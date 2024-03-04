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

struct AppSecurityMenuSection: TableViewSection {
    let title: String?
    var cells: [AppSecurityMenuCell]
    let footer: String?
    
    init(title: String? = nil, cells: [AppSecurityMenuCell], footer: String? = nil) {
        self.title = title
        self.cells = cells
        self.footer = footer
    }
}

struct AppSecurityMenuCell: Hashable {
    struct Toggle: Hashable {
        let kind: ToggleKind
        let isOn: Bool
        let isBlocked: Bool
    }
    
    // swiftlint:disable discouraged_none_name
    enum Accessory: Hashable {
        case none
        case arrow
        case info(text: String)
        case toggle(toggle: Toggle)
    }
    // swiftlint:enable discouraged_none_name
    
    enum Action: Hashable {
        case changePIN
        case limit
    }
    
    enum ToggleKind: Hashable {
        case PIN
        case biometry
    }
    
    let title: String
    let accessory: Accessory
    let action: Action?
    
    init(title: String, accessory: Accessory, action: Action? = nil) {
        self.title = title
        self.accessory = accessory
        self.action = action
    }
}

extension Array where Element == AppSecurityMenuSection {
    func indexPath(for action: AppSecurityMenuCell.Action) -> IndexPath? {
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
