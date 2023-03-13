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

final class SelectServiceTableViewCell: UITableViewCell {
    static let identifier = "SelectServiceTableViewCell"
    
    private let settingsIcon: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = UIColor.label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
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
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = Theme.Metrics.standardSpacing
        stackView.alignment = .fill
        return stackView
    }()
    
    private let iconContainer = UIView()
            
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
        
        stackView.addArrangedSubviews([iconContainer, textStackView])
        textStackView.addArrangedSubviews([titleLabel, subtitleLabel])
    }
    
    func update(icon: UIImage, title: String, subtitle: String?) {
        settingsIcon.image = icon
        titleLabel.text = title
        if let subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
    }
}
