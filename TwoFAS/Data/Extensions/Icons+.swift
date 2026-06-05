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
import SwiftUI
#if os(iOS)
import Content
import Common
#elseif os(watchOS)
import ContentWatch
import CommonWatch
#endif

#if os(iOS)
public extension ServiceIconDefinition {
    var icon: UIImage {
        switch iconType {
        case .brand:
            return ServiceIcon.for(iconTypeID: iconTypeID)
        case .label:
            return LabelImageRenderer.render(
                with: labelTitle,
                tintColor: labelColor
            )
        }
    }
    
    var iconDetails: IconDetails {
        switch iconType {
        case .brand:
            IconDetails.brand(iconTypeID: iconTypeID)
        case .label:
            IconDetails.label(title: labelTitle, TintColor: labelColor)
        }
    }
}

extension IconDetails {
    public var iconImage: UIImage? {
        guard case .brand(let iconTypeID) = self else { return nil }
        return ServiceIcon.for(iconTypeID: iconTypeID)
    }
}

extension ServiceData: @retroactive ServiceIconDefinition {}
extension WidgetService: @retroactive ServiceIconDefinition {}

#endif

public extension IconDescription {
    var icon: UIImage {
        ServiceIcon.for(iconTypeID: iconTypeID)
    }
}
