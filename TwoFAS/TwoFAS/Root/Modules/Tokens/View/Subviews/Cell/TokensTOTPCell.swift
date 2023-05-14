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
import Token

final class TokensTOTPCell: UICollectionViewCell, TokenTimerConsumer {
    static let reuseIdentifier = "TokensTOTPCell"
    let autoManagable = true
    
    private let hMargin: CGFloat = Theme.Metrics.doubleMargin
    private let vMargin: CGFloat = Theme.Metrics.mediumMargin
    
    private let tokenLabel = TokensTokenView()
    private let nextTokenLabel = TokensNextTokenView()
    private let circularProgress = TokensCircleProgress()
    
    private(set) var secret: String = ""
    private var serviceTypeName: String = ""
    
    private var useNextToken = false
    private var hasAdditionalInfo = false
    
    private let categoryView = TokensCategoryComponent()
    private var logoView: TokensLogoComponent = {
        let comp = TokensLogoComponent()
        comp.setKind(.normal)
        return comp
    }()
    private var serviceNameLabel: TokensServiceNameComponent = {
        let comp = TokensServiceNameComponent()
        comp.setKind(.normal)
        return comp
    }()
    private var additionalInfoLabel: TokensAdditionalInfoComponent = {
        let comp = TokensAdditionalInfoComponent()
        comp.setKind(.normal)
        return comp
    }()
    
    private var bottomNameConstraint: NSLayoutConstraint?
    private var bottomAdditionalNameConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupBackground()
        setupLayout()
        //        setupAccessibility() // TODO: Add accessibility
    }
    
    private func setupBackground() {
        contentView.backgroundColor = Theme.Colors.Fill.background
        backgroundColor = Theme.Colors.Fill.background
    }
    
    private func setupLayout() {
        contentView.addSubview(categoryView, with: [
            categoryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryView.topAnchor.constraint(equalTo: contentView.topAnchor),
            categoryView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.addSubview(logoView, with: [
            logoView.leadingAnchor.constraint(equalTo: categoryView.trailingAnchor, constant: hMargin),
            logoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vMargin),
            logoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vMargin)
        ])
        
        contentView.addSubview(serviceNameLabel, with: [
            serviceNameLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: hMargin),
            serviceNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vMargin)
        ])
        
        bottomNameConstraint = serviceNameLabel.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -vMargin
        )
        
        contentView.addSubview(additionalInfoLabel, with: [
            additionalInfoLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: hMargin),
            additionalInfoLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor),
            additionalInfoLabel.heightAnchor.constraint(equalTo: serviceNameLabel.heightAnchor),
            additionalInfoLabel.widthAnchor.constraint(equalTo: serviceNameLabel.widthAnchor)
        ])
        
        bottomAdditionalNameConstraint = additionalInfoLabel.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -vMargin
        )
        
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
        serviceNameLabel.setText(name)
        self.secret = secret
        self.serviceTypeName = serviceTypeName
        if let additionalInfo {
            hasAdditionalInfo = true
            additionalInfoLabel.setText(additionalInfo)
        } else {
            hasAdditionalInfo = false
            additionalInfoLabel.clear()
        }
        
        clearTokenMarking()
        categoryView.setColor(category)
        logoView.configure(with: logoType)

        self.useNextToken = useNextToken
        
        wireLayout()
    }
    
    func setInitial(_ progress: Int, period: Int, currentToken: String, nextToken: String, willChangeSoon: Bool) {
        circularProgress.setPeriod(period)
        circularProgress.setProgress(progress, animated: false)
        tokenLabel.setToken(currentToken)
        nextTokenLabel.set(nextToken: nextToken)
        shouldMark(willChangeSoon: willChangeSoon, isPlanned: false)
    }
    
    func setUpdate(_ progress: Int, isPlanned: Bool, currentToken: String, nextToken: String, willChangeSoon: Bool) {
        circularProgress.setProgress(progress, animated: isPlanned)
        tokenLabel.setToken(currentToken)
        nextTokenLabel.set(nextToken: nextToken)
        shouldMark(willChangeSoon: willChangeSoon, isPlanned: isPlanned)
    }
    
    private func shouldMark(willChangeSoon: Bool, isPlanned: Bool) {
        if useNextToken {
            if willChangeSoon {
                nextTokenLabel.showNextToken(animated: isPlanned)
            } else {
                nextTokenLabel.hideNextToken(animated: isPlanned)
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
}
