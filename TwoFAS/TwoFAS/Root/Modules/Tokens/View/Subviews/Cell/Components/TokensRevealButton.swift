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
    static let sizeNormal: CGFloat = 34
    static let sizeCompact: CGFloat = 32
    private let imageValue = IconName.eyeFill
    
    private var kind: TokensCellKind = .normal
    
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
        isAccessibilityElement = true
        accessibilityValue = T.Tokens.showServiceKey
        tintColor = AppColor.labelsPrimary.uiColor
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
        
        self.kind = kind
        invalidateIntrinsicContentSize()
    }
    
    private func setupCompact() {
        let config = UIImage.SymbolConfiguration(font: TextStyle.footnote.uiFont())
        let imageNormal = UIImage(
            icon: imageValue,
            withConfiguration: config
        )!

        setImage(imageNormal, for: .normal)

        applyRoundedCorners(withBackgroundColor: AppColor.fillsTertiary.uiColor, cornerRadius: Self.sizeCompact / 2)
    }

    private func setupNormal() {
        adjustsImageSizeForAccessibilityContentSizeCategory = true
        let config = UIImage.SymbolConfiguration(font: TextStyle.subheadline.uiFont())
        let imageNormal = UIImage(
            icon: imageValue,
            withConfiguration: config
        )!
        
        setImage(imageNormal, for: .normal)

        applyRoundedCorners(withBackgroundColor: AppColor.fillsTertiary.uiColor, cornerRadius: Self.sizeNormal / 2)
    }
    
    override var intrinsicContentSize: CGSize {
        let value: CGFloat = {
            if kind == .compact {
                return Self.sizeCompact
            }
            return Self.sizeNormal
        }()
        return .init(width: value, height: value)
    }
}
