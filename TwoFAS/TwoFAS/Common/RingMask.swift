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

final class RingMask: UIView {
    override static var layerClass: AnyClass { CAShapeLayer.self }
    
    private var shapeLayer: CAShapeLayer { self.layer as! CAShapeLayer }
    
    private var innerDimension: CGFloat = 62
    private var outerDimension: CGFloat = 68
    
    convenience init(innerDimension: CGFloat, outerDimension: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: outerDimension, height: outerDimension))
        self.innerDimension = innerDimension
        self.outerDimension = outerDimension
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        let biggerPath = UIBezierPath(
            ovalIn: CGRect(
                origin: .zero,
                size: CGSize(width: outerDimension, height: outerDimension)
            )
        )
        let origin = (outerDimension - innerDimension) / 2.0
        let smallerPath = UIBezierPath(
            ovalIn: CGRect(
                origin: .init(x: origin, y: origin),
                size: CGSize(width: innerDimension, height: innerDimension)
            )
        )
        smallerPath.append(biggerPath)
        smallerPath.usesEvenOddFillRule = true
        shapeLayer.path = smallerPath.cgPath
        shapeLayer.fillRule = .evenOdd
        shapeLayer.fillColor = UIColor.white.cgColor
        
        super.layoutSubviews()
    }
}
