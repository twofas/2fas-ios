//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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
import Common

extension CloudState.Sync {
    var description: String {
        switch self {
        case .syncing: T.Backup.syncStatusProgress
        case .synced: T.Backup.synced
        }
    }
}

extension CloudState {
    var description: String {
        switch self {
        case .unknown: T.Backup.checking
        case .disabledNotAvailable(let reason): T.Backup.syncNotAvailable(reason.description)
        case .disabledAvailable: T.Backup.syncDisabled
        case .enabled(let sync): sync.description
        }
    }
}

extension CloudState.NotAvailableReason {
    var description: String {
        switch self {
        case .disabledByUser: return T.Backup.icloudDisabledTitle
        case .other: return T.Backup.icloudNotAvailable
        case .error(let error): return error?.localizedDescription ?? T.Commons.unknownError
        case .overQuota: return T.Backup.userOverQuotaIcloud
        case .incorrectService(let serviceName): return T.Backup.incorrectSecret(serviceName)
        case .useriCloudProblem: return T.Backup.icloudProblem
        case .newerVersion: return T.Error.cloudBackupNewerVersion
        case .cloudEncryptedUser: return T.Backup.cloudEncryptedUser
        case .cloudEncryptedSystem: return T.Backup.cloudEncryptedSystem
        }
    }
}
