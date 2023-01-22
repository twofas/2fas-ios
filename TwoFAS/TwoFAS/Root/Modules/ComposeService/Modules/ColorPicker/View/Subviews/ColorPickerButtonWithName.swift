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

final class ColorPickerButtonWithName: UIView {
    var userAction: ((TintColor) -> Void)? {
        get { colorButton.userAction }
        set { colorButton.userAction = newValue }
    }
    
    var isActive: Bool { colorButton.isActive }
    
    private(set) var color: TintColor!
    
    private let colorButton = ColorPickerButton()
    private let colorNameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.Controls.smallTitle
        label.textColor = Theme.Colors.Text.main
        label.textAlignment = .center
        return label
    }()
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        sv.spacing = Theme.Metrics.standardMargin
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
        addSubview(stackView)
        stackView.addArrangedSubviews([colorButton, colorNameLabel])
        addSubview(stackView, with: [
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
        isAccessibilityElement = true
    }
    
    func set(color: TintColor) {
        self.color = color
        colorButton.set(color: color)
        colorNameLabel.text = color.localizedName
        accessibilityLabel = color.localizedName
        accessibilityTraits = .button
    }
    
    func setActive(_ active: Bool, animated: Bool) {
        colorButton.setActive(active, animated: animated)
    }
}
