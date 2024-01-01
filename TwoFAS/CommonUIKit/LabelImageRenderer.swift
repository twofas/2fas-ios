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

public enum LabelImageRenderer {
    public enum Variant {
        case standard
        case small
        
        var size: CGFloat {
            switch self {
            case .standard: return 40
            case .small: return 30
            }
        }
        
        var textSize: CGFloat {
            switch self {
            case .standard: return 13
            case .small: return 10
            }
        }
    }
    private static let size: CGFloat = 40
    private static let textSize: CGFloat = 13
    private static let textOffsetY: CGFloat = -1
    private static let textOffsetHeight: CGFloat = 2
    
    public static func render(
        with title: String,
        tintColor: TintColor,
        variant: Variant = .standard
    ) -> UIImage {
        let size = CGSize(width: variant.size, height: variant.size)
        let frame = CGRect(origin: .zero, size: size)
        let paths = LabelShapes.generate(for: size)
        let rectColor = ThemeColor.labelTextBackground
        let textColor = ThemeColor.labelText
        let renderer = UIGraphicsImageRenderer(bounds: frame)
        return renderer.image { _ in
            tintColor.color.setFill()
            paths.backgroundCircle.fill()
            
            rectColor.setFill()
            paths.upperRect.fill()
            
            attributedText(for: title, textSize: variant.textSize, textColor: textColor)
                .draw(
                    with: CGRect(
                        x: 0,
                        y: variant.textSize + textOffsetY,
                        width: variant.size,
                        height: variant.textSize + textOffsetHeight
                    ),
                    options: .usesLineFragmentOrigin,
                    context: nil
                )
        }
    }
    
    private static func attributedText(
        for title: String,
        textSize: CGFloat,
        textColor: UIColor
    ) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: textSize, weight: .bold),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: textColor
        ]
        
        return NSAttributedString(string: title, attributes: attrs)
    }
}
