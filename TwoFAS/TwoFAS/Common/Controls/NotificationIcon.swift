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
import PKHUD
import Common

final class NotificationIcon: UIView, PKHUDAnimating {
    enum Kind {
        case success
        case failure
        
        var path: UIBezierPath {
            let path = UIBezierPath()
            switch self {
            case .success:
                path.move(to: CGPoint(x: 115.35, y: 0))
                path.addLine(to: CGPoint(x: 42.4, y: 71))
                path.addLine(to: CGPoint(x: 14.44, y: 44.29))
                path.addLine(to: CGPoint(x: 0, y: 59))
                path.addLine(to: CGPoint(x: 41.97, y: 100))
                path.addLine(to: CGPoint(x: 42.15, y: 100))
                path.addLine(to: CGPoint(x: 130, y: 14.4))
                path.addLine(to: CGPoint(x: 115.35, y: 0))
                path.close()
            case .failure:
                path.move(to: CGPoint(x: 50.892, y: 66.768))
                path.addLine(to: CGPoint(x: 15.66, y: 102))
                path.addLine(to: CGPoint(x: 0, y: 86.34))
                path.addLine(to: CGPoint(x: 35.232, y: 51.108))
                path.addLine(to: CGPoint(x: 0, y: 15.877))
                path.addLine(to: CGPoint(x: 15.66, y: 0.217))
                path.addLine(to: CGPoint(x: 50.892, y: 35.449))
                path.addLine(to: CGPoint(x: 86.123, y: 0.217))
                path.addLine(to: CGPoint(x: 101.783, y: 15.877))
                path.addLine(to: CGPoint(x: 66.551, y: 51.108))
                path.addLine(to: CGPoint(x: 101.783, y: 86.34))
                path.addLine(to: CGPoint(x: 86.123, y: 102))
                path.addLine(to: CGPoint(x: 50.892, y: 66.768))
                path.close()
                path.move(to: CGPoint(x: 50.892, y: 66.768))
            }
            return path
        }
        
        var scale: CGFloat {
            switch self {
            case .success: return 0.5
            case .failure: return 0.5
            }
        }
    }
    
    static private let iconSize = CGSize(width: 130, height: 100)
    private let size = CGSize(width: 215.0, height: 170.0)
    private let strokeAnimKey = "checkmarkStrokeAnimation"
    private let fillAnimationKey = "fillAnimation"
    
    private var kind: Kind = .success
    private var iconShapeLayer = CAShapeLayer()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme.Colors.Text.light
        label.font = Theme.Fonts.Controls.title
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let shapeContainerView = UIView(frame: CGRect(origin: CGPoint.zero, size: iconSize))
    
    private func createShape() {
        let width = NotificationIcon.iconSize.width
        let height = NotificationIcon.iconSize.height
        
        let path = kind.path
        
        path.usesEvenOddFillRule = true
        path.fill()
        
        var affineTransform = CGAffineTransform(scaleX: kind.scale, y: kind.scale)
        let transformedPath = path.cgPath.copy(using: &affineTransform)
        
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: 0, y: 0, width: width * kind.scale, height: height * kind.scale)
        layer.path = transformedPath
        
        layer.fillMode = .forwards
        layer.lineCap = .square
        layer.lineJoin = .bevel
        
        layer.fillColor = Theme.Colors.Fill.notification.cgColor
        layer.strokeColor = Theme.Colors.Fill.notification.cgColor
        layer.lineWidth = 1
        
        iconShapeLayer = layer
    }
    
    private let stack = UIStackView()
    private let spacing = Theme.Metrics.standardSpacing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(title: String, iconKind: Kind) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: size.width, height: 1000)))
        self.kind = iconKind
        
        createShape()
        
        titleLabel.text = title
        
        shapeContainerView.layer.addSublayer(iconShapeLayer)
        
        let currentSize = iconShapeLayer.frame.size
        let totalSize = shapeContainerView.frame.size
        iconShapeLayer.position = CGPoint(
            x: round((totalSize.width - 2 * currentSize.width)) + 5.0,
            y: round((totalSize.height + currentSize.height / 2.0) / 2.0)
        )
        
        stack.addArrangedSubviews([shapeContainerView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = spacing
        addSubview(stack, with: [
            stack.topAnchor.constraint(equalTo: topAnchor, constant: spacing),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2 * spacing),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
            stack.widthAnchor.constraint(equalToConstant: size.width - 2 * spacing)
        ])
        
        let size = stack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        frame.size = CGSize(
            width: frame.size.width,
            height: size.height + 3 * spacing + totalSize.height + spacing
        ) // stack height but only text + spacing + icon + stack spacing
    }
    
    func startAnimation() {
        let checkmarkStrokeAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        checkmarkStrokeAnimation.values = [0, 1]
        checkmarkStrokeAnimation.keyTimes = [0, 1]
        checkmarkStrokeAnimation.duration = 0.35
        
        iconShapeLayer.add(checkmarkStrokeAnimation, forKey: strokeAnimKey)
        
        iconShapeLayer.fillColor = Theme.Colors.Text.dark.cgColor
        
        let fillAnimation = CAKeyframeAnimation(keyPath: "fillColor")
        fillAnimation.values = [Theme.Colors.Text.dark.cgColor, Theme.Colors.Text.light.cgColor]
        fillAnimation.keyTimes = [0, 1]
        fillAnimation.duration = 0.7
        fillAnimation.fillMode = .both
        fillAnimation.isRemovedOnCompletion = false
        
        iconShapeLayer.add(fillAnimation, forKey: fillAnimationKey)
    }
    
    func stopAnimation() {
        iconShapeLayer.removeAnimation(forKey: strokeAnimKey)
        iconShapeLayer.removeAnimation(forKey: fillAnimationKey)
        iconShapeLayer.fillColor = Theme.Colors.Text.light.cgColor
    }
}
