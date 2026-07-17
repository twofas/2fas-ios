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

final class TokensViewEmptySearchScreen: UIView {
    private let iconSize: CGFloat = 72
    private let offsetY: CGFloat = 36
    private let spacingIconTitle: CGFloat = 12
    private let spacingTitleDescription: CGFloat = 6
    private let marginHorizontal: CGFloat = 30
    
    private let backgroundImage: UIImageView = {
        let img = UIImageView(image: Asset.emptyScreenBackground.image)
        img.contentMode = .scaleAspectFill
        img.tintColor = AppColor.fillsTertiary.uiColor
        return img
    }()
    private let iconImage: UIImageView = {
        let img = UIImageView(image: Asset.emptyScreenSearch.image)
        img.contentMode = .scaleAspectFit
        return img
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.allowsDefaultTighteningForTruncation = true
        label.textColor = AppColor.labelsPrimary.uiColor
        label.font = TextStyle.title2.uiFont(.emphasized)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = AppColor.labelsSecondary.uiColor
        label.font = TextStyle.callout.uiFont()
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
        backgroundColor = AppColor.backgroundsPrimary.uiColor
        isUserInteractionEnabled = false
        
        addSubview(backgroundImage)
        backgroundImage.pinToParent()

        addSubview(titleLabel, with: [
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offsetY),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: marginHorizontal),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -marginHorizontal)
        ])
        
        addSubview(descriptionLabel, with: [
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacingTitleDescription),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: marginHorizontal),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -marginHorizontal)
        ])
        
        addSubview(iconImage, with: [
            iconImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImage.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -spacingIconTitle),
            iconImage.widthAnchor.constraint(equalToConstant: iconSize),
            iconImage.heightAnchor.constraint(equalToConstant: iconSize)
        ])
        
        titleLabel.text = T.Tokens.serviceNotFoundSearch
        descriptionLabel.text = T.Tokens.tryDifferentSearchTerm
    }
}
