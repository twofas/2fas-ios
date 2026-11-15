//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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

import WidgetKit
import Storage
import Protection
import Common

enum AccessManager {
    static var protection: Protection = {
        Protection()
    }()

    private static let lock = NSLock()
    private static var cachedStorage: Storage?

    /// Checked on every call, as this process may outlive what the main app does with the stores:
    /// - a store opened in memory (its migration waits for the main app) isn't kept, so the widget shows the
    ///   services once the main app has migrated the store,
    /// - when the main app replaced the key (it reset the local data), the stores were replaced with it – the
    ///   current key is loaded and the store is opened again.
    static var storage: Storage {
        lock.withLock {
            let isKeyReplaced = protection.reloadLocalStorageKeyIfChanged()
            if let cachedStorage, !cachedStorage.isMigrationDeferred, !isKeyReplaced {
                return cachedStorage
            }
            EncryptionHolder.initialize(with: protection.localKeyEncryption)
            let storage = Storage(
                readOnly: true,
                initializeLogStorage: false,
                cipher: protection.localStorageCipher,
                allowsMigration: false,
                logError: nil
            )
            cachedStorage = storage
            return storage
        }
    }

    static var serviceHandler: WidgetServiceHandlerType {
        storage.widgetService
    }
}
