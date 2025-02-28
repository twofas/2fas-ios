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

final class IconSelectorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "IconSelectorCollectionViewCell"
    static let dimension: CGFloat = 65
    static let labelHeight: CGFloat = 20
    
    private static let maskAdditionalSize: CGFloat = 6
    
    private let animDuration: TimeInterval = 0.2
    private var lastIsSelectedValue = true
    
    private let labelContainer = UIView()
    private let label: UILabel = {
        let l = UILabel()
        l.textColor = Theme.Colors.Text.main
        l.font = Theme.Fonts.sectionHeader
        l.textAlignment = .center
        l.numberOfLines = 1
        l.minimumScaleFactor = 0.9
        l.adjustsFontSizeToFitWidth = true
        l.allowsDefaultTighteningForTruncation = true
        l.lineBreakMode = .byTruncatingTail
        return l
    }()
    
    override var isSelected: Bool {
        didSet {
            setSelected(isSelected, animated: true)
        }
    }
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .center
        return iv
    }()
    
    private let circle = CircleShape()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        contentView.backgroundColor = Theme.Colors.Fill.System.first
        backgroundColor = Theme.Colors.Fill.System.first
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        contentView.addSubview(labelContainer, with: [
            labelContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            labelContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            labelContainer.widthAnchor.constraint(equalToConstant: IconSelectorCollectionViewCell.dimension),
            labelContainer.heightAnchor.constraint(equalToConstant: IconSelectorCollectionViewCell.labelHeight),
            labelContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        labelContainer.addSubview(label, with: [
            label.topAnchor.constraint(equalTo: labelContainer.topAnchor),
            label.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor),
            label.widthAnchor.constraint(equalTo: labelContainer.widthAnchor),
            label.bottomAnchor.constraint(lessThanOrEqualTo: labelContainer.bottomAnchor)
        ])
        
        setSelected(false, animated: false)
        
        contentView.addSubview(iconView, with: [
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconView.heightAnchor.constraint(equalToConstant: IconSelectorCollectionViewCell.dimension),
            iconView.widthAnchor.constraint(equalToConstant: IconSelectorCollectionViewCell.dimension),
            iconView.bottomAnchor.constraint(
                equalTo: labelContainer.topAnchor, constant: -Theme.Metrics.standardSpacing
            )
        ])
        
        contentView.addSubview(circle, with: [
            circle.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            circle.centerYAnchor.constraint(equalTo: iconView.centerYAnchor)
        ])
    }
    
    func setIcon(_ icon: UIImage, serviceName: String, showTitle: Bool) {
        iconView.image = icon
        accessibilityLabel = serviceName
        
        if showTitle {
            label.text = serviceName
            label.isHidden = false
        } else {
            label.text = nil
            label.isHidden = true
        }
    }
    
    func setSelected(_ selected: Bool, animated: Bool) {
        guard selected != lastIsSelectedValue else { return }
        let animationDuration: TimeInterval = animated ? animDuration : 0
        if selected {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut) {
                self.circle.transform = self.circle.transform.scaledBy(x: 2, y: 2)
                self.circle.alpha = 1
                self.label.font = Theme.Fonts.warning
            }
        } else {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseIn) {
                self.circle.transform = self.circle.transform.scaledBy(x: 0.5, y: 0.5)
                self.circle.alpha = 0
                self.label.font = Theme.Fonts.sectionHeader
            }
        }
        lastIsSelectedValue = selected
    }
}

private final class CircleShape: UIView {
    private let dimension: CGFloat = 65
    
    private let lineWidth: CGFloat = 2
    override static var layerClass: AnyClass { CAShapeLayer.self }
    private var shapeLayer: CAShapeLayer { self.layer as! CAShapeLayer }
    
    override func layoutSubviews() {
        backgroundColor = .clear
        let center = CGPoint(x: dimension / 2.0, y: dimension / 2.0)
        let circle = UIBezierPath(
            arcCenter: center,
            radius: dimension / 2.0,
            startAngle: -CGFloat.pi / 2.0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true
        )
        shapeLayer.path = circle.cgPath
        shapeLayer.strokeColor = Theme.Colors.Fill.theme.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .square
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        super.layoutSubviews()
    }
    
    override var intrinsicContentSize: CGSize { CGSize(width: dimension, height: dimension) }
}
