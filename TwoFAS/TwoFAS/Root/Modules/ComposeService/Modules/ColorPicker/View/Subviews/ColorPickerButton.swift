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

final class ColorPickerButton: UIView {
    var userAction: ((TintColor) -> Void)?
    
    private let size: CGFloat = 68
    private let circleMargin: CGFloat = 6
    private let circleSize: CGFloat = 56
    private let animDuration = Theme.Animations.Timing.quick
    private var currentColor: TintColor?
    
    private lazy var circle: UIView = {
        let c = UIView()
        let size: CGFloat = circleSize
        let shape = CAShapeLayer()
        let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: circleSize, height: circleSize)))
        shape.path = path.cgPath
        c.layer.mask = shape
        return c
    }()
    private let ring = UIView()
    private let ringMaskContainer = UIView()
    private let ringMask = RingMask()
    
    private(set) var isActive = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(ring)
        ring.pinToParent()
        
        addSubview(circle, with: [
            circle.widthAnchor.constraint(equalToConstant: circleSize),
            circle.heightAnchor.constraint(equalToConstant: circleSize),
            circle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: circleMargin),
            circle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -circleMargin),
            circle.topAnchor.constraint(equalTo: topAnchor, constant: circleMargin),
            circle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -circleMargin)
        ])
        
        ringMaskContainer.addSubview(ringMask)
        ringMask.frame = CGRect(origin: .zero, size: CGSize(width: size, height: size))
        
        ring.mask = ringMaskContainer
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(gestureRecognizer)
        setActive(false, animated: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ringMaskContainer.frame = ring.frame
    }
    
    func set(color: TintColor) {
        currentColor = color
        circle.backgroundColor = color.color
        ring.backgroundColor = color.color
    }
    
    func setActive(_ active: Bool, animated: Bool) {
        guard active != isActive else { return }
        let animationDuration: TimeInterval = animated ? animDuration : 0
        if active {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut) {
                self.ringMask.transform = self.ringMask.transform.scaledBy(x: 4, y: 4)
                self.ringMask.alpha = 1
            }
        } else {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut) {
                self.ringMask.transform = self.ringMask.transform.scaledBy(x: 0.25, y: 0.25)
                self.ringMask.alpha = 0
            }
        }
        isActive = active
    }
    
    override var intrinsicContentSize: CGSize { CGSize(width: size, height: size) }
    
    @objc(didTap)
    private func didTap() {
        guard let currentColor else { return }
        userAction?(currentColor)
    }
}
