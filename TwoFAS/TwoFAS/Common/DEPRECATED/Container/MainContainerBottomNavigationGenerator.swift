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

enum MainContainerBottomNavigationGenerator {
    enum Element {
        enum ImageKind {
            case normal
            case template(color: UIColor)
        }
        case filledButton(text: String, callback: Callback, created: ((LoadingContentButton) -> Void)? = nil)
        case textButton(text: String, callback: Callback, created: ((LoadingContentButton) -> Void)? = nil)
        case text(text: String, style: MainContainerTextStyling, created: ((UILabel) -> Void)? = nil)
        case pagination(currentPage: Int, totalPages: Int)
        case other(view: UIView)
        case noSpacingContainer(elements: [Element])
        case image(name: String, size: CGSize, kind: ImageKind = .normal)
        case extraSpacing(value: CGFloat = Theme.Metrics.doubleMargin)
        case decoratedVerticalContainer(
            elements: [Element],
            created: ((MainContainerDecoratedVerticalContainer) -> Void)? = nil
        )
        case toggle(text: String, action: (Bool) -> Void, defaultValue: Bool = false)
    }
    
    static func generate(from elements: [Element]) -> UIView {
        let elements: [UIView] = elements.map { elementToView($0) }
        
        return MainContainerElementGenerator.generateHorizontalStackView(
            spacing: Theme.Metrics.halfSpacing,
            arrangedSubviews: elements
        )
    }
    
    private static func elementToView(_ element: Element) -> UIView {
        switch element {
        case .filledButton(let text, let callback, let created):
            let button = LoadingContentButton()
            button.configure(style: .background, title: text)
            button.action = callback
            created?(button)
            return button
            
        case .textButton(let text, let callback, let created):
            let button = LoadingContentButton()
            button.configure(style: .noBackground, title: text)
            button.apply(MainContainerButtonStyling.text.value)
            button.action = callback
            created?(button)
            return button
            
        case .text(let text, let style, let created):
            let label = MainContainerElementGenerator.generateText(text, with: style, accessibilityLabel: nil)
            created?(label)
            return label
            
        case .pagination(let currentPage, let totalPages):
            let pagination = MainContainerPaging()
            pagination.setPage(currentPage, total: totalPages)
            return pagination
            
        case .other(let view): return view
            
        case .noSpacingContainer(let elements):
            return MainContainerElementGenerator.generateHorizontalStackView(
                spacing: 0,
                arrangedSubviews: elements.map { elementToView($0) }
            )
            
        case .image(let name, let size, let kind):
            let useTemplated: Bool
            let color: UIColor?
            switch kind {
            case .normal:
                useTemplated = false
                color = nil
            case .template(let colorValue):
                useTemplated = true
                color = colorValue
            }
            let img = MainContainerElementGenerator.generateImage(using: name, size: size, useTemplated: useTemplated)
            if useTemplated {
                img.tintColor = color
            }
            return img
            
        case .extraSpacing(let value):
            let view = UIView()
            view.heightAnchor.constraint(equalToConstant: value).isActive = true
            return view
            
        case .decoratedVerticalContainer(let elements, let created):
            let container = MainContainerDecoratedVerticalContainer()
            container.addArrangedSubviews(elements.map { elementToView($0) })
            created?(container)
            return container
            
        case .toggle(let text, let action, let enabled):
            let tg = MainContainerToggleWithLabel()
            tg.setText(text)
            tg.action = action
            tg.setDefaultValue(enabled)
            return tg
        }
    }
}
