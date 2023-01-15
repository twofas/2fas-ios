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

public enum SpinnerViewLocalizations {
    public static var voiceOverSpinner: String?
}

final class SpinnerView: UIView {
    private let color = ThemeColor.theme
    private let sizePrimary: CGFloat = 40
    private let sizeSecondary: CGFloat = 12
    private let distance: CGFloat = 20
    private let sizeOuter: CGFloat = 100
    private let primaryAnimKey = "SpinnerView.primaryAnimKey"
    private let secondaryAnimKey = "SpinnerView.secondaryAnimKey"
    
    private lazy var primaryShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.borderWidth = 0
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = ThemeMetrics.lineWidth * 4
        return shapeLayer
    }()
    
    private lazy var secondaryShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.borderWidth = 0
        return shapeLayer
    }()

    private(set) var isAnimating = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    private func commonInit() {
        layer.addSublayer(primaryShapeLayer)
        layer.addSublayer(secondaryShapeLayer)
        
        isAccessibilityElement = true
        accessibilityLabel = SpinnerViewLocalizations.voiceOverSpinner
        
        tintColor = color
        secondaryShapeLayer.fillColor = color.cgColor

        let primaryPosition = round((sizeOuter - sizePrimary) / 2.0)
        primaryShapeLayer.frame = CGRect(
            origin: CGPoint(x: primaryPosition, y: primaryPosition),
            size: CGSize(width: sizePrimary, height: sizePrimary)
        )
        primaryShapeLayer.path = createPrimaryPath().cgPath
        
        let size = sizePrimary + 2 * distance
        let secondaryPosition = round((sizeOuter - size) / 2.0)
        secondaryShapeLayer.frame = CGRect(
            origin: CGPoint(x: secondaryPosition, y: secondaryPosition),
            size: CGSize(width: size, height: size)
        )
        secondaryShapeLayer.path = createSecondaryPath().cgPath
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        primaryShapeLayer.strokeColor = tintColor.cgColor
        secondaryShapeLayer.strokeColor = tintColor.cgColor
    }
    
    private func createPrimaryPath() -> UIBezierPath {
        let doublePi = 2.0 * Double.pi
        let startAngle = CGFloat(0.75 * doublePi)
        let endAngle: CGFloat = startAngle + CGFloat(0.9 * doublePi)
        
        let width = sizePrimary
        return UIBezierPath(
            arcCenter: CGPoint(x: width / 2.0, y: width / 2.0),
            radius: width / 2.0,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
    }
    
    private func createSecondaryPath() -> UIBezierPath {
        UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: sizeSecondary, height: sizeSecondary))
    }
    
    func startAnimating() {
        if isAnimating {
            return
        }
        
        isAnimating = true
        addAnimation()
        isHidden = false
    }
    
    func stopAnimating() {
        guard isAnimating else { return }
        
        removeAnimation()
        isAnimating = false
    }
    
    private func addAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue = 2 * Double.pi
        animation.timingFunction = .init(name: .linear)
        animation.duration = 1.0
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        primaryShapeLayer.add(animation, forKey: primaryAnimKey)
        
        let animation2 = CABasicAnimation(keyPath: "transform.rotation")
        animation2.toValue = 2 * Double.pi
        animation2.timingFunction = .init(name: .linear)
        animation2.duration = 4.0
        animation2.repeatCount = .infinity
        animation2.isRemovedOnCompletion = false
        secondaryShapeLayer.add(animation2, forKey: secondaryAnimKey)
    }
    
    private func removeAnimation() {
        primaryShapeLayer.removeAnimation(forKey: primaryAnimKey)
        secondaryShapeLayer.removeAnimation(forKey: secondaryAnimKey)
    }
    
    override var intrinsicContentSize: CGSize { CGSize(width: sizeOuter, height: sizeOuter) }
}
