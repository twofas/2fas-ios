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

enum MainContainerElementGenerator {
    static func generateImage(using name: String, size: CGSize, useTemplated: Bool = false) -> UIImageView {
        let image: UIImage = {
            guard let i = UIImage(named: name) else { return UIImage() }
            if useTemplated {
                return i.withRenderingMode(.alwaysTemplate)
            }
            return i
        }()
        let img = UIImageView(image: image)
        if UIDevice.isiPad {
            img.contentMode = .center
        } else {
            img.contentMode = .scaleAspectFit
        }
        
        img.translatesAutoresizingMaskIntoConstraints = false
        img.setContentCompressionResistancePriority(.defaultLow - 1, for: .vertical)
        
        let anchorWidth = img.widthAnchor.constraint(equalToConstant: size.width)
        anchorWidth.priority = .defaultLow - 1
        anchorWidth.isActive = true
        
        let anchorHeight = img.heightAnchor.constraint(equalToConstant: size.height)
        anchorHeight.priority = .defaultLow - 1
        anchorHeight.isActive = true
        
        return img
    }
    
    static func generateHorizontalStackView(spacing: CGFloat, arrangedSubviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        
        stackView.axis = .vertical
        stackView.spacing = spacing
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        return stackView
    }
    
    static func generateText(
        _ text: String,
        with style: MainContainerTextStyling,
        accessibilityLabel: String?
    ) -> UILabel {
        let label = UILabel()
        label.apply(MainContainerTextStyling.content.value)
        label.text = text
        label.apply(style.value)
        if let accessibilityLabel {
            label.accessibilityLabel = accessibilityLabel
        }
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        label.setContentHuggingPriority(.defaultHigh + 1, for: .vertical)
        
        return label
    }
    
    static func generateAttributedText(
        _ text: String,
        with mainStyle: MainContainerTextStyling,
        additionalFormatting: [MainContainerElementGeneratorAdditionalFormatting],
        accessibilityLabel: String?
    ) -> UILabel {
        let label = UILabel()
        label.apply(MainContainerTextStyling.content.value)
        label.apply(mainStyle.value)
        let attrText = NSMutableAttributedString(string: text)
        additionalFormatting.forEach { formatting in
            attrText.decorate(textToDecorate: formatting.substring, attributes: formatting.formatting)
        }
        label.attributedText = attrText
        if let accessibilityLabel {
            label.accessibilityLabel = accessibilityLabel
        }
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        label.setContentHuggingPriority(.defaultHigh + 1, for: .vertical)
        return label
    }
    
    static func generateCenteredImage(image: UIImage) -> UIView {
        let imageView = MainContainerCenteredImage()
        imageView.setImage(image)
        return imageView
    }
}

struct MainContainerElementGeneratorAdditionalFormatting {
    let substring: String
    let formatting: [NSAttributedString.Key: Any]
}
