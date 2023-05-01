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
import Storage
import Token
import Common

final class GridViewItemCell: GridCollectionViewCell, TokenTimerConsumer {
    static let reuseIdentifier = "GridViewItemCell"
    let autoManagable = true
    
    private enum ViewItemConsts {
        static let circularProgressSize: CGFloat = 28
        static let stackViewLeading: CGFloat = 80
        static let tokenHeight: CGFloat = 60
    }
    private let tokenLabel = TokenLabel()
    private let circularProgress = CircleProgress()
    
    private(set) var secret: String = ""
    private var serviceTypeName: String = ""
    
    private var useNextToken = false
    
    func update(
        name: String,
        secret: String,
        serviceTypeName: String,
        additionalInfo: String?,
        logoType: LogoType,
        category: TintColor,
        useNextToken: Bool
    ) {
        tokenLabel.clear()
        nameLabel.text = name
        self.secret = secret
        self.serviceTypeName = serviceTypeName
        infoNextToken.set(info: additionalInfo)
        clearTokenMarking()
        categoryView.backgroundColor = category.color
        categoryView.accessibilityLabel = T.Voiceover.badgeColor(category.localizedName)
//        configureIcon(with: iconType, serviceTypeName: serviceTypeName)
        setupAccessibility()
        self.useNextToken = useNextToken
    }
    
    func setInitial(_ progress: Int, period: Int, currentToken: String, nextToken: String, willChangeSoon: Bool) {
        circularProgress.setPeriod(period)
        circularProgress.setProgress(progress, animated: false)
        tokenLabel.setToken(currentToken)
        infoNextToken.set(nextToken: nextToken)
        shouldMark(willChangeSoon: willChangeSoon, isPlanned: false)
    }
    
    func setUpdate(_ progress: Int, isPlanned: Bool, currentToken: String, nextToken: String, willChangeSoon: Bool) {
        circularProgress.setProgress(progress, animated: isPlanned)
        tokenLabel.setToken(currentToken)
        infoNextToken.set(nextToken: nextToken)
        shouldMark(willChangeSoon: willChangeSoon, isPlanned: isPlanned)
    }
    
    private func shouldMark(willChangeSoon: Bool, isPlanned: Bool) {
        if useNextToken {
            if willChangeSoon {
                infoNextToken.showNextToken(animated: isPlanned)
            } else {
                infoNextToken.showInfo(animated: isPlanned)
            }
        }
        if willChangeSoon {
            markToken()
        } else {
            clearTokenMarking()
        }
    }
    
    private func markToken() {
        tokenLabel.mark()
        circularProgress.mark()
    }
    
    private func clearTokenMarking() {
        tokenLabel.clearMarking()
        circularProgress.unmark()
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        contentView.addSubview(iconImageView, with: [
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Consts.margin),
            iconImageView.widthAnchor.constraint(equalToConstant: Consts.imageSize)
        ])
        
        contentView.addSubview(labelRendererContainer, with: [
            labelRendererContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            labelRendererContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            labelRendererContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Consts.margin
            ),
            labelRendererContainer.widthAnchor.constraint(equalToConstant: Consts.imageSize)
        ])
        
        contentView.addSubview(stackView, with: [
            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Consts.smallHeight
            ),
            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Consts.smallHeight
            ),
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: ViewItemConsts.stackViewLeading
            )
        ])
        
        stackView.addArrangedSubviews([
            nameLabel,
            tokenLabel,
            infoNextToken
        ])
        
        contentView.addSubview(circularProgress, with: [
            circularProgress.widthAnchor.constraint(equalToConstant: ViewItemConsts.circularProgressSize),
            circularProgress.heightAnchor.constraint(equalToConstant: ViewItemConsts.circularProgressSize),
            circularProgress.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Consts.margin
            ),
            circularProgress.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.heightAnchor.constraint(equalToConstant: Consts.smallHeight),
            tokenLabel.heightAnchor.constraint(equalToConstant: ViewItemConsts.tokenHeight),
            infoNextToken.heightAnchor.constraint(equalToConstant: Consts.smallHeight),
            stackView.trailingAnchor.constraint(
                lessThanOrEqualTo: circularProgress.leadingAnchor,
                constant: -Consts.margin
            )
        ])
    }
    
    override func setupAccessibility() {
        super.setupAccessibility()
        
        var accViews: [UIView] = [categoryView]
        if let current = currentAccessibilityIcon {
            accViews.append(current)
        }
        accViews.append(contentsOf: [nameLabel, tokenLabel, infoNextToken, circularProgress])
        accessibilityElements = accViews
    }
}
