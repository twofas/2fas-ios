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
}

/// Prepares the local storage key and the stores before they are opened by the main app.
public enum LocalStorageBootstrap {
    /// - Parameters:
    ///   - storeNames: Names of all local stores that are encrypted with the local storage key.
    ///   - storesRequiringMigration: Stores that need a migration in this launch. Only then the key is created
    ///     ahead of the first write (the migration seals the data).
    ///   - incompatibleStoreNames: Stores proven to be incompatible with the current model. When non-empty,
    ///     all stores are removed (they are rebuilt from the cloud).
    ///   - directory: Directory of the stores. `nil` – the app group container.
    public static func prepare(
        cipher: LocalStorageCipherAdmin,
        storeNames: [String],
        storesRequiringMigration: [String] = [],
        incompatibleStoreNames: [String] = [],
        directory: URL? = nil
    ) -> LocalStorageBootstrapResult {
        if !incompatibleStoreNames.isEmpty {
            Log("Local storage bootstrap: incompatible stores, removing", module: .storage)
            destroyStores(storeNames, directory: directory)
            if cipher.state == .keyLost {
                cipher.discardLostKey()
            }
            return .wipedStores
        }

        switch cipher.state {
        case .keyUnavailable:
            Log("Local storage bootstrap: key unavailable", module: .storage)
            return .ready
        case .keyLost:
            Log("Local storage bootstrap: key lost, removing stores", module: .storage)
            destroyStores(storeNames, directory: directory)
            cipher.discardLostKey()
            return .wipedStores
        case .noKey:
            if !storesRequiringMigration.isEmpty {
                do {
                    try cipher.createKeyIfNeeded()
                } catch {
                    Log("Local storage bootstrap: unable to create key (\(type(of: error)))", module: .storage)
                }
            }
            return .ready
        case .available:
            return .ready
        }
    }

    private static func destroyStores(_ storeNames: [String], directory: URL?) {
        storeNames.forEach { CoreDataStack.destroyStoreFiles(name: $0, directory: directory) }
    }
}
