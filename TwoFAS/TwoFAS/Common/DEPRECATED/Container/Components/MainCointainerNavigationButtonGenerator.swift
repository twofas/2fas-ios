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

enum MainCointainerNavigationButtonGenerator {
    enum ButtonType {
        case skip
        case custom(title: String)
        case back
        
        var localizedDescription: String? {
            switch self {
            case .skip: return T.Commons.skip
            case .custom(let title): return title
            case .back: return nil
            }
        }
        
        var image: UIImage? {
            switch self {
            case .back: return Asset.iconArrowLeft.image
            default: return nil
            }
        }
    }
    
    static func generate(type: ButtonType) -> MainContainerActionButton {
        let button = MainContainerActionButton()
        if let image = type.image {
            let imageTemplate = image.withRenderingMode(.alwaysTemplate)
            button.tintColor = Theme.Colors.Line.theme
            button.setImage(imageTemplate, for: .normal)            
        }
        
        if let title = type.localizedDescription {
            button.setTitle(title, style: MainContainerElementsStyling.navigationButton)
        }
        
        return button
    }
}
