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
import Data
import Common

struct BackupMenuSection: TableViewSection {
    let title: String?
    var cells: [BackupMenuCell]
    let footer: String?
    
    init(title: String? = nil, cells: [BackupMenuCell], footer: String? = nil) {
        self.title = title
        self.cells = cells
        self.footer = footer
    }
}

struct BackupMenuCell: Hashable {
    struct Toggle: Hashable {
        let kind: BackupNavigationToggle
        let isOn: Bool
        let isActive: Bool
    }
    
    let icon: UIImage?
    let title: String
    let accessory: Toggle?
    let action: BackupNavigationAction?
    let isEnabled: Bool
    
    init(
        icon: UIImage? = nil,
        title: String,
        accessory: Toggle? = nil,
        action: BackupNavigationAction? = nil,
        isEnabled: Bool = true
    ) {
        self.icon = icon
        self.title = title
        self.accessory = accessory
        self.action = action
        self.isEnabled = isEnabled
    }
}

enum BackupNavigationAction: Hashable {
    case importFile
    case exportFile
    case deleteCloudBackup
}

enum BackupNavigationToggle: Hashable {
    case backup
}

extension Array where Element == BackupMenuSection {
    func indexPath(for action: BackupNavigationAction) -> IndexPath? {
        for (sectionIndex, section) in self.enumerated() {
            for (cellIndex, cell) in section.cells.enumerated() {
                if let cellAction = cell.action, cellAction == action {
                    return IndexPath(row: cellIndex, section: sectionIndex)
                }
            }
        }
        return nil
    }
}

extension CloudState.NotAvailableReason {
    var errorText: String? {
        switch self {
        case .disabledByUser: return T.Backup.icloudDisabledTitle
        case .other: return T.Backup.icloudNotAvailable
        case .error(let error): return error?.localizedDescription
        case .overQuota: return T.Backup.userOverQuotaIcloud
        case .incorrectService(let serviceName): return T.Backup.incorrectSecret(serviceName)
        case .useriCloudProblem: return T.Backup.icloudProblem
        case .newerVersion: return T.Error.cloudBackupNewerVersion
        case .cloudEncrypted: return T.Error.cloudBackupEncryptedNotSupported
        }
    }
}
