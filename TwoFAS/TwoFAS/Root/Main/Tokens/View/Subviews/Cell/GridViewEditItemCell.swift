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

final class GridViewEditItemCell: GridCollectionViewCell {
    static let reuseIdentifier = "GridViewEditItemCell"

    private enum ViewEditItemConsts {
        static let dragHandlesWidth: CGFloat = 16
        static let iconImageLeading: CGFloat = 54
        static let stackViewLeading: CGFloat = 114
        static let arrowWidth: CGFloat = 12
        static let arrowHeigth: CGFloat = 28
    }
    private var dragHandles: UIImageView = {
        let imageView = UIImageView(image: Asset.dragHandles.image)
        imageView.contentMode = .center
        imageView.tintColor = Theme.Colors.Icon.more
        return imageView
    }()
    private var rightArrow: UIImageView = {
        let imageView = UIImageView(image: Asset.settingsArrow.image)
        imageView.contentMode = .right
        imageView.tintColor = Theme.Colors.Icon.more
        return imageView
    }()
    
    private var placeholdersStackView: UIStackView = {
        let mainStackView = UIStackView()
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center
        mainStackView.distribution = .equalSpacing
        mainStackView.spacing = 22
        
        for _ in 0...1 {
            let phStackView = UIStackView()
            phStackView.axis = .horizontal
            phStackView.alignment = .center
            phStackView.distribution = .equalSpacing
            phStackView.spacing = 11
            for _ in 0...2 {
                let ph = UIImageView(image: Asset.tokenPlaceholder.image)
                ph.contentMode = .scaleAspectFit
                ph.tintColor = Theme.Colors.Line.secondaryLine
                phStackView.addArrangedSubview(ph)
            }
            mainStackView.addArrangedSubview(phStackView)
        }
        
        return mainStackView
    }()
    
    private var serviceTypeName: String = ""
    
    func update(
        name: String,
        additionalInfo: String,
        serviceTypeName: String,
        iconType: IconType,
        category: TintColor,
        canBeDragged: Bool
    ) {
        nameLabel.text = name
        infoNextToken.set(info: additionalInfo)
        infoNextToken.showInfo(animated: false)
        self.serviceTypeName = serviceTypeName
        categoryView.backgroundColor = category.color
        categoryView.accessibilityLabel = T.Voiceover.badgeColor(category.localizedName)
        configureIcon(with: iconType, serviceTypeName: serviceTypeName)
        dragHandles.isHidden = !canBeDragged
        setupAccessibility()
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        contentView.addSubview(dragHandles, with: [
            dragHandles.topAnchor.constraint(equalTo: contentView.topAnchor),
            dragHandles.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dragHandles.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Consts.margin),
            dragHandles.widthAnchor.constraint(equalToConstant: ViewEditItemConsts.dragHandlesWidth)
        ])
        
        contentView.addSubview(iconImageView, with: [
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            iconImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: ViewEditItemConsts.iconImageLeading
            ),
            iconImageView.widthAnchor.constraint(equalToConstant: Consts.imageSize)
        ])
        
        contentView.addSubview(labelRendererContainer, with: [
            labelRendererContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            labelRendererContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            labelRendererContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: ViewEditItemConsts.iconImageLeading
            ),
            labelRendererContainer.widthAnchor.constraint(equalToConstant: Consts.imageSize)
        ])

        contentView.addSubview(stackView, with: [
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Consts.smallHeight),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Consts.smallHeight),
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: ViewEditItemConsts.stackViewLeading
            )
        ])
        
        stackView.addArrangedSubviews([
            nameLabel,
            placeholdersStackView,
            infoNextToken
        ])
        
        contentView.addSubview(rightArrow, with: [
            rightArrow.widthAnchor.constraint(equalToConstant: ViewEditItemConsts.arrowWidth),
            rightArrow.heightAnchor.constraint(equalToConstant: ViewEditItemConsts.arrowHeigth),
            rightArrow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Consts.margin),
            rightArrow.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.heightAnchor.constraint(equalToConstant: Consts.smallHeight),
            infoNextToken.heightAnchor.constraint(equalToConstant: Consts.smallHeight),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: rightArrow.leadingAnchor)
        ])
    }
    
    override func setupAccessibility() {
        super.setupAccessibility()
        contentView.isAccessibilityElement = true
        contentView.accessibilityLabel = T.Voiceover.edit(serviceTypeName)
        contentView.accessibilityTraits = .button
        var accViews: [UIView] = [categoryView]
        if let current = currentAccessibilityIcon {
            accViews.append(current)
        }
        accViews.append(contentsOf: [nameLabel, infoNextToken, contentView])
        accessibilityElements = accViews
    }
}
