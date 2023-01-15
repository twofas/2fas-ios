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

final class MainContainerToggleWithLabel: UIView {
    var action: ((Bool) -> Void)?
    
    private let horizontalSpacing: CGFloat = 10
    private let elementsSpacing: CGFloat = Theme.Metrics.standardSpacing
    private let container = UIView()
    private let toggle: UISwitch = {
        let t = UISwitch()
        t.thumbTintColor = Theme.Colors.Fill.backgroundLight
        t.onTintColor = Theme.Colors.Controls.active
        t.isAccessibilityElement = true
        return t
    }()
    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.adjustsFontSizeToFitWidth = true
        l.numberOfLines = 1
        l.minimumScaleFactor = 0.7
        l.isUserInteractionEnabled = true
        l.font = Theme.Fonts.Text.info
        l.isAccessibilityElement = false
        return l
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
        addSubview(container, with: [
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            container.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
        container.addSubview(toggle, with: [
            toggle.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: horizontalSpacing),
            toggle.topAnchor.constraint(equalTo: container.topAnchor),
            toggle.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        container.addSubview(descriptionLabel, with: [
            descriptionLabel.leadingAnchor.constraint(equalTo: toggle.trailingAnchor, constant: elementsSpacing),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -horizontalSpacing),
            descriptionLabel.topAnchor.constraint(equalTo: container.topAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelTapped)))
        toggle.addTarget(self, action: #selector(toggleAction), for: .valueChanged)
    }
    
    @objc(toggleAction)
    private func toggleAction() {
        action?(toggle.isOn)
    }
    
    @objc
    private func labelTapped() {
        toggle.setOn(!toggle.isOn, animated: true)
        toggleAction()
    }
    
    func setText(_ text: String) {
        descriptionLabel.text = text
        toggle.accessibilityLabel = text
    }
    
    func setDefaultValue(_ value: Bool) {
        toggle.setOn(value, animated: false)
    }
}
