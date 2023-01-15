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

enum MainContainerTextStyling {
    case content
    case boldContent
    case marked
    case title
    case boldTitle
    case boldTitleOneLine
    case note
    case noteLight
    case titleDark
    case titleLight
    case contentDark
    case contentLight
    
    var value: Style<UILabel> {
        switch self {
        case .content: return MainContainerTextStyling.contentValue
        case .boldContent: return MainContainerTextStyling.boldContentValue
        case .marked: return MainContainerTextStyling.markedValue
        case .title: return MainContainerTextStyling.titleValue
        case .boldTitle: return MainContainerTextStyling.titleBoldValue
        case .boldTitleOneLine: return MainContainerTextStyling.titleBoldOneLineValue
        case .note: return MainContainerTextStyling.noteValue
        case .noteLight: return MainContainerTextStyling.noteLightValue
        case .titleDark: return MainContainerTextStyling.titleDarkValue
        case .titleLight: return MainContainerTextStyling.titleLightValue
        case .contentDark: return MainContainerTextStyling.contentDarkValue
        case .contentLight: return MainContainerTextStyling.contentLightValue
        }
    }
    private static let contentValue = Style<UILabel> {
        $0.font = Theme.Fonts.Text.content
        $0.textColor = Theme.Colors.Text.main
        $0.textAlignment = .center
        $0.lineBreakMode = .byWordWrapping
        $0.numberOfLines = 0
        $0.allowsDefaultTighteningForTruncation = true
        $0.minimumScaleFactor = 0.7
        $0.adjustsFontSizeToFitWidth = true
    }
    
    private static let boldContentValue = Style<UILabel> {
        $0.font = Theme.Fonts.Text.boldContent
    }
    
    private static let markedValue = Style<UILabel> {
        $0.textColor = Theme.Colors.Text.theme
    }
    
    private static let titleValue = Style<UILabel> {
        $0.font = Theme.Fonts.Text.title
    }
    
    private static let titleBoldValue = Style<UILabel> {
        $0.font = Theme.Fonts.Text.boldTitle
    }
    
    private static let titleBoldOneLineValue = Style<UILabel> {
        $0.font = Theme.Fonts.Text.boldTitle
        $0.textAlignment = .center
        $0.minimumScaleFactor = 0.3
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        $0.adjustsFontSizeToFitWidth = true
    }
    
    private static let noteValue = Style<UILabel> {
        $0.font = Theme.Fonts.Text.note
    }
    
    private static let noteLightValue = Style<UILabel> {
        $0.font = Theme.Fonts.Text.note
        $0.textColor = Theme.Colors.Text.light
    }
    
    private static let titleDarkValue = Style<UILabel> {
        $0.font = Theme.Fonts.Text.title
        $0.textColor = Theme.Colors.Text.dark
    }
    
    private static let titleLightValue = Style<UILabel> {
        $0.font = Theme.Fonts.Text.title
        $0.textColor = Theme.Colors.Text.light
    }
    
    private static let contentDarkValue = Style<UILabel> {
        $0.textColor = Theme.Colors.Text.dark
    }
    
    private static let contentLightValue = Style<UILabel> {
        $0.textColor = Theme.Colors.Text.dark
        $0.textColor = Theme.Colors.Text.light
    }
}
