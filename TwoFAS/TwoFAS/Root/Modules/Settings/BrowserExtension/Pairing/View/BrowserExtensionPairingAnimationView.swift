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

final class BrowserExtensionPairingAnimationView: UIView {
    private let backgroundOval0Image = Asset.pairingBackgroundOval1.image
    private let backgroundOval1Image = Asset.pairingBackgroundOval2.image
    
    private let size: CGFloat = 500
    private let container = UIView()
    private let animations: [ImageContainer] = [
        .init(image: Asset.pairingOval0.image, offset: .zero, rotationSpeed: 5),
        .init(image: Asset.pairingOval1.image, offset: CGPoint(x: 55, y: 55), rotationSpeed: 2),
        .init(image: Asset.pairingOval2.image, offset: CGPoint(x: 0, y: 140), rotationSpeed: 0.9),
        .init(image: Asset.pairingOval3.image, offset: CGPoint(x: 108, y: 75), rotationSpeed: 0.9),
        .init(image: Asset.pairingOval3.image, offset: CGPoint(x: -168, y: -168), rotationSpeed: 0.9)
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(container, with: [
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: size),
            container.heightAnchor.constraint(equalToConstant: size)
        ])
        let center = CGPoint(x: size / 2.0, y: size / 2.0)
        
        let bgImg0 = UIImageView(image: backgroundOval0Image)
        let bgImg1 = UIImageView(image: backgroundOval1Image)
        bgImg0.tintColor = Theme.Colors.Line.secondaryLine
        bgImg1.tintColor = Theme.Colors.Line.secondaryLine
        
        container.addSubview(bgImg0)
        bgImg0.center = center
        
        container.addSubview(bgImg1)
        bgImg1.center = center
        
        container.backgroundColor = Theme.Colors.Fill.background
        
        animations.forEach {
            container.addSubview($0)
            $0.center = center
        }
    }
    
    func start() {
        animations.forEach { $0.start() }
    }
    
    func clear() {
        animations.forEach { $0.clear() }
    }
}

private final class ImageContainer: UIView {
    private let image: UIImage
    private let offset: CGPoint
    private let rotationSpeed: CGFloat
    
    private let kRotationAnimationKey = "centeredRotationAnimation"
    
    init(image: UIImage, offset: CGPoint, rotationSpeed: Double) {
        self.image = image
        self.offset = offset
        self.rotationSpeed = rotationSpeed
        super.init(frame: CGRect(origin: .zero, size: image.size))
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.image = UIImage()
        self.offset = .zero
        self.rotationSpeed = 0
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let imageView = UIImageView(image: image)
        imageView.tintColor = Theme.Colors.Fill.theme
        let size = image.size
        addSubview(imageView)
        imageView.center = CGPoint(x: round(size.width / 2.0) + offset.x, y: round(size.height / 2.0) + offset.y)
        clipsToBounds = false
    }
    
    func start() {
        if layer.animation(forKey: kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * 2.0
            rotationAnimation.duration = (Double.pi * 2.0) / rotationSpeed
            rotationAnimation.repeatCount = Float.infinity
            
            layer.add(rotationAnimation, forKey: kRotationAnimationKey)
        }
    }
    
    func clear() {
        if layer.animation(forKey: kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: kRotationAnimationKey)
        }
    }
}
