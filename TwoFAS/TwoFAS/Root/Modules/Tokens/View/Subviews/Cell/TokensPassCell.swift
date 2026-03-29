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

final class TokensPassCell: UICollectionViewCell {
    static let reuseIdentifier = "TokensPassCell"
    
    private let size = CGSize(width: 328, height: 163)
    private let imageFrame = UIImage(asset: Asset.passFrameLight)
    private let imageDecoration = UIImage(asset: Asset.framePassDecoration)
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics(forTextStyle: .headline)
            .scaledFont(for: .systemFont(ofSize: 14, weight: .medium))
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.7
        label.allowsDefaultTighteningForTruncation = true
        label.textAlignment = .center
        label.textColor = Theme.Colors.Text.main
        label.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        label.accessibilityTraits = .header
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics(forTextStyle: .body)
            .scaledFont(for: .systemFont(ofSize: 12, weight: .regular))
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 5
        label.minimumScaleFactor = 0.7
        label.allowsDefaultTighteningForTruncation = true
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.textColor = Theme.Colors.Text.main
        label.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        label.accessibilityTraits = .staticText
        return label
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
        let img = UIImageView(image: imageFrame)
        img.contentMode = .center
        contentView.addSubview(img, with: [
            img.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            img.topAnchor.constraint(equalTo: contentView.topAnchor),
            img.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        let decoration = UIImageView(image: imageDecoration)
        contentView.addSubview(decoration, with: [
            decoration.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            decoration.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22)
        ])
        
        contentView.addSubview(titleLabel, with: [
            titleLabel.topAnchor.constraint(equalTo: decoration.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: img.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: img.trailingAnchor, constant: -18)
        ])
        titleLabel.text = "We built something new for you!"
        
        contentView.addSubview(descriptionLabel, with: [
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: img.leadingAnchor, constant: 18),
            descriptionLabel.trailingAnchor.constraint(equalTo: img.trailingAnchor, constant: -18)
        ])
        
        descriptionLabel.attributedText = NSAttributedString
            .create(
                text: "A secure, local-first Password Manager – 2FAS Pass, designed to work alongside 2FAS Auth, keeping your Authenticator exactly as it is.",
                emphasis: "Password Manager – 2FAS Pass",
                standardAttributes: [:],
                emphasisAttributes: [NSAttributedString.Key.font: UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 12, weight: .bold))]
            )
        
    }
}
