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
    
    public static func render(with title: String, color: TintColor, variant: Variant = .standard) -> UIImage {
        let frame = CGRect(origin: .zero, size: CGSize(width: variant.size, height: variant.size))
        let renderer = UIGraphicsImageRenderer(bounds: frame)
        return renderer.image { ctx in
            color.color.setFill()
            ctx.cgContext.fillEllipse(in: frame)
            UIColor.white.setFill()
            attributedText(for: title, textSize: variant.textSize)
                .draw(
                    with: CGRect(x: 0, y: variant.textSize, width: variant.size, height: variant.textSize),
                    options: .usesLineFragmentOrigin,
                    context: nil
                )
        }
    }
    
    private static func attributedText(for title: String, textSize: CGFloat) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: textSize, weight: .bold),
            .paragraphStyle: paragraphStyle
        ]
        
        return NSAttributedString(string: title, attributes: attrs)
    }
}
