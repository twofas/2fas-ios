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

enum MainContainerContentGenerator {
    enum Element {
        case noSpacingContainer(elements: [Element])
        case extraSpacing
        case text(
            text: String,
            style: MainContainerTextStyling,
            created: ((UILabel) -> Void)? = nil,
            accessibilityLabel: String? = nil
        )
        case formattedText(
            text: String,
            mainStyle: MainContainerTextStyling,
            additionalFormatting: [MainContainerElementGeneratorAdditionalFormatting],
            created: ((UILabel) -> Void)? = nil,
            accessibilityLabel: String? = nil
        )
        case image(name: String, size: CGSize, allowCenter: Bool = false)
        case centeredImage(image: UIImage)
        case view(view: UIView)
        case lineSeparator
        case variableSpacing
        case elasticSpacer
    }
    
    static func generate(from elements: [Element]) -> UIView {
        let double: Double = 2
        let container = UIView()
        let extraSpacingValue = double * Theme.Metrics.doubleMargin
        let standardSpacingValue = Theme.Metrics.standardMargin
        
        var prevTop = container.topAnchor
        
        var extraSpacingUsed = false
        let elemenetViewsConfig: [(view: UIView, extraSpacing: Bool)] = elements.map { elementToView($0) }
            .reduce(into: [(UIView, Bool)]()) { result, value in
            if value.extraSpacing {
                extraSpacingUsed = true
            } else if let view = value.createdElement {
                result.append((view, extraSpacingUsed))
                extraSpacingUsed = false
            }
        }
        
        for elementConfig in elemenetViewsConfig {
            let spacing = elementConfig.extraSpacing ? extraSpacingValue : standardSpacingValue
            let element = elementConfig.view
            
            container.addSubview(element, with: [
                element.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                element.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                element.topAnchor.constraint(equalTo: prevTop, constant: spacing)
            ])
            
            prevTop = element.bottomAnchor
        }
        
        container.bottomAnchor.constraint(equalTo: prevTop, constant: standardSpacingValue).isActive = true
        
        return container
    }
    
    private static func elementToView(_ element: Element) -> (createdElement: UIView?, extraSpacing: Bool) {
        let second: Float = 2
        switch element {
        case .extraSpacing:
            return (createdElement: nil, extraSpacing: true)
        case .text(let text, let style, let created, let accessibilityLabel):
            let label = MainContainerElementGenerator.generateText(
                text,
                with: style,
                accessibilityLabel: accessibilityLabel
            )
            created?(label)
            return (createdElement: label, extraSpacing: false)
        case .formattedText(let text, let mainStyle, let additionalFormatting, let created, let accessibilityLabel):
            let label = MainContainerElementGenerator.generateAttributedText(
                text,
                with: mainStyle,
                additionalFormatting: additionalFormatting,
                accessibilityLabel: accessibilityLabel
            )
            created?(label)
            return (createdElement: label, extraSpacing: false)
        case .noSpacingContainer(let elements):
            let container = MainContainerElementGenerator.generateHorizontalStackView(
                spacing: 0,
                arrangedSubviews: elements.compactMap { elementToView($0).createdElement }
            )
            return (createdElement: container, extraSpacing: false)
        case .image(let name, let size, let allowCenter):
            let container = MainContainerElementGenerator.generateImage(using: name, size: size)
            if allowCenter {
                container.setContentHuggingPriority(.defaultLow - second, for: .vertical)
                container.setContentCompressionResistancePriority(.defaultLow - second, for: .vertical)
            }
            return (createdElement: container, extraSpacing: false)
        case .centeredImage(let image):
            let image = MainContainerElementGenerator.generateCenteredImage(image: image)
            return (createdElement: image, extraSpacing: false)
        case .view(let view):
            return (createdElement: view, extraSpacing: false)
        case .variableSpacing:
            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow - second, for: .vertical)
            spacer.setContentCompressionResistancePriority(.defaultLow - second, for: .vertical)
            return (createdElement: spacer, extraSpacing: false)
        case .lineSeparator:
            return (createdElement: Separator(), extraSpacing: false)
        case .elasticSpacer:
            let v = UIView()
            v.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
            return (createdElement: v, extraSpacing: false)
        }
    }
}
