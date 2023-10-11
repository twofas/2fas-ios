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

final class SelectServiceTableViewHeader: UIView {
    var saveAction: ((Bool) -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = UIColor.label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    private let saveLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = UIColor.label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.text = T.Browser.saveChoice
        return label
    }()
    
    private let saveSwitch = UISwitch()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = Theme.Colors.Fill.background
        let margin = Theme.Metrics.doubleMargin
        addSubview(titleLabel, with: [
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: margin)
        ])
        
        saveSwitch.addTarget(self, action: #selector(saveSwitchAction), for: .valueChanged)
        
        saveLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        
        addSubview(saveLabel, with: [
            saveLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3 * margin),
            saveLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            saveLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin)
        ])
        
        addSubview(saveSwitch, with: [
            saveSwitch.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3 * margin),
            saveSwitch.leadingAnchor.constraint(equalTo: saveLabel.trailingAnchor, constant: margin),
            saveSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            saveSwitch.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin)
        ])
    }
    
    func configure(for extensionName: String, domain: String) {
        let bold = [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1).withTraits(traits: .traitBold)
        ]
        let txt = NSAttributedString.create(
            text: T.Browser.requestSourceDescription(extensionName, domain),
            emphasis: extensionName,
            standardAttributes: [:],
            emphasisAttributes: bold
        )
        let secondPartTxt = NSMutableAttributedString(attributedString: txt)
        secondPartTxt.decorate(textToDecorate: domain, attributes: bold)
        titleLabel.attributedText = secondPartTxt
    }
    
    func setSaveSwitch(isOn: Bool) {
        saveSwitch.isOn = isOn
    }
    
    @objc
    private func saveSwitchAction() {
        saveAction?(saveSwitch.isOn)
    }
}
