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

final class TokensNextTokenLabel: UILabel {
    init() {
        super.init(frame: CGRect.zero)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        adjustsFontForContentSizeCategory = true
        numberOfLines = 1
        textColor = AppColor.labelsPrimary.uiColor
        setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        setContentHuggingPriority(.defaultLow - 1, for: .vertical)
    }
    
    func setKind(_ kind: TokensCellKind) {
        switch kind {
        case .compact:
            font = TextStyle.smallToken.uiFont()
        case .normal:
            font = TextStyle.smallToken.uiFont()
        default:
            break
        }
    }
}
