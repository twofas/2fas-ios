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

enum MainContainerElementsStyling {
    static let pagingHeight: CGFloat = 20
    
    static let paging = Style<UILabel> {
        $0.font = Theme.Fonts.Text.note
        $0.textAlignment = .center
        $0.textColor = Theme.Colors.Text.subtitle
    }
    
    static let navigationButton = Style<UIButton> {
        $0.titleLabel?.font = Theme.Fonts.Text.content
        $0.setTitleColor(Theme.Colors.Text.theme, for: .normal)
        $0.setTitleColor(Theme.Colors.Text.themeHighlighted, for: .highlighted)
        $0.setTitleColor(Theme.Colors.Text.inactive, for: .disabled)
    }
    
    static let linkButton = Style<UIButton> {
        $0.titleLabel?.font = Theme.Fonts.Text.note
        $0.titleLabel?.numberOfLines = 0
        $0.titleLabel?.lineBreakMode = .byWordWrapping
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(Theme.Colors.Text.theme, for: .normal)
        $0.setTitleColor(Theme.Colors.Text.themeHighlighted, for: .highlighted)
        $0.setTitleColor(Theme.Colors.Text.inactive, for: .disabled)
    }
    
    static let input = Style<UITextField> {
        $0.font = Theme.Fonts.Form.rowInput
    }
}
