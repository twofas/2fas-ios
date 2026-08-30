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
import Common

struct SettingsMenuSection: Identifiable {
    let id = UUID()
    let title: String?
    var cells: [SettingsMenuCell]
    let footer: String?

    init(title: String? = nil, cells: [SettingsMenuCell], footer: String? = nil) {
        self.title = title
        self.cells = cells
        self.footer = footer
    }
}

struct SettingsMenuCell: Identifiable {
    enum Icon {
        case symbol(IconName)
        case brand(UIImage)
    }
    enum AccessoryKind {
        case arrow
        case toggle(kind: SettingsNavigationToggle, isOn: Bool)
        case external
        case warning
    }
    enum Action: Hashable {
        case navigation(navigatesTo: SettingsNavigationModule)
    }

    let id = UUID()
    let icon: Icon?
    let title: String
    let info: String?
    let accessory: AccessoryKind?
    let action: Action?
    let isEnabled: Bool
    let rememberPosition: Bool

    init(
        icon: Icon? = nil,
        title: String,
        info: String? = nil,
        accessory: AccessoryKind? = nil,
        action: Action? = nil,
        isEnabled: Bool = true,
        rememberPosition: Bool = true
    ) {
        self.icon = icon
        self.title = title
        self.info = info
        self.accessory = accessory
        self.action = action
        self.isEnabled = isEnabled
        self.rememberPosition = rememberPosition
    }
}

enum SettingsNavigationModule: Hashable {
    case backup
    case browserExtension
    case security
    case trash
    case faq
    case about
    case transfer
    case appearance
    case appleWatch
    case openPass
    case appStorePass
    #if DEV
    case debug
    #endif
}

enum SettingsNavigationToggle: Hashable {
    case widgets
}

extension Array where Element == SettingsMenuSection {
    func indexPath(for module: SettingsNavigationModule) -> IndexPath? {
        for (sectionIndex, section) in self.enumerated() {
            for (cellIndex, cell) in section.cells.enumerated() {
                if let action = cell.action, case SettingsMenuCell.Action.navigation(let navigatesTo) = action,
                    navigatesTo == module {
                    return IndexPath(row: cellIndex, section: sectionIndex)
                }
            }
        }

        return nil
    }
}

extension SettingsMenuCell {
    var shouldSelectCell: Bool {
        switch self.action {
        case .navigation: return true
        default: return false
        }
    }

    var module: SettingsNavigationModule? {
        if case .navigation(let module) = action {
            return module
        }
        return nil
    }
}
