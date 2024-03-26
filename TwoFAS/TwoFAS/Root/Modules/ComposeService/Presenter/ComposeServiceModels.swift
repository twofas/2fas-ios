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
import Common

struct ComposeServiceSection: TableViewSection {
    let title: String?
    var cells: [ComposeServiceSectionCell]
    
    init(title: String? = nil, cells: [ComposeServiceSectionCell]) {
        self.title = title
        self.cells = cells
    }
}

struct ComposeServiceSectionCell: Hashable {
    enum Kind: Hashable {
        case input(InputConfig)
        case privateKey(PrivateKeyConfig)
        case action(ActionConfig)
        case navigate(NavigationConfig)
        case icon(IconConfig)
    }
    
    struct InputConfig: Hashable {
        enum Kind: Hashable {
            case serviceName
            case additionalInfo
        }
        
        let kind: Kind
        let value: String?
    }
    
    struct PrivateKeyConfig: Hashable {
        enum PrivateKeyKind: Hashable {
            case empty
            case hidden
            case hiddenNonCopyable
        }

        enum PrivateKeyError: Hashable {
            case incorrect
            case tooShort
            case duplicated
        }
        
        let value: String?
        let privateKeyKind: PrivateKeyKind
        let error: PrivateKeyError?
    }
    
    struct ActionConfig: Hashable {
        enum Kind: Hashable {
            case delete
        }
        
        let kind: Kind
    }
    
    struct NavigationConfig: Hashable {
        enum Kind: Hashable {
            case advanced
            case brandIcon
            case label
            case badgeColor
            case browserExtension
            case category
        }
        
        enum AccessoryKind: Hashable {
            case badgeColor(TintColor)
            case label(String)
        }
        
        let kind: Kind
        let isEnabled: Bool
        let accessory: AccessoryKind?
    }
    
    struct IconConfig: Hashable {
        let kind: IconType
        let iconTypeID: IconTypeID
        let labelTitle: String
        let labelColor: TintColor
        let iconTypeName: IconTypeName
    }
    
    let kind: Kind
}
