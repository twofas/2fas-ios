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

// swiftlint:disable no_magic_numbers
final class ColorGridSelector: UIView {
    var userAction: ((TintColor) -> Void)?
    private(set) var activeColor: TintColor = .default
    private var tintColorButtons: [TintColor: ColorPickerButtonWithName] = [:]
    private let mainStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .equalSpacing
        sv.spacing = Theme.Metrics.doubleMargin * 2
        return sv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = Theme.Colors.Fill.System.third
        isAccessibilityElement = false
        
        let margin = Theme.Metrics.doubleMargin * 2
        let hMargin = Theme.Metrics.doubleMargin

        addSubview(mainStack, with: [
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin),
            mainStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: hMargin),
            mainStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -hMargin),
            mainStack.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        let colorsChunked: [UIStackView] = TintColor.allCases.chunked(into: 3).map { colors in
            var buttons: [UIView] = colors.map { color in
                let b = ColorPickerButtonWithName()
                b.set(color: color)
                b.userAction = { [weak self] color in self?.didSelectColor(color) }
                tintColorButtons[color] = b
                accessibilityElements?.append(b)
                return b
            }
            
            if buttons.count == 1 {
                buttons.insert(UIView(), at: 0)
                buttons.insert(UIView(), at: 2)
            } else if buttons.count == 2 {
                buttons.insert(UIView(), at: 2)
            }
            
            let sv = UIStackView(arrangedSubviews: buttons)
            sv.axis = .horizontal
            sv.alignment = .center
            sv.distribution = .equalSpacing
            sv.spacing = Theme.Metrics.doubleMargin * 2
            return sv
        }
        mainStack.addArrangedSubviews(colorsChunked)
    }
    
    private func didSelectColor(_ color: TintColor) {
        setActiveColor(color, animated: true)
        userAction?(color)
    }
    
    func setActiveColor(_ color: TintColor, animated: Bool) {
        activeColor = color
        tintColorButtons.forEach { currentColor, button in
            button.setActive(color == currentColor, animated: animated)
        }
    }
}
