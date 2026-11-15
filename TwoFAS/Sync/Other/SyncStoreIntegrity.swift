//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>
//

import Foundation
import CoreData
#if os(iOS)
import UIKit
import Common
#elseif os(watchOS)
import WatchKit
import CommonWatch
#endif

enum SyncStoreIntegrity {
    /// Whether every `ServiceCacheEntity` (content and metadata) and every `LogEntity` can be decrypted. Has to be
    /// called on the queue of the context.
    static func verify(context: NSManagedObjectContext) -> Bool {
        do {
            for service in ServiceCacheEntity.listAll(on: context) {
                _ = try service.decryptedContent()
                _ = try service.decryptedMetadata()
            }
            for log in LogEntity.listAll(on: context) {
                _ = try log.decryptedEntityID()
            }
            return true
        } catch {
            Log(
                "SyncStoreIntegrity - the cache can't be decrypted: \(SealedEntity.describe(error))",
                module: .cloudSync,
                severity: .error
            )
            return false
        }
    }

    /// Sync can't run while the key is lost or unavailable – an empty list read from an undecryptable store would look
    /// like deletions. Nor in a launch in which a stack was opened in memory because its migration was deferred
    /// (`isDeferred`) – the empty store synced with the saved change tokens would diverge from the cloud.
    static func shouldSync(cipherState: LocalStorageCipherState, isDeferred: Bool) -> Bool {
        guard !isDeferred else { return false }
        switch cipherState {
        case .available, .noKey: return true
        case .keyLost, .keyUnavailable: return false
        }
    }
    
    /// The state of the cipher of the Sync store's context – no cipher counts as unavailable
    static func cipherState(of context: NSManagedObjectContext) -> LocalStorageCipherState {
        context.localStorageCipher?.state ?? .keyUnavailable
    }
    
    /// Runs `start` (Sync from scratch: clearing the change log, the cache and the checkpoints, logging the first
    /// import) when Sync may run. Otherwise changes nothing and only schedules a reset – the next allowed sync does the
    /// same work through `SyncLocalReset` – as the first import couldn't be logged without the key (or would log the
    /// empty in-memory store of a deferred launch).
    /// - Returns: Whether `start` was run.
    @discardableResult
    static func startFromScratch(on context: NSManagedObjectContext, isDeferred: Bool, _ start: () -> Void) -> Bool {
        let state = cipherState(of: context)
        guard shouldSync(cipherState: state, isDeferred: isDeferred) else {
            Log(
                "SyncStoreIntegrity - Can't start from scratch. Local storage key state: \(state), "
                + "deferred: \(isDeferred). Reset scheduled",
                module: .cloudSync
            )
            ConstStorage.syncResetRequired = true
            return false
        }
        start()
        return true
    }

    /// The value read by `read`, or `nil` when it can't be decrypted – logged (entity name and error code only) and
    /// a reset of the cache is scheduled then
    static func valueOrScheduleReset<Value>(
        entityName: String,
        field: String,
        _ read: () throws -> Value
    ) -> Value? {
        do {
            return try read()
        } catch SealedEntity.Failure.missingContext {
            assertionFailure("\(entityName) - reading \(field) without a context")
            return nil
        } catch {
            Log(
                "\(entityName) - can't open \(field): \(SealedEntity.describe(error))",
                module: .cloudSync,
                severity: .error
            )
            ConstStorage.syncResetRequired = true
            return nil
        }
    }
}

/// What `SyncHandler.synchronize()` does before a sync starts. The checks run in this order: the key state and a
/// deferral for this launch, a sync in progress, then a scheduled reset or a cache that can't be decrypted.
enum SyncPreflight: Equatable {
    /// Sync can't run now (key lost or unavailable, or deferred for this launch) – nothing is started
    case notAllowed
    /// A sync is in progress – it still uses the cache, so the cache isn't checked
    case inProgress
    /// The cache is reset from scratch before the sync (a reset is scheduled or the cache can't be decrypted)
    case resetFirst
    case proceed

    static func decide(
        cipherState: LocalStorageCipherState,
        isDeferred: Bool,
        isSyncing: Bool,
        resetRequired: Bool,
        isCacheReadable: () -> Bool
    ) -> SyncPreflight {
        guard SyncStoreIntegrity.shouldSync(cipherState: cipherState, isDeferred: isDeferred) else {
            return .notAllowed
        }
        guard !isSyncing else { return .inProgress }
        guard !resetRequired, isCacheReadable() else { return .resetFirst }
        return .proceed
    }

    /// The result a pending notification handler is completed with right away. `nil` – the sync that starts (or the
    /// one in progress) completes it.
    var notificationResult: BackgroundFetchResult? {
        switch self {
        case .notAllowed: .noData
        case .inProgress, .resetFirst, .proceed: nil
        }
    }
}

/// Resets the local Sync state from scratch – the same state as `SyncHandler.firstStart()` clears: the next sync
/// fetches everything and merges it with the local data
struct SyncLocalReset {
    let store: CoreDataStack
    /// The cached Info record (`InfoHandler.purge()`) – kept outside the store
    let clearInfoCache: () -> Void
    let clearCheckpoints: () -> Void
    /// The change tokens of a fetch in progress (`CloudKit.clear()`), committed after the fetch callback otherwise
    let clearPendingTokens: () -> Void
    let clearQueue: () -> Void
    /// `false` when not every item could be logged
    let logFirstImport: () -> Bool

    /// Empties the Sync store, so no object or background context of the store may be in use during the call.
    /// - Returns: `false` when the first import couldn't be logged – the reset stays scheduled then and Sync mustn't
    ///   run (the items missing in the cloud would be trashed).
    @discardableResult
    func perform() -> Bool {
        Log("SyncLocalReset - resetting the Sync cache from scratch", module: .cloudSync)
        store.destroyAndRecreateStore()
        clearInfoCache()
        clearCheckpoints()
        // A reset inside the fetch callback would be undone by the tokens CloudKit commits after it
        clearPendingTokens()
        clearQueue()
        guard logFirstImport() else {
            Log("SyncLocalReset - the first import couldn't be logged. Reset stays scheduled", module: .cloudSync)
            ConstStorage.syncResetRequired = true
            return false
        }
        ConstStorage.syncResetRequired = false
        return true
    }
}
