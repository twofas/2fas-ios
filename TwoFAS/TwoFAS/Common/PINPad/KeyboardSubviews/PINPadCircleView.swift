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

final class PINPadCircleView: UIView {
    private let dimension: CGFloat
    
    enum CircleType {
        case empty
        case full
    }
    
    private let typeOfCircle: CircleType
    private let borderWidth: CGFloat
    
    init(typeOfCircle: CircleType, dimension: CGFloat, borderWidth: CGFloat) {
    
        self.typeOfCircle = typeOfCircle
        self.dimension = dimension
        self.borderWidth = borderWidth
        
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
        contentMode = .redraw
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let emptyCircleRect = rect.insetBy(dx: 2 * borderWidth, dy: 2 * borderWidth)
        
        let themeColor = Theme.Colors.Controls.active.cgColor
        let emptyCircleColor = Theme.Colors.Controls.empty.cgColor
        let borderColor = Theme.Colors.Controls.inactive.cgColor
        
        if typeOfCircle == .empty {
           
            context.setFillColor(borderColor)
            context.addEllipse(in: rect)
            context.fillPath()
            
            context.setFillColor(emptyCircleColor)
            context.addEllipse(in: emptyCircleRect)
            context.fillPath()
        } else {
            
            context.setFillColor(themeColor)
            context.addEllipse(in: rect)
            context.fillPath()
        }
    }
    
    override var intrinsicContentSize: CGSize { CGSize(width: dimension, height: dimension) }
}
