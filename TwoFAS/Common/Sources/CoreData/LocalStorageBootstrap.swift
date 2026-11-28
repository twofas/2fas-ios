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

public enum LocalStorageBootstrapResult: Equatable {
    case ready
    case wipedStores
    /// The key that sealed the stored data can't be found. Nothing was removed yet – the stores are removed when the
    /// key is still missing in `launchesLeft` more launches (or when the user resets the local data).
    case keyLostPending(launchesLeft: Int)
}

/// Counts the consecutive launches in which the key of the stored data was missing. A single answer of Keychain
/// isn't trusted with removing the user's data.
public struct LostKeyLaunchCounter {
    /// The stores are removed in the launch with this number (counted from 1)
    public static let wipeThreshold = 3
    static let defaultsKey = "com.2fas.localStorageLostKeyLaunches"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    public var count: Int { defaults.integer(forKey: Self.defaultsKey) }

    public func increment() {
        defaults.set(count + 1, forKey: Self.defaultsKey)
    }

    public func reset() {
        defaults.removeObject(forKey: Self.defaultsKey)
    }
}

/// Prepares the local storage key and the stores before they are opened by the main app.
public enum LocalStorageBootstrap {
    /// - Parameters:
    ///   - storeNames: Names of all local stores that are encrypted with the local storage key.
    ///   - storesRequiringMigration: Stores that need a migration in this launch. Only then the key is created
    ///     ahead of the first write (the migration seals the data).
    ///   - incompatibleStoreNames: Stores proven to be incompatible with the current model. When non-empty,
    ///     all stores are removed (they are rebuilt from the cloud).
    ///   - hasSealedData: Whether the stores hold data sealed with the local storage key. Asked only when the key
    ///     is missing: without sealed data nothing is lost with the key, so nothing is removed.
    ///   - sealedDataOpens: Whether the key opens what is stored. Asked only when there is a key (and launches are
    ///     counted): a key that doesn't open the stored data is handled like a lost one – the data can't be
    ///     read with it either – instead of showing an empty app.
    ///   - lostKeyCounter: `nil` – the stores are removed as soon as the key is found missing.
    ///   - countsLaunch: Whether this call is the first one in a launch opened by the user. Only then the launch
    ///     is counted – and only such a call removes the stores of a lost key. A check made in the background
    ///     (a push, a background refresh) or repeated in the same launch never removes anything.
    ///   - directory: Directory of the stores. `nil` – the app group container.
    public static func prepare(
        cipher: LocalStorageCipherAdmin,
        storeNames: [String],
        storesRequiringMigration: [String] = [],
        incompatibleStoreNames: [String] = [],
        hasSealedData: () -> Bool = { true },
        sealedDataOpens: () -> Bool = { true },
        lostKeyCounter: LostKeyLaunchCounter? = nil,
        countsLaunch: Bool = true,
        directory: URL? = nil
    ) -> LocalStorageBootstrapResult {
        if !incompatibleStoreNames.isEmpty {
            Log("Local storage bootstrap: incompatible stores, removing", module: .storage)
            return wipe(cipher: cipher, storeNames: storeNames, lostKeyCounter: lostKeyCounter, directory: directory)
        }

        switch cipher.state {
        case .keyUnavailable:
            Log("Local storage bootstrap: key unavailable", module: .storage)
            return .ready
        case .keyLost:
            guard hasSealedData() else {
                // Nothing was sealed with the key (e.g. the stores still wait for the migration)
                Log("Local storage bootstrap: key lost, no sealed data – discarding the key", module: .storage)
                cipher.discardLostKey()
                lostKeyCounter?.reset()
                createKeyIfNeeded(cipher: cipher, storesRequiringMigration: storesRequiringMigration)
                return .ready
            }
            return handleMissingKey(
                cipher: cipher,
                storeNames: storeNames,
                lostKeyCounter: lostKeyCounter,
                countsLaunch: countsLaunch,
                directory: directory
            )
        case .noKey:
            // Sealed data without a key ID: the key that sealed it can't be found any more. Creating a new key
            // would leave that data undecryptable for good.
            if lostKeyCounter != nil, hasSealedData() {
                Log("Local storage bootstrap: sealed data without a key", module: .storage)
                return handleMissingKey(
                    cipher: cipher,
                    storeNames: storeNames,
                    lostKeyCounter: lostKeyCounter,
                    countsLaunch: countsLaunch,
                    directory: directory
                )
            }
            lostKeyCounter?.reset()
            createKeyIfNeeded(cipher: cipher, storesRequiringMigration: storesRequiringMigration)
            return .ready
        case .available:
            if lostKeyCounter != nil, !sealedDataOpens() {
                Log("Local storage bootstrap: the key doesn't open the stored data", module: .storage)
                return handleMissingKey(
                    cipher: cipher,
                    storeNames: storeNames,
                    lostKeyCounter: lostKeyCounter,
                    countsLaunch: countsLaunch,
                    discardsKey: true,
                    directory: directory
                )
            }
            lostKeyCounter?.reset()
            return .ready
        }
    }

    /// Removes the stores and forgets the key – the explicit decision of the user, in any state of the key.
    public static func resetLocalData(
        cipher: LocalStorageCipherAdmin,
        storeNames: [String],
        lostKeyCounter: LostKeyLaunchCounter? = nil,
        directory: URL? = nil
    ) {
        Log("Local storage bootstrap: resetting the local data on request", module: .storage)
        destroyStores(storeNames, directory: directory)
        cipher.discardLostKey()
        lostKeyCounter?.reset()
    }

    // MARK: - Private

    private static func handleMissingKey(
        cipher: LocalStorageCipherAdmin,
        storeNames: [String],
        lostKeyCounter: LostKeyLaunchCounter?,
        countsLaunch: Bool,
        discardsKey: Bool = false,
        directory: URL?
    ) -> LocalStorageBootstrapResult {
        guard let lostKeyCounter else {
            Log("Local storage bootstrap: key lost, removing stores", module: .storage)
            return wipe(
                cipher: cipher,
                storeNames: storeNames,
                lostKeyCounter: nil,
                discardsKey: discardsKey,
                directory: directory
            )
        }
        guard countsLaunch else {
            // Whatever the counter says (it may be left over from an interrupted launch): nothing is removed
            // in a call that isn't a launch opened by the user
            let launches = lostKeyCounter.count
            Log("Local storage bootstrap: key lost, not counted (\(launches) so far), stores kept", module: .storage)
            return .keyLostPending(launchesLeft: max(1, LostKeyLaunchCounter.wipeThreshold - launches))
        }
        lostKeyCounter.increment()
        let launches = lostKeyCounter.count
        guard launches >= LostKeyLaunchCounter.wipeThreshold else {
            Log("Local storage bootstrap: key lost in \(launches) launch(es), stores kept", module: .storage)
            return .keyLostPending(launchesLeft: LostKeyLaunchCounter.wipeThreshold - launches)
        }
        Log("Local storage bootstrap: key lost in \(launches) launches, removing stores", module: .storage)
        return wipe(
            cipher: cipher,
            storeNames: storeNames,
            lostKeyCounter: lostKeyCounter,
            discardsKey: discardsKey,
            directory: directory
        )
    }

    private static func wipe(
        cipher: LocalStorageCipherAdmin,
        storeNames: [String],
        lostKeyCounter: LostKeyLaunchCounter?,
        discardsKey: Bool = false,
        directory: URL?
    ) -> LocalStorageBootstrapResult {
        destroyStores(storeNames, directory: directory)
        // A key that doesn't open the stored data is replaced along with the stores
        if discardsKey || cipher.state == .keyLost {
            cipher.discardLostKey()
        }
        lostKeyCounter?.reset()
        return .wipedStores
    }

    private static func createKeyIfNeeded(cipher: LocalStorageCipherAdmin, storesRequiringMigration: [String]) {
        guard !storesRequiringMigration.isEmpty, cipher.state == .noKey else { return }
        do {
            try cipher.createKeyIfNeeded()
        } catch {
            Log("Local storage bootstrap: unable to create key (\(type(of: error)))", module: .storage)
        }
    }

    private static func destroyStores(_ storeNames: [String], directory: URL?) {
        storeNames.forEach { CoreDataStack.destroyStoreFiles(name: $0, directory: directory) }
    }
}
