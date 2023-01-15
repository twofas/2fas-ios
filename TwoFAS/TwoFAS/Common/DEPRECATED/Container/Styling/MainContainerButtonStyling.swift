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

enum MainContainerButtonStyling {
    case filled
    case text
    case filledOnDark
    case textOnDark
    case filledInDecoratedContainer
    case filledInDecoratedContainerLightText
    case borderOnly
    case textOnly
    
    var value: Style<LoadingContentButton> {
        switch self {
        case .filled: return Self.filledValue
        case .text: return Self.textValue
        case .filledOnDark: return Self.filledOnDarkValue
        case .textOnDark: return Self.textOnDarkValue
        case .filledInDecoratedContainer: return Self.filledInDecoratedContainerValue
        case .filledInDecoratedContainerLightText: return Self.filledInDecoratedContainerLightTextValue
        case .borderOnly: return Self.borderOnlyValue
        case .textOnly: return Self.textOnlyValue
        }
    }
    
    private static let filledValue = Style<LoadingContentButton> {
        $0.titleColor = Theme.Colors.Text.theme
        $0.highlightedTitleColor = Theme.Colors.Text.themeHighlighted
        $0.disabledTitleColor = Theme.Colors.Text.inactive
        $0.updateStyle()
    }
    
    private static let filledOnDarkValue = Style<LoadingContentButton> {
        $0.titleColor = Theme.Colors.Text.dark
        $0.highlightedTitleColor = Theme.Colors.Text.main
        $0.disabledTitleColor = Theme.Colors.Text.inactive
        $0.inactiveColor = Theme.Colors.Controls.highlighed
        $0.highlightedColor = Theme.Colors.Controls.highlighed
        $0.normalColor = Theme.Colors.Controls.light
        $0.updateStyle()
    }
    
    private static let textValue = Style<LoadingContentButton> {
        $0.titleColor = Theme.Colors.Text.theme
        $0.highlightedTitleColor = Theme.Colors.Text.themeHighlighted
        $0.disabledTitleColor = Theme.Colors.Text.inactive
        $0.updateStyle()
    }
    
    private static let textOnDarkValue = Style<LoadingContentButton> {
        $0.titleColor = Theme.Colors.Text.light
        $0.highlightedTitleColor = Theme.Colors.Text.main
        $0.disabledTitleColor = Theme.Colors.Text.inactive
        $0.updateStyle()
    }
    
    private static let filledInDecoratedContainerValue = Style<LoadingContentButton> {
        $0.titleColor = Theme.Colors.decoratedContainerButtonInverted
        $0.highlightedTitleColor = Theme.Colors.Text.main
        $0.disabledTitleColor = Theme.Colors.inactiveInverted
        $0.inactiveColor = Theme.Colors.inactiveMoreContrast
        $0.highlightedColor = Theme.Colors.Controls.highlighed
        $0.normalColor = Theme.Colors.decoratedContainerButton
        $0.updateStyle()
    }
    
    private static let filledInDecoratedContainerLightTextValue = Style<LoadingContentButton> {
        $0.titleColor = Theme.Colors.Text.light
        $0.highlightedTitleColor = Theme.Colors.decoratedContainerButtonInverted
        $0.disabledTitleColor = Theme.Colors.inactiveInverted
        $0.inactiveColor = Theme.Colors.inactiveMoreContrast
        $0.highlightedColor = Theme.Colors.Controls.highlighed
        $0.normalColor = Theme.Colors.Controls.active
        $0.updateStyle()
    }
    
    private static let borderOnlyValue = Style<LoadingContentButton> {
        $0.configure(style: .border(width: Theme.Metrics.lineWidth * 15), title: "")
        $0.titleColor = Theme.Colors.Text.theme
        $0.highlightedTitleColor = Theme.Colors.Text.themeHighlighted
        $0.disabledTitleColor = Theme.Colors.Text.inactive
        $0.inactiveColor = Theme.Colors.inactiveMoreContrast
        $0.highlightedColor = Theme.Colors.Controls.highlighed
        $0.normalColor = Theme.Colors.Controls.active
        $0.updateStyle()
    }
    
    private static let textOnlyValue = Style<LoadingContentButton> {
        $0.titleColor = Theme.Colors.Text.theme
        $0.highlightedTitleColor = Theme.Colors.Text.themeHighlighted
        $0.disabledTitleColor = Theme.Colors.Text.inactive
        $0.inactiveColor = .clear
        $0.highlightedColor = .clear
        $0.normalColor = .clear
        $0.updateStyle()
    }
}
