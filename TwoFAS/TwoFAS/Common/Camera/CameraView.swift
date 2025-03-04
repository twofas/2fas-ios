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

final class CameraView: UIView {
    private let topView = GradientView()
    private let bottomView = GradientView()
    
    private var topHeight: NSLayoutConstraint?
    private var bottomHeight: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(topView, with: [
            topView.topAnchor.constraint(equalTo: topAnchor),
            topView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        addSubview(bottomView, with: [
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        bottomView.invert()
        
        topHeight = topView.heightAnchor.constraint(equalToConstant: 0)
        bottomHeight = bottomView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            topHeight!,
            bottomHeight!
        ])
    }
    
    func setHeight(top: CGFloat, bottom: CGFloat) {
        topHeight?.constant = top
        bottomHeight?.constant = bottom
    }
}

private final class GradientView: UIView {
    private static let start: CGFloat = 0.55
    private static let end: CGFloat = 0.0
    private static let color: UIColor = .black
    
    private let colorsTop: [CGColor] = [
        GradientView.color.withAlphaComponent(GradientView.start).cgColor,
        GradientView.color.withAlphaComponent(GradientView.end).cgColor
    ]
    private let colorsBottom: [CGColor] = [
        GradientView.color.withAlphaComponent(GradientView.end).cgColor,
        GradientView.color.withAlphaComponent(GradientView.start).cgColor
    ]
    
    private let locationsTop: [NSNumber] = [0.2, 1.0]
    private let locationsBottom: [NSNumber] = [0.1, 1.0]
    
    override static var layerClass: AnyClass {
        CAGradientLayer.self
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
        guard let gradientLayer = layer as? CAGradientLayer else { return }
        gradientLayer.colors = colorsTop
        gradientLayer.locations = locationsTop
    }
    
    func invert() {
        guard let gradientLayer = layer as? CAGradientLayer else { return }
        gradientLayer.colors = colorsBottom
        gradientLayer.locations = locationsBottom
    }
}
