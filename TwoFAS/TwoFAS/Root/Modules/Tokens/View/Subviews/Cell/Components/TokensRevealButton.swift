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

final class TokensRevealButton: UIButton {
    private let imageNormalValue = "eye"
    private let imageActiveValue = "eye.fill"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        imageView?.contentMode = .scaleAspectFit
        tintColor = ThemeColor.secondary
    }
    
    func setKind(_ kind: TokensCellKind) {
        switch kind {
        case .compact:
            setupCompact()
        case .normal:
            setupNormal()
        default:
            break
        }
    }
    
    private func setupCompact() {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .medium)
        let imageNormal = UIImage(
            systemName: imageNormalValue,
            withConfiguration: config
        )!
        
        let imageActive = UIImage(
            systemName: imageActiveValue,
            withConfiguration: config
        )!
        setImage(imageNormal, for: .normal)
        setImage(imageActive, for: .highlighted)
    }
    
    private func setupNormal() {
        adjustsImageSizeForAccessibilityContentSizeCategory = true
        let config = UIImage.SymbolConfiguration(textStyle: .body)
        let imageNormal = UIImage(
            systemName: imageNormalValue,
            withConfiguration: config
        )!
        
        let imageActive = UIImage(
            systemName: imageActiveValue,
            withConfiguration: config
        )!
        setImage(imageNormal, for: .normal)
        setImage(imageActive, for: .highlighted)
    }
}
