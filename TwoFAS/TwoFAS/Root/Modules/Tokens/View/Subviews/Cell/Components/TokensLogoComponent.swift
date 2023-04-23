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

final class TokensLogoComponent: UIView {
    private let imageView = UIImageView()
    private let labelRenderer = LabelRenderer()
    private var currentSize: TokensLogoSize = .normal
    
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
        
        addSubview(labelRenderer)
        labelRenderer.pinToParent()
    }
    
    func configure(with logoType: LogoType, size: TokensLogoSize) {
        let refresh = size != currentSize
        currentSize = size
        
        switch logoType {
        case .image(let image):
            imageView.image = image
            
            imageView.isHidden = false
            labelRenderer.isHidden = true
        case .label(let text, let tintColor):
            labelRenderer.setColor(tintColor, animated: false)
            labelRenderer.setText(text)
            labelRenderer.setSize(size)
            
            imageView.isHidden = true
            labelRenderer.isHidden = false
        }
        
        if refresh {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let size = currentSize.dimension
        return CGSize(width: size, height: size)
    }
}
