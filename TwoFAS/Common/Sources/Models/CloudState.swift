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

import Foundation

public enum CloudState: Equatable {
    public enum NotAvailableReason: Equatable {
        public enum EncryptionError: Equatable {
            case cantCreateEncryptionElements
            case missingSystemKey
            case missingUserKey
            case missingAllKeys
            /// Records of the backup can't be opened with the keys of this device
            case unreadableRecords
        }
        
        case overQuota
        case disabledByUser
        case error(error: NSError?)
        case useriCloudProblem
        case other
        case newerVersion
        case incorrectService(serviceName: String)
        case cloudEncryptedUser
        case cloudEncryptedSystem
        case encryptionError(encryptionError: EncryptionError)

        /// The backup was stopped by something only the user can do something about (a missing key or password,
        /// a newer version, a service that can't be saved) – unlike iCloud not being available. The reason stays
        /// until the user turns the backup on (it's tried again) or off.
        public var isStopOfTheBackup: Bool {
            switch self {
            case .newerVersion, .incorrectService, .cloudEncryptedUser, .cloudEncryptedSystem, .encryptionError:
                true
            case .overQuota, .disabledByUser, .useriCloudProblem, .error, .other:
                false
            }
        }
    }
    
    public enum Sync: Equatable {
        case syncing
        case synced
    }
    
    case unknown
    case disabledNotAvailable(reason: NotAvailableReason)
    case disabledAvailable
    case enabled(sync: Sync)
}

public enum EncryptionError: Error {
    case cantCreateEncryptionElements
    case missingSystemKey
    case missingUserKey
    case missingAllKeys
    case unreadableRecords
}
