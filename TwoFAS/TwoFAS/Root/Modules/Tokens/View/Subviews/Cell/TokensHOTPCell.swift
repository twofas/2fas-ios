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

final class TokensHOTPCell: UICollectionViewCell, TokenCounterConsumer, TokensHOTPCellType {
    static let reuseIdentifier = "TokensHOTPCell"
    let autoManagable = true
    
    var didTapRefreshCounter: ((Secret) -> Void)?
    
    private let hMargin: CGFloat = Theme.Metrics.doubleMargin
    private let vMargin: CGFloat = Theme.Metrics.mediumMargin
    
    private let tokenLabel = TokensTokenView()
    private let nextTokenLabel = TokensNextTokenLabel()
    private let refreshCounter: RefreshTokenCounter = {
        let view = RefreshTokenCounter()
        view.adjustsImageSizeForAccessibilityContentSizeCategory(true)
        return view
    }()

    private(set) var secret: String = ""
    private var serviceTypeName: String = ""
    private var isActive = true
        
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
    private let accessoryContainer = UIView()
    private let separator: UIView = {
        let line = UIView()
        line.backgroundColor = Theme.Colors.Line.separator
        line.isAccessibilityElement = false
        line.isUserInteractionEnabled = false
        return line
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
        setupBackground()
        setupLayout()
        setupConfiguration()
        //        setupAccessibility() // TODO: Add accessibility
    }
    
    private func setupBackground() {
        contentView.backgroundColor = Theme.Colors.Fill.background
        backgroundColor = Theme.Colors.Fill.background
    }
    
    private func setupLayout() {
        let tokenNegativeMargin = round(hMargin / 4.0)
        let logoViewTopOffset = vMargin + 14.0
        let accessoryContainerTopOffset = vMargin + 16.0
        contentView.addSubview(separator, with: [
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: Theme.Metrics.separatorHeight),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.addSubview(categoryView, with: [
            categoryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryView.topAnchor.constraint(equalTo: contentView.topAnchor),
            categoryView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.addSubview(logoView, with: [
            logoView.leadingAnchor.constraint(equalTo: categoryView.trailingAnchor, constant: hMargin),
            logoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: logoViewTopOffset),
            logoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vMargin)
        ])
        
        contentView.addSubview(serviceNameLabel, with: [
            serviceNameLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: hMargin),
            serviceNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vMargin)
        ])
        
        contentView.addSubview(additionalInfoLabel, with: [
            additionalInfoLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: hMargin),
            additionalInfoLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor),
            additionalInfoLabel.widthAnchor.constraint(equalTo: serviceNameLabel.widthAnchor)
        ])
        
        contentView.addSubview(tokenLabel, with: [
            additionalInfoLabel.bottomAnchor.constraint(equalTo: tokenLabel.topAnchor, constant: tokenNegativeMargin),
            tokenLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: hMargin),
            tokenLabel.widthAnchor.constraint(equalTo: serviceNameLabel.widthAnchor)
        ])
        
        contentView.addSubview(nextTokenLabel, with: [
            nextTokenLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: hMargin),
            nextTokenLabel.widthAnchor.constraint(equalTo: serviceNameLabel.widthAnchor),
            nextTokenLabel.topAnchor.constraint(equalTo: tokenLabel.bottomAnchor, constant: -tokenNegativeMargin),
            nextTokenLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vMargin)
        ])

        contentView.addSubview(accessoryContainer, with: [
            serviceNameLabel.trailingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor, constant: -hMargin),
            accessoryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -hMargin),
            accessoryContainer.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: accessoryContainerTopOffset
            ),
            accessoryContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vMargin)
        ])
        
        accessoryContainer.addSubview(refreshCounter, with: [
            refreshCounter.leadingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor),
            refreshCounter.trailingAnchor.constraint(equalTo: accessoryContainer.trailingAnchor),
            refreshCounter.topAnchor.constraint(greaterThanOrEqualTo: accessoryContainer.topAnchor),
            refreshCounter.bottomAnchor.constraint(lessThanOrEqualTo: accessoryContainer.bottomAnchor),
            refreshCounter.centerYAnchor.constraint(equalTo: accessoryContainer.centerYAnchor)
        ])
        
        tokenLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        tokenLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        tokenLabel.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
    }
    
    func update(
        name: String,
        secret: String,
        serviceTypeName: String,
        additionalInfo: String?,
        logoType: LogoType,
        category: TintColor
    ) {
        tokenLabel.clear()
        serviceNameLabel.setText(name)
        self.secret = secret
        self.serviceTypeName = serviceTypeName
        if let additionalInfo {
            additionalInfoLabel.isHidden = false
            additionalInfoLabel.setText(additionalInfo)
        } else {
            additionalInfoLabel.isHidden = true
            additionalInfoLabel.clear()
        }
        
        categoryView.setColor(category)
        logoView.configure(with: logoType)
    }

    func setInitial(_ state: TokenCounterConsumerState) {
        switch state {
        case .locked:
            isActive = true
            tokenLabel.maskToken()
            refreshCounter.unlock()
            
        case .unlocked(let isRefreshLocked, let currentToken):
            isActive = !isRefreshLocked
            tokenLabel.setToken(currentToken)
            if isRefreshLocked {
                refreshCounter.lock()
            } else {
                refreshCounter.unlock()
            }
        }
    }
    
    func setUpdate(_ state: TokenCounterConsumerState, isPlanned: Bool) {
        switch state {
        case .locked:
            isActive = true
            tokenLabel.maskToken()
            refreshCounter.unlock()
            
        case .unlocked(let isRefreshLocked, let currentToken):
            isActive = !isRefreshLocked
            tokenLabel.setToken(currentToken)
            if isRefreshLocked {
                refreshCounter.lock()
            } else {
                refreshCounter.unlock()
            }
        }
    }
    
    private func setupConfiguration() {
        accessoryContainer.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(animateRefreshCounter))
        )
        tokenLabel.maskToken()
        nextTokenLabel.isHidden = true
        nextTokenLabel.text = TokenValue.empty
    }
    
    @objc
    private func animateRefreshCounter() {
        guard isActive else { return }
        isActive = false
        refreshCounter.rotate()
        didTapRefreshCounter?(secret)
    }
    
//    func setupAccessibility() {
//        super.setupAccessibility()
//
//        var accViews: [UIView] = [categoryView]
//        if let current = currentAccessibilityIcon {
//            accViews.append(current)
//        }
//        accViews.append(contentsOf: [nameLabel, tokenLabel, infoNextToken])
//        accessibilityElements = accViews
//    }
}
