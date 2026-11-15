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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

public final class Protection {
    public typealias PIN = String
    
    public enum CodeType: CaseIterable {
        case PIN4
        case PIN6
    }
    
    public struct Code {
        let PINvalue: PIN
        let codeType: CodeType
    }
    public let reference = Keys.Reference.dataValue
    /// Only the main app (`isMainApp`) can create the key, extensions only use an existing one
    public let localStorageCipher: LocalStorageCipherAdmin
    #if os(iOS)
    public let localEncryptionKeyData: Data = Keys.LocalEncryptionKey.dataValue
    private let encryptedStorage: LocalEncryptedStorage
    
    public let biometricAuth: BiometricAuth
    public let codeStorage: CodeStorage
    public let tokenStorage: TokenStorageType
    public let localKeyEncryption: CommonLocalKeyEncryption
    public let extensionsStorage: ExtensionsStorage
    
    private let migrationHandler: MigrationHandler
    
    public init(isMainApp: Bool = false) {
        localStorageCipher = Self.makeLocalStorageCipher(isMainApp: isMainApp)
        encryptedStorage = LocalEncryptedStorage(
            defaults: UserDefaults(suiteName: Config.groupIdentifier)!,
            cipher: localStorageCipher
        )
        biometricAuth = BiometricAuth(storage: encryptedStorage)
        codeStorage = CodeStorage(storage: encryptedStorage)
        tokenStorage = TokenStorage(storage: encryptedStorage)
        localKeyEncryption = LocalKeyEncryption()
        extensionsStorage = ExtensionsStorage(storage: encryptedStorage)
        migrationHandler = MigrationHandler(storage: encryptedStorage)
        migrationHandler.migrateIfNeeded()
    }
    #elseif os(watchOS)
    public let localKeyEncryption: CommonLocalKeyEncryption
    public let localEncryptionKeyData: Data
    public init(isMainApp: Bool = false) {
        localStorageCipher = Self.makeLocalStorageCipher(isMainApp: isMainApp)
        localKeyEncryption = LocalKeyEncryption()
        localEncryptionKeyData = Keys.LocalEncryptionKey.dataValue
    }
    #endif
}

#if os(iOS)
public extension Protection {
    /// For the main app, after the local storage key was replaced (the local data was reset): what was sealed with
    /// the old key – the PIN, the notification token, the device ID – can't be opened any more. It's removed with
    /// what depends on it: without the PIN there's no app lock, so the PIN type and the biometry setting go too.
    func resetSealedSettings() {
        encryptedStorage.removeSealedValues()
        codeStorage.remove()
        biometricAuth.disable()
        tokenStorage.removeAll()
    }
}
#endif

public extension Protection {
    /// For a process that outlives a reset of the local data in the main app (an extension): makes the cipher
    /// load the current key when it was replaced.
    /// - Returns: Whether the key was replaced – the stores were replaced along with it and have to be reopened.
    func reloadLocalStorageKeyIfChanged() -> Bool {
        (localStorageCipher as? LocalStorageCipherImpl)?.reloadKeyIfChanged() ?? false
    }
}

private extension Protection {
    static func makeLocalStorageCipher(isMainApp: Bool) -> LocalStorageCipherAdmin {
        let keyStore = LocalStorageKeyStore(
            defaults: UserDefaults(suiteName: Config.groupIdentifier)!,
            keychain: SystemKeychainItemStore(),
            protections: [PlainDataKeyProtection()]
        )
        return LocalStorageCipherImpl(keyStore: keyStore, canCreateKey: isMainApp)
    }
}
