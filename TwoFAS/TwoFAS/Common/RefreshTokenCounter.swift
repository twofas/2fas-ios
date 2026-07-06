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

final class RefreshTokenCounter: UIView {
    var didAnimate: Callback?
    
    static let sizeNormal: CGFloat = 30
    static let sizeCompact: CGFloat = 28
    
    private var kind: TokensCellKind = .normal
    
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
        addSubview(image, with: [
            image.topAnchor.constraint(equalTo: topAnchor),
            image.bottomAnchor.constraint(equalTo: bottomAnchor),
            image.leadingAnchor.constraint(equalTo: leadingAnchor),
            image.trailingAnchor.constraint(equalTo: trailingAnchor),
            image.widthAnchor.constraint(equalTo: widthAnchor)
        ])

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
    
    func setKind(_ kind: TokensCellKind) {
        self.kind = kind
        invalidateIntrinsicContentSize()
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
            image.contentMode = .scaleAspectFit
            addSubview(image, with: [
                image.topAnchor.constraint(equalTo: topAnchor),
                image.bottomAnchor.constraint(equalTo: bottomAnchor),
                image.leadingAnchor.constraint(equalTo: leadingAnchor),
                image.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
            setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
            setContentHuggingPriority(.defaultHigh + 1, for: .vertical)
            setContentCompressionResistancePriority(.defaultHigh + 2, for: .horizontal)
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
            image.tintColor = AppColor.fillsTertiary.uiColor
        }
        
        func unlock() {
            image.tintColor = AppColor.accentsBrand.uiColor
        }
        
        override var intrinsicContentSize: CGSize {
            image.bounds.size
        }
    }
}
