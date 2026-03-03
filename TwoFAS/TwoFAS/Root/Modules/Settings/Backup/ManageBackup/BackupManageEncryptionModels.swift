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

import UIKit
import Data

struct BackupManageEncryptionSection: TableViewSection {
    let title: String?
    var cells: [BackupManageEncryptionCell]
    let footer: String?
    
    init(title: String? = nil, cells: [BackupManageEncryptionCell], footer: String? = nil) {
        self.title = title
        self.cells = cells
        self.footer = footer
    }
}

struct BackupManageEncryptionCell: Hashable {
    enum Action: Hashable {
        case encrypt
        case decrypt
        case recrypt
        case clear
    }
    
    let title: String
    let action: Action
    let isEnabled: Bool
    var icon: UIImage {
        action.icon
    }
    
    init(title: String, action: Action, isEnabled: Bool) {
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
    }
}

extension BackupManageEncryptionCell.Action {
    var icon: UIImage {
        switch self {
        case .encrypt: UIImage(systemName: "lock.icloud.fill")!
        case .decrypt: UIImage(systemName: "lock.open.fill")!
        case .recrypt: UIImage(systemName: "lock.open.rotation")!
        case .clear: UIImage(systemName: "xmark.icloud.fill")!
        }
    }
}
