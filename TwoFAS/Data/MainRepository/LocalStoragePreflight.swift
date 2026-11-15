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

import UIKit
import Common
import Protection
import Storage
import Sync

public enum LocalStorageStatus: Equatable {
    /// The stores are migrated and the key can be used – the app can start
    case ready
    /// The key that sealed the stored data can't be found. The data is kept for `launchesLeft` more launches
    /// opened by the user, then removed.
    case keyLost(launchesLeft: Int)
    /// The key can't be read (or created) right now. Nothing is removed.
    case keyUnavailable
    /// The stores couldn't be migrated. They are left as they were.
    case migrationFailed
}

/// The first stage of starting the main app: prepares the local storage key and migrates the stores. Until it
/// returns `.ready` nothing else of the app is created – the main app never runs on an empty stand-in store, as
/// everything written to it would be lost.
///
/// Has to be used on the main thread.
public enum LocalStoragePreflight {
    static let protection = Protection(isMainApp: true)

    private static let storeNames = [Storage.storeName, SyncInstance.storeName]
    private static let lostKeyCounter = LostKeyLaunchCounter(defaults: .standard)
    private static var status: LocalStorageStatus?
    private static var didCountLaunch = false
    /// The stores were migrated or removed in this launch – what the widgets show is outdated
    private(set) static var didChangeStores = false

    public static var isReady: Bool { status == .ready }

    /// Checks the local storage, migrating the stores when they need it. Can be repeated until it returns `.ready`.
    /// - Parameter userVisible: The app was opened by the user. Only such launches count towards removing the data
    ///   of a lost key – once per launch.
    @discardableResult
    public static func run(userVisible: Bool) -> LocalStorageStatus {
        // Once ready, the stores are in use
        if status == .ready { return .ready }
        let newStatus = evaluate(countsLaunch: userVisible && !didCountLaunch)
        if userVisible {
            didCountLaunch = true
        }
        status = newStatus
        return newStatus
    }

    /// Removes the local stores and forgets the key – the decision of the user, who knows the key is gone (or
    /// gives up waiting for it). Services synced with the cloud are downloaded again.
    @discardableResult
    public static func resetLocalData() -> LocalStorageStatus {
        guard status != .ready else { return .ready }
        LocalStorageBootstrap.resetLocalData(
            cipher: protection.localStorageCipher,
            storeNames: storeNames,
            lostKeyCounter: lostKeyCounter
        )
        SyncInstance.scheduleResetFromScratch()
        protection.resetSealedSettings()
        didChangeStores = true
        return run(userVisible: false)
    }

    // MARK: - Private

    private static func evaluate(countsLaunch: Bool) -> LocalStorageStatus {
        // The migration policies read the legacy obfuscated values
        EncryptionHolder.initialize(with: protection.localKeyEncryption)
        let cipher = protection.localStorageCipher

        let result = LocalStorageBootstrap.prepare(
            cipher: cipher,
            storeNames: storeNames,
            storesRequiringMigration: storesRequiringMigration(),
            hasSealedData: { Storage.storeContainsSealedData() },
            lostKeyCounter: lostKeyCounter,
            countsLaunch: countsLaunch
        )
        switch result {
        case .keyLostPending(let launchesLeft):
            return .keyLost(launchesLeft: launchesLeft)
        case .wipedStores:
            SyncInstance.scheduleResetFromScratch()
            // Sealed with the key that is gone
            protection.resetSealedSettings()
            didChangeStores = true
        case .ready:
            break
        }

        let requiresMigration = !storesRequiringMigration().isEmpty
        switch cipher.state {
        case .keyUnavailable, .keyLost:
            return .keyUnavailable
        case .noKey:
            // The migration seals the data – the key couldn't be created
            if requiresMigration { return .keyUnavailable }
        case .available:
            break
        }

        let backgroundTask = requiresMigration ? MigrationBackgroundTask() : nil
        defer { backgroundTask?.end() }
        do {
            let didMigrateStorage = try Storage.prepareStore(cipher: cipher)
            let didMigrateSync = try SyncInstance.prepareStore(cipher: cipher)
            if didMigrateStorage || didMigrateSync {
                didChangeStores = true
            }
        } catch {
            Log(
                "LocalStoragePreflight - migration failed: \(describe(error))",
                module: .storage,
                severity: .error
            )
            return .migrationFailed
        }
        return .ready
    }

    private static func storesRequiringMigration() -> [String] {
        [
            Storage.storeRequiresMigration() ? Storage.storeName : nil,
            SyncInstance.storeRequiresMigration() ? SyncInstance.storeName : nil
        ].compactMap { $0 }
    }

    /// Safe for logs: the stage with the domain and the code of the error only
    private static func describe(_ error: Error) -> String {
        if let error = error as? CoreDataMigrationError {
            return error.logDescription
        }
        let error = error as NSError
        return "\(error.domain) \(error.code)"
    }
}

/// Keeps the app running when it goes to the background during the migration of the local stores – suspended in the
/// middle, the migration would start over at the next launch
private final class MigrationBackgroundTask {
    private var identifier = UIBackgroundTaskIdentifier.invalid

    init() {
        identifier = UIApplication.shared.beginBackgroundTask(withName: "LocalStorageMigration") { [weak self] in
            self?.end()
        }
    }

    func end() {
        guard identifier != .invalid else { return }
        UIApplication.shared.endBackgroundTask(identifier)
        identifier = .invalid
    }
}
