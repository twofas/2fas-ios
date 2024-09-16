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

final class SettingsMenuTableViewCell: UITableViewCell {
    static let identifier = "SettingsMenuTableViewCell"
    
    // swiftlint:disable discouraged_none_name
    enum AccessoryType {
        case toggle(isEnabled: Bool, action: (SettingsMenuTableViewCell, Bool) -> Void)
        case info(text: String)
        case arrowWithCustomView(customView: UIView)
        case customView(customView: UIView)
        case infoArrow(text: String)
        case arrow
        case checkmark
        case none
    }
    
    enum TextDecoration {
        case none
        case action
    }
    // swiftlint:enable discouraged_none_name
    
    private var isDisabled = false
    private var decorateText: TextDecoration = .none
    
    private let settingsIcon = SettingsMenuIcon()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = UIColor.label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.minimumScaleFactor = 0.9
        label.allowsDefaultTighteningForTruncation = true
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.defaultHigh + 2, for: .horizontal)
        label.accessibilityTraits = .staticText
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = Theme.Metrics.standardSpacing
        stackView.alignment = .fill
        return stackView
    }()
    
    private let iconContainer = UIView()
    private let infoLabelContainer = UIView()
    private let customViewContainer = UIView()
    
    init(frame: CGRect) {
        super.init(style: .default, reuseIdentifier: nil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    private func commonInit() {
        let iconSize = Theme.Metrics.settingsIconSize
        let accessoryViewSize = Theme.Metrics.settingsAccessoryViewSize

        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true
        
        contentView.addSubview(stackView, with: [
            stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
        
        iconContainer.addSubview(settingsIcon, with: [
            settingsIcon.widthAnchor.constraint(equalToConstant: iconSize),
            settingsIcon.heightAnchor.constraint(equalToConstant: iconSize),
            settingsIcon.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor),
            settingsIcon.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor),
            settingsIcon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            customViewContainer.widthAnchor.constraint(equalToConstant: accessoryViewSize),
            customViewContainer.heightAnchor.constraint(equalToConstant: accessoryViewSize)
        ])

        infoLabelContainer.addSubview(infoLabel)
        infoLabel.pinToParent()
        
        stackView.addArrangedSubview(iconContainer)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(infoLabelContainer)
        stackView.addArrangedSubview(customViewContainer)
        accessibilityTraits = .button
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateTitleColor()
        updateInfoLabelColor()
    }
    
    func update(icon: UIImage?, title: String, kind: AccessoryType, decorateText: TextDecoration = .none) {
        self.decorateText = decorateText
        
        if let icon {
            settingsIcon.image = icon
            iconContainer.isHidden = false
        } else {
            settingsIcon.image = nil
            iconContainer.isHidden = true
        }
        
        isDisabled = false
        titleLabel.text = title
        clearCustomContainer()
        
        switch kind {
        case .arrow:
            infoLabelContainer.isHidden = true
            accessoryView = nil
            accessoryType = .disclosureIndicator
        case .info(let text):
            infoLabel.text = text
            infoLabelContainer.isHidden = false
            accessoryView = nil
            accessoryType = .none
        case .infoArrow(let text):
            infoLabel.text = text
            infoLabelContainer.isHidden = false
            accessoryView = nil
            accessoryType = .disclosureIndicator
        case .toggle(let isEnabled, let action):
            infoLabelContainer.isHidden = true
            let toggle = SettingsMenuToggle()
            toggle.isOn = isEnabled
            toggle.actionCallback = { [weak self] isOn in
                guard let self else { return }
                action(self, isOn)
            }
            accessoryView = toggle
            accessoryType = .none
        case .checkmark:
            infoLabelContainer.isHidden = true
            accessoryView = nil
            accessoryType = .checkmark
        case .none:
            infoLabelContainer.isHidden = true
            accessoryView = nil
            accessoryType = .none
        case .arrowWithCustomView(let customView):
            infoLabelContainer.isHidden = true
            accessoryView = nil
            accessoryType = .disclosureIndicator
            customViewContainer.addSubview(customView)
            customView.pinToParent()
            customViewContainer.isHidden = false
        case .customView(let customView):
            infoLabelContainer.isHidden = true
            accessoryView = nil
            accessoryType = .none
            customViewContainer.addSubview(customView)
            customView.pinToParent()
            customViewContainer.isHidden = false
        }
        
        updateTitleColor()
        updateInfoLabelColor()
    }
    
    func disable() {
        isDisabled = true
        settingsIcon.disable()
        updateTitleColor()
        updateInfoLabelColor()
        selectionStyle = .none
        disableToggle()
    }
    
    func disableToggle() {
        if let toggle = accessoryView as? SettingsMenuToggle {
            toggle.makeInactive()
        }
    }
    
    func disableIconBorder() {
        settingsIcon.disableBorder()
    }
    
    private func clearCustomContainer() {
        customViewContainer.isHidden = true
        customViewContainer.removeAllSubviews()
    }
    
    private func updateTitleColor() {
        var color: UIColor = .label
        if isDisabled {
            color = Theme.Colors.Text.inactive
        } else if isSelected && selectionStyle != .none {
            color = .white
        } else if decorateText == .action {
            color = Theme.Colors.Text.theme
        }
        titleLabel.textColor = color
    }
    
    private func updateInfoLabelColor() {
        var color: UIColor = .secondaryLabel
        if isDisabled {
            color = Theme.Colors.Text.inactive
        } else if isSelected && selectionStyle != .none {
            color = .white
        }
        infoLabel.textColor = color
    }
}
