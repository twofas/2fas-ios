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
import CodeSupport
import Common

final class ComposeServiceIconTypeSelection: UITableViewCell {
    static let identifier = "ComposeServiceIconTypeSelection"
    
    enum OptionSelected {
        case brandIcon
        case label
    }
    
    var didSelect: ((OptionSelected) -> Void)?
    
    private let brandIcon = SelectionOption()
    private let labelIcon = SelectionOption()
    private let iconRenderer: UIImageView = {
        let im = UIImageView()
        im.contentMode = .center
        return im
    }()
    private let labelRenderer = LabelRenderer()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private var optionSelected: OptionSelected = .brandIcon
    
    private func commonInit() {
        backgroundColor = Theme.Colors.SettingsCell.background
        
        brandIcon.translatesAutoresizingMaskIntoConstraints = false
        labelIcon.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(brandIcon)
        contentView.addSubview(labelIcon)
        
        let verticalMargin = Theme.Metrics.doubleMargin
        
        NSLayoutConstraint.activate([
            brandIcon.topAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.topAnchor,
                constant: verticalMargin
            ),
            brandIcon.bottomAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.bottomAnchor,
                constant: -verticalMargin
            ),
            labelIcon.topAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.topAnchor,
                constant: verticalMargin
            ),
            labelIcon.bottomAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.bottomAnchor,
                constant: -verticalMargin
            ),
            NSLayoutConstraint(
                item: brandIcon,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerX,
                multiplier: 0.6,
                constant: 0
            ),
            NSLayoutConstraint(
                item: labelIcon,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerX,
                multiplier: 1.4,
                constant: 0
            )
        ])
        
        brandIcon.setSelected(true)
        brandIcon.setTitle(T.Tokens.brandIcon)
        brandIcon.setIconHandler(iconRenderer)
        
        labelIcon.setTitle(T.Tokens.label)
        labelIcon.setIconHandler(labelRenderer)
        
        brandIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(brandAction)))
        labelIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelAction)))
        
        selectionStyle = .none
        
        accessibilityElements = [brandIcon, labelIcon]
    }
    
    func set(iconTypeID: IconTypeID, labelTitle: String, labelColor: TintColor, iconTypeName: IconTypeName) {
        iconRenderer.image = ServiceIcon.for(iconTypeID: iconTypeID)
        brandIcon.accessibilityText = T.Voiceover.serviceIcon(iconTypeName)
        
        labelRenderer.setText(labelTitle)
        labelRenderer.setColor(labelColor, animated: false)
        labelIcon.accessibilityText = T.Voiceover.serviceLabelWithNameAndColor(labelTitle, labelColor.localizedName)
    }
    
    func setSelectedOption(_ optionSelected: OptionSelected) {
        self.optionSelected = optionSelected
        switch optionSelected {
        case .brandIcon: switchToBrand()
        case .label: switchToLabel()
        }
    }
    
    @objc
    private func brandAction() {
        switchToBrand()
        didSelect?(.brandIcon)
    }
    
    @objc
    private func labelAction() {
        switchToLabel()
        didSelect?(.label)
    }
    
    private func switchToBrand() {
        brandIcon.setSelected(true)
        labelIcon.setSelected(false)
    }
    
    private func switchToLabel() {
        brandIcon.setSelected(false)
        labelIcon.setSelected(true)
    }
}
