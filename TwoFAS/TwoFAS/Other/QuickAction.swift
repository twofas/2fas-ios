//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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
import Data

extension QuickAction {
    var title: String {
        switch self {
        case .backup: return T.Shortcuts.backupTitle
        case .support: return T.Shortcuts.supportTitle
        case .pair: return T.Shortcuts.pairTitle
        case .search: return T.Shortcuts.searchTitle
        }
    }

    var icon: IconName {
        switch self {
        case .backup: return .doc
        case .support: return .questionmarkCircle
        case .pair: return .plus
        case .search: return .magnifyingglass
        }
    }

    var shortcutItem: UIApplicationShortcutItem {
        UIApplicationShortcutItem(
            type: rawValue,
            localizedTitle: title,
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(systemImageName: icon.rawValue),
            userInfo: nil
        )
    }

    static var shortcutItems: [UIApplicationShortcutItem] {
        allCases.map { $0.shortcutItem }
    }
}
