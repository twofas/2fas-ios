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

final class RefreshTokenCounter: UIView {
    var didAnimate: Callback?
    
    private let image = RefreshImage()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(image)
        image.pinToParent()
        image.didAnimate = { [weak self] in self?.didAnimate?() }
        isAccessibilityElement = true
        accessibilityValue = T.Tokens.showServiceKey
    }
    
    func rotate() {
        image.rotate()
    }
    
    func lock() {
        image.lock()
    }
    
    func unlock() {
        image.unlock()
    }
    
    func adjustsImageSizeForAccessibilityContentSizeCategory(_ value: Bool) {
        image.adjustsImageSizeForAccessibilityContentSizeCategory(value)
    }
}

private extension RefreshTokenCounter {
    final class RefreshImage: UIView {
        var didAnimate: Callback?
        
        private let image = UIImageView(
            image: Asset.refreshTokenCounter.image.withRenderingMode(.alwaysTemplate)
        )
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            addSubview(image)
            unlock()
        }
        
        func adjustsImageSizeForAccessibilityContentSizeCategory(_ value: Bool) {
            image.adjustsImageSizeForAccessibilityContentSizeCategory = value
        }
        
        func rotate() {
            UIView.animate(
                withDuration: Theme.Animations.Timing.quick,
                delay: 0,
                options: [.curveEaseIn, .beginFromCurrentState],
                animations: { self.image.transform = CGAffineTransform(rotationAngle: Double.pi) },
                completion: { _ in
                UIView.animate(
                    withDuration: Theme.Animations.Timing.quick,
                    delay: 0,
                    options: [.curveEaseOut, .beginFromCurrentState],
                    animations: { self.image.transform = CGAffineTransform(rotationAngle: 2 * Double.pi) },
                    completion: { _ in self.didAnimate?() }
                )}
            )
        }
        
        func lock() {
            image.tintColor = Theme.Colors.Controls.inactive
        }
        
        func unlock() {
            image.tintColor = Theme.Colors.Controls.active
        }
        
        override var intrinsicContentSize: CGSize {
            image.bounds.size
        }
    }
}
