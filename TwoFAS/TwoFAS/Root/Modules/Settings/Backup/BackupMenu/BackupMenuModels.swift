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

struct BackupMenuSection: Identifiable {
    let id = UUID()
    let title: String?
    var cells: [BackupMenuCell]
    let footer: String?

    init(title: String? = nil, cells: [BackupMenuCell], footer: String? = nil) {
        self.title = title
        self.cells = cells
        self.footer = footer
    }
}

struct BackupMenuCell: Identifiable {
    struct Toggle {
        let kind: BackupNavigationToggle
        let isOn: Bool
        let isActive: Bool
    }

    let id = UUID()
    let title: String
    let accessory: Toggle?
    let action: BackupNavigationAction?
    let isEnabled: Bool

    init(
        title: String,
        accessory: Toggle? = nil,
        action: BackupNavigationAction? = nil,
        isEnabled: Bool = true
    ) {
        self.title = title
        self.accessory = accessory
        self.action = action
        self.isEnabled = isEnabled
    }
}

enum BackupNavigationAction: Hashable {
    case importFile
    case exportFile
    case manageAppleWatch
    case manageBackup
    case advanced
    case reloadKeys
}

enum BackupNavigationToggle: Hashable {
    case backup
}
