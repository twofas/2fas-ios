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
    #if os(iOS)
    private let encryptedStorage: LocalEncryptedStorage
    
    public let biometricAuth: BiometricAuth
    public let codeStorage: CodeStorage
    public let tokenStorage: TokenStorageType
    public let localKeyEncryption: CommonLocalKeyEncryption
    public let extensionsStorage: ExtensionsStorage
    
    private let migrationHandler: MigrationHandler
    
    public init() {
        encryptedStorage = LocalEncryptedStorage(defaults: UserDefaults(suiteName: Config.suiteName)!)
        biometricAuth = BiometricAuth(storage: encryptedStorage)
        codeStorage = CodeStorage(storage: encryptedStorage)
        tokenStorage = TokenStorage(storage: encryptedStorage)
        localKeyEncryption = LocalKeyEncryption()
        extensionsStorage = ExtensionsStorage(storage: encryptedStorage)
        migrationHandler = MigrationHandler(storage: encryptedStorage)
        migrationHandler.migrateIfNeeded()
    }
    #elseif os(watchOS)
//    private let encryptedStorage: LocalEncryptedStorage
//    public let codeStorage: CodeStorage
      public let localKeyEncryption: CommonLocalKeyEncryption
//
    public init() {
//        encryptedStorage = LocalEncryptedStorage(defaults: UserDefaults(suiteName: Config.suiteName)!)
//        codeStorage = CodeStorage(storage: encryptedStorage)
        localKeyEncryption = LocalKeyEncryption()
    }
    #endif
}
