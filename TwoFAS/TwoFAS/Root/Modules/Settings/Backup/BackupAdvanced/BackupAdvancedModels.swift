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
import Data

struct BackupAdvancedSection: Identifiable {
    let id = UUID()
    let title: String?
    var cells: [BackupAdvancedCell]
    let footer: String?

    init(title: String? = nil, cells: [BackupAdvancedCell], footer: String? = nil) {
        self.title = title
        self.cells = cells
        self.footer = footer
    }
}

struct BackupAdvancedCell: Identifiable {
    enum Action: Hashable {
        case exportKeys
        case importKeys
        case deleteBackup
    }

    let id = UUID()
    let title: String
    let action: Action
    let isEnabled: Bool

    var iconSystemName: String {
        switch action {
        case .exportKeys: return "arrow.up.doc.fill"
        case .importKeys: return "square.and.arrow.down.on.square.fill"
        case .deleteBackup: return "xmark.icloud.fill"
        }
    }

    init(title: String, action: Action, isEnabled: Bool) {
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
    }
}
