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
import Data

final class TokensHOTPCell: UICollectionViewCell, TokenCounterConsumer, TokensHOTPCellType {
    static let reuseIdentifier = "TokensHOTPCell"
    let autoManagable = true
    
    var didTapRefreshCounter: ((Secret) -> Void)?
    
    private let hMargin: CGFloat = Theme.Metrics.doubleMargin
    private let vMargin: CGFloat = Theme.Metrics.mediumMargin
    private let manualOffset: CGFloat = 3
    
    private let tokenLabel: TokensTokenView = {
        let view = TokensTokenView()
        view.setKind(.normal)
        return view
    }()
    private let nextTokenLabel = TokensNextTokenLabel()
    private let refreshCounter: RefreshTokenCounter = {
        let view = RefreshTokenCounter()
        view.adjustsImageSizeForAccessibilityContentSizeCategory(true)
        return view
    }()
    
    private(set) var secret: String = ""
    private var serviceTypeName: String = ""
    private var isActive = true
    private var shouldAnimate = true
    
    private let categoryView = TokensCategory()
    private var logoView: TokensLogo = {
        let comp = TokensLogo()
        comp.setKind(.normal)
        return comp
    }()
    private var serviceNameLabel: TokensServiceName = {
        let comp = TokensServiceName()
        comp.setKind(.normal)
        return comp
    }()
    private var additionalInfoLabel: TokensAdditionalInfo = {
        let comp = TokensAdditionalInfo()
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
    }
    
    func update(
        name: String,
        secret: String,
        serviceTypeName: String,
        additionalInfo: String?,
        logoType: LogoType,
        category: TintColor,
        shouldAnimate: Bool
    ) {
        tokenLabel.clear()
        serviceNameLabel.setText(name)
        self.secret = secret
        self.serviceTypeName = serviceTypeName
        if let additionalInfo, !additionalInfo.isEmpty {
            additionalInfoLabel.isHidden = false
            additionalInfoLabel.setText(additionalInfo)
        } else {
            additionalInfoLabel.isHidden = true
            additionalInfoLabel.clear()
        }
        
        self.shouldAnimate = shouldAnimate
        
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
            tokenLabel.setToken(currentToken, animated: false)
            if isRefreshLocked {
                refreshCounter.lock()
            } else {
                refreshCounter.unlock()
            }
        }
    }
    
    func setUpdate(_ state: TokenCounterConsumerState) {
        switch state {
        case .locked:
            isActive = true
            tokenLabel.maskToken()
            refreshCounter.unlock()
            
        case .unlocked(let isRefreshLocked, let currentToken):
            isActive = !isRefreshLocked
            tokenLabel.setToken(currentToken, animated: shouldAnimate)
            if isRefreshLocked {
                refreshCounter.lock()
            } else {
                refreshCounter.unlock()
            }
        }
    }
}

private extension TokensHOTPCell {
    func setupBackground() {
        contentView.backgroundColor = Theme.Colors.Fill.background
        backgroundColor = Theme.Colors.Fill.background
    }
    
    func setupLayout() {
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
            accessoryContainer.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -hMargin - manualOffset
            ),
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
            refreshCounter.centerYAnchor.constraint(equalTo: accessoryContainer.centerYAnchor),
            refreshCounter.widthAnchor.constraint(equalTo: accessoryContainer.widthAnchor)
        ])
        
        tokenLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        tokenLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        tokenLabel.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
    }
    
    func setupConfiguration() {
        accessoryContainer.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(animateRefreshCounter))
        )
        tokenLabel.maskToken()
        nextTokenLabel.textColor = Theme.Colors.Fill.background.withAlphaComponent(0.1)
        nextTokenLabel.text = TokenValue.empty
        nextTokenLabel.isAccessibilityElement = false
    }
    
    @objc
    func animateRefreshCounter() {
        guard isActive else { return }
        isActive = false
        refreshCounter.rotate()
        didTapRefreshCounter?(secret)
    }
}
