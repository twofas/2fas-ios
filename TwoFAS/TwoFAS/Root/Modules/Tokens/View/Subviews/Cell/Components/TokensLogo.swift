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

final class TokensLogo: UIView {
    private let imageView = UIImageView()
    private let labelRenderer = LabelRenderer()
    private var currentKind: TokensCellKind = .normal
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(imageView)
        imageView.contentMode = .center
        imageView.pinToParent()
        setContentHuggingPriority(.defaultHigh + 2, for: .horizontal)
        setContentHuggingPriority(.defaultLow - 2, for: .vertical)
        
        addSubview(labelRenderer)
        labelRenderer.pinToParentCenter()
    }
    
    func setKind(_ kind: TokensCellKind) {
        let refresh = kind != currentKind
        currentKind = kind
        
        labelRenderer.setKind(kind)
        
        if refresh {
            invalidateIntrinsicContentSize()
        }
    }
    
    func configure(with logoType: LogoType) {
        switch logoType {
        case .image(let image):
            if currentKind == .compact || currentKind == .edit {
                let img = image.preparingThumbnail(
                    of: CGSize(width: currentKind.iconDimension, height: currentKind.iconDimension)
                )
                imageView.image = img
            } else {
                imageView.image = image
            }
            
            imageView.isHidden = false
            labelRenderer.isHidden = true
        case .label(let text, let tintColor):
            labelRenderer.setColor(tintColor, animated: false)
            labelRenderer.setText(text)
            
            imageView.isHidden = true
            labelRenderer.isHidden = false
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let size = currentKind.iconDimension
        return CGSize(width: size, height: size)
    }
}
