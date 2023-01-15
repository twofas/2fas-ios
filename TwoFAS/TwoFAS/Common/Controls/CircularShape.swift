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

final class CircularShape: UIView {
    private let angleOffset = -CGFloat.pi / 2.0
    private var shape: CAShapeLayer!
    private var period: Int = 0
    private var previousValue: Int = -100
    
    private enum AnimKeyPath: String {
        case color = "strokeColor"
        case end = "strokeEnd"
    }
    
    private enum AnimKey: String {
        case color = "animatingColor"
        case end = "animatingShape"
    }
    
    var animationDuration: TimeInterval = 0.99
    var lineWidth: CGFloat = 1 {
        didSet {
            shape.lineWidth = lineWidth
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = Theme.Colors.Fill.background
        isUserInteractionEnabled = false
        
        shape = CAShapeLayer()
        shape.fillColor = Theme.Colors.Fill.background.cgColor
        shape.strokeColor = UIColor.black.cgColor
        shape.lineWidth = lineWidth
        shape.lineCap = .square
        layer.addSublayer(shape)
        configurePath()
    }
    
    func setClearBackground() {
        backgroundColor = UIColor.clear
        shape.backgroundColor = UIColor.clear.cgColor
        shape.fillColor = UIColor.clear.cgColor
        isOpaque = false
    }
    
    func setLineColor(_ color: UIColor, animated: Bool) {
        if shape.animation(forKey: AnimKey.color.rawValue) != nil {
            shape.removeAnimation(forKey: AnimKey.color.rawValue)
        }
        
        if animated {
            let animation = CABasicAnimation(keyPath: AnimKeyPath.color.rawValue)
            animation.toValue = color.cgColor
            animation.duration = Theme.Animations.Timing.show
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            animation.fillMode = CAMediaTimingFillMode.both
            animation.isRemovedOnCompletion = false
            shape.add(animation, forKey: AnimKey.color.rawValue)
        } else {
            shape.strokeColor = color.cgColor
        }
    }
    
    func setPeriod(_ period: Int) {
        self.period = period
    }
    
    func setValue(_ value: Int, animated: Bool) {
        guard value != previousValue else { return }
        previousValue = value
        
        let valueNormalized = normalized(value)
        
        var fromValue: CGFloat = 0
        if let currentAnimation = shape.animation(forKey: AnimKey.end.rawValue) as? CABasicAnimation,
            let value = currentAnimation.toValue as? CGFloat {
            fromValue = value
            shape.removeAnimation(forKey: AnimKey.end.rawValue)
        } else {
            fromValue = shape.strokeEnd
        }
        
        let animation = CABasicAnimation(keyPath: AnimKeyPath.end.rawValue)
        animation.fromValue = fromValue
        animation.toValue = valueNormalized
        
        animation.duration = selectAnimDuration(value: value, animated: animated)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.fillMode = CAMediaTimingFillMode.both
        animation.isRemovedOnCompletion = false
        shape.add(animation, forKey: AnimKey.end.rawValue)
    }
    
    var progress: Int {
        get {
            Int(shape.strokeEnd * 100)
        }
        set {
            shape.strokeEnd = normalized(newValue)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configurePath()
    }
    
    private func normalized(_ value: Int) -> CGFloat {
        let value = value - 2
        let newValue: Int
        let maxValue = period - 2
        
        if value > maxValue {
            
            newValue = maxValue
        } else if value < 0 {
            
            newValue = 0
        } else {
            
            newValue = value
        }
        
        let valueNormalized = CGFloat(newValue) / CGFloat(maxValue)
        
        return valueNormalized
    }
    
    private func selectAnimDuration(value: Int, animated: Bool) -> TimeInterval {
        var animDuration: TimeInterval = animationDuration
        
        if value == 0 {
            animDuration = animationDuration / 4.0
        }
        
        if !animated {
            animDuration = 0
        }
        
        return animDuration
    }
    
    private func configurePath() {
        let rectSize = bounds.size
        let smallerSize = min(rectSize.width, rectSize.height)
        let sideLength = smallerSize
        let radius = (sideLength - lineWidth) / 2.0
        let center = CGPoint(x: rectSize.width / 2.0, y: rectSize.height / 2.0)
        
        let circle = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: angleOffset,
            endAngle: 2 * CGFloat.pi + angleOffset,
            clockwise: true
        )
        shape.path = circle.cgPath
        shape.strokeEnd = 0
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            shape.fillColor = Theme.Colors.Fill.background.cgColor
        }
    }
}
