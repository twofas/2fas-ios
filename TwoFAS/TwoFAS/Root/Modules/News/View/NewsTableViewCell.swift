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

final class NewsTableViewCell: UITableViewCell {
    static let identifier = "NewsTableViewCell"
    private let iconSize: CGFloat = 35
    private let frameMargin: CGFloat = Theme.Metrics.doubleMargin
    
    private let newsIcon: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .top
        return imgView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = UIColor.label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let linkIcon: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .topRight
        imgView.image = Asset.externalLinkIcon.image.withRenderingMode(.alwaysTemplate)
        imgView.tintColor = UIColor.secondaryLabel
        return imgView
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = Theme.Metrics.halfSpacing
        stackView.alignment = .fill
        return stackView
    }()
    
    private let backgroundViewFrame: UIView = {
        let v = UIView()
        v.layer.cornerCurve = .continuous
        v.layer.cornerRadius = Theme.Metrics.cornerRadius
        v.backgroundColor = Theme.Colors.Fill.System.third
        return v
    }()
    
    private let newsIconContainer = UIView()
    private let linkIconContainer = UIView()
    
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
        
        backgroundColor = Theme.Colors.notificationsBackground
        contentView.backgroundColor = Theme.Colors.notificationsBackground
        
        contentView.addSubview(backgroundViewFrame)
        backgroundViewFrame.pinToParent(with: UIEdgeInsets(
            top: frameMargin / 2.0,
            left: frameMargin,
            bottom: frameMargin / 2.0,
            right: frameMargin
        ))
        
        let elementMargin = 1.5 * frameMargin
        let vElementMargin = frameMargin
        
        contentView.addSubview(newsIconContainer, with: [
            newsIconContainer.leadingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.leadingAnchor,
                constant: elementMargin
            ),
            newsIconContainer.topAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.topAnchor,
                constant: vElementMargin
            ),
            newsIconContainer.bottomAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.bottomAnchor,
                constant: -vElementMargin
            ),
            newsIconContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: iconSize),
            newsIconContainer.widthAnchor.constraint(equalToConstant: iconSize)
        ])
        
        contentView.addSubview(textStackView, with: [
            textStackView.leadingAnchor.constraint(
                equalTo: newsIconContainer.trailingAnchor,
                constant: Theme.Metrics.doubleMargin
            ),
            textStackView.topAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.topAnchor,
                constant: vElementMargin
            ),
            textStackView.bottomAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.bottomAnchor,
                constant: -vElementMargin
            )
        ])
                
        contentView.addSubview(linkIconContainer, with: [
            linkIconContainer.widthAnchor.constraint(equalToConstant: iconSize),
            linkIconContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: iconSize),
            linkIconContainer.leadingAnchor.constraint(
                equalTo: textStackView.trailingAnchor,
                constant: Theme.Metrics.standardSpacing
            ),
            linkIconContainer.trailingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.trailingAnchor,
                constant: -elementMargin
            ),
            linkIconContainer.topAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.topAnchor,
                constant: vElementMargin
            ),
            linkIconContainer.bottomAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.bottomAnchor,
                constant: -vElementMargin
            )
        ])
        textStackView.addArrangedSubviews([titleLabel, subtitleLabel])
        
        newsIconContainer.addSubview(newsIcon)
        newsIcon.pinToParent()
        
        linkIconContainer.addSubview(linkIcon)
        linkIcon.pinToParent()
        
        selectionStyle = .gray
    }
    
    func update(
        icon: UIImage,
        title: String,
        wasRead: Bool,
        publishedAgo: String,
        hasURL: Bool
    ) {
        newsIcon.image = icon
        titleLabel.text = title
        subtitleLabel.text = publishedAgo
        linkIcon.isHidden = !hasURL
        
        if wasRead {
            newsIcon.tintColor = Theme.Colors.Icon.inactive
            titleLabel.font = readText
            titleLabel.textColor = UIColor.secondaryLabel
            backgroundViewFrame.backgroundColor = Theme.Colors.notificationsBackground
        } else {
            newsIcon.tintColor = Theme.Colors.Icon.theme
            titleLabel.font = unreadText
            titleLabel.textColor = UIColor.label
            backgroundViewFrame.backgroundColor = Theme.Colors.Fill.System.third
        }
    }
    
    private var readText: UIFont {
        UIFont.preferredFont(forTextStyle: .body)
    }
    
    private var unreadText: UIFont {
        UIFont.preferredFont(forTextStyle: .body).bold()
    }
}
