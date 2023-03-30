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

struct AboutSection: TableViewSection {
    let title: String
    var cells: [AboutCell]
    let footer: String?
    
    init(title: String, cells: [AboutCell], footer: String? = nil) {
        self.title = title
        self.cells = cells
        self.footer = footer
    }
}

struct AboutCell: Hashable {
    enum AccessoryKind: Hashable {
        case external
        case share
        case noAccessory
        case toggle(isOn: Bool)
    }
    enum Action: Hashable {
        case writeReview
        case privacyPolicy
        case tos
        case share
        case sendLogs
        case acknowledgements
    }
    
    let title: String
    let accessory: AccessoryKind
    let action: Action?
}

extension AboutCell.AccessoryKind {
    var icon: UIImage? {
        switch self {
        case .share: return Asset.shareIcon.image
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(Theme.Colors.Icon.theme)
        case .external: return Asset.externalLinkIcon.image
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(Theme.Colors.Icon.theme)
        case .noAccessory, .toggle: return nil
        }
    }
}
