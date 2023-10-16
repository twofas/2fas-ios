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

final class TokensHOTPCompactCell: UICollectionViewCell, TokenCounterConsumer, TokensHOTPCellType {
    static let reuseIdentifier = "TokensHOTPCompactCell"
    let autoManagable = true
    
    var didTapRefreshCounter: ((Secret) -> Void)?
    
    private let hMargin: CGFloat = Theme.Metrics.doubleMargin
    private let vMargin: CGFloat = Theme.Metrics.mediumMargin
    private let manualOffset: CGFloat = 3
    
    private var serviceName2TopConstraint: NSLayoutConstraint?
    private var serviceName2AdditionalInfoConstraint: NSLayoutConstraint?
    private var serviceName2TokenConstraint: NSLayoutConstraint?
    private var serviceName2BottomConstraint: NSLayoutConstraint?
    private var serviceName2CenterYConstraint: NSLayoutConstraint?
    
    private var additionalInfo2TokenConstraint: NSLayoutConstraint?
    
    private let tokenLabel: TokensTokenView = {
        let view = TokensTokenView()
        view.setKind(.compact)
        return view
    }()
    private let refreshCounter: RefreshTokenCounter = {
        let view = RefreshTokenCounter()
        view.adjustsImageSizeForAccessibilityContentSizeCategory(false)
        return view
    }()
    
    private(set) var secret: String = ""
    private var serviceTypeName: String = ""
    private var isActive = true
    private var isLocked = false
    private var shouldAnimate = true
    
    private let categoryView = TokensCategory()
    private var logoView: TokensLogo = {
        let comp = TokensLogo()
        comp.setKind(.compact)
        return comp
    }()
    private var serviceNameLabel: TokensServiceName = {
        let comp = TokensServiceName()
        comp.setKind(.compact)
        return comp
    }()
    private var additionalInfoLabel: TokensAdditionalInfo = {
        let comp = TokensAdditionalInfo()
        comp.setKind(.compact)
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
        isLocked = false
        showToken()
        
        categoryView.setColor(category)
        logoView.configure(with: logoType)
    }

    func setInitial(_ state: TokenCounterConsumerState) {
        switch state {
        case .locked:
            isLocked = true
            isActive = true
            tokenLabel.maskToken()
            hideToken()
            refreshCounter.unlock()
            
        case .unlocked(let isRefreshLocked, let currentToken):
            isLocked = false
            isActive = !isRefreshLocked
            tokenLabel.setToken(currentToken, animated: false)
            showToken()
            if isRefreshLocked {
                refreshCounter.lock()
            } else {
                refreshCounter.unlock()
            }
        }
        updateAccessibility()
    }
    
    func setUpdate(_ state: TokenCounterConsumerState) {
        switch state {
        case .locked:
            isLocked = true
            isActive = true
            tokenLabel.maskToken()
            hideToken()
            refreshCounter.unlock()
            
        case .unlocked(let isRefreshLocked, let currentToken):
            isLocked = false
            isActive = !isRefreshLocked
            tokenLabel.setToken(currentToken, animated: shouldAnimate)
            showToken()
            if isRefreshLocked {
                refreshCounter.lock()
            } else {
                refreshCounter.unlock()
            }
        }
        updateAccessibility()
    }
}

private extension TokensHOTPCompactCell {
    func setupBackground() {
        contentView.backgroundColor = Theme.Colors.Fill.background
        backgroundColor = Theme.Colors.Fill.background
    }
    
    func setupLayout() {
        let tokenBottomOffset = 2.0
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
            logoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vMargin),
            logoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vMargin)
        ])
        
        contentView.addSubview(serviceNameLabel, with: [
            serviceNameLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: hMargin)
        ])
        
        contentView.addSubview(additionalInfoLabel, with: [
            additionalInfoLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: hMargin),
            additionalInfoLabel.widthAnchor.constraint(equalTo: serviceNameLabel.widthAnchor),
            additionalInfoLabel.heightAnchor.constraint(equalTo: serviceNameLabel.heightAnchor)
        ])
        
        contentView.addSubview(tokenLabel, with: [
            tokenLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: hMargin),
            tokenLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -vMargin + tokenBottomOffset
            )
        ])
        
        serviceName2TopConstraint = serviceNameLabel.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: vMargin
        )
        serviceName2AdditionalInfoConstraint = additionalInfoLabel.topAnchor.constraint(
            equalTo: serviceNameLabel.bottomAnchor
        )
        serviceName2TokenConstraint = tokenLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor)
        serviceName2BottomConstraint = serviceNameLabel.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -vMargin
        )
        serviceName2CenterYConstraint = serviceNameLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor)

        additionalInfo2TokenConstraint = tokenLabel.topAnchor.constraint(equalTo: additionalInfoLabel.bottomAnchor)

        serviceName2TopConstraint?.isActive = true
        serviceName2AdditionalInfoConstraint?.isActive = true
        additionalInfo2TokenConstraint?.isActive = true

        contentView.addSubview(accessoryContainer, with: [
            tokenLabel.trailingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor, constant: -hMargin),
            serviceNameLabel.trailingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor, constant: -hMargin),
            accessoryContainer.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -hMargin - manualOffset
            ),
            accessoryContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vMargin),
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
    
    func showToken() {
        tokenLabel.isHidden = false
        if additionalInfoLabel.isHidden {
            serviceName2TopConstraint?.isActive = true
            serviceName2AdditionalInfoConstraint?.isActive = false
            serviceName2TokenConstraint?.isActive = true
            serviceName2BottomConstraint?.isActive = false
            serviceName2CenterYConstraint?.isActive = false
            additionalInfo2TokenConstraint?.isActive = false
        } else {
            serviceName2TopConstraint?.isActive = true
            serviceName2AdditionalInfoConstraint?.isActive = true
            serviceName2TokenConstraint?.isActive = false
            serviceName2BottomConstraint?.isActive = false
            serviceName2CenterYConstraint?.isActive = false
            additionalInfo2TokenConstraint?.isActive = true
        }
    }
    
    func hideToken() {
        tokenLabel.isHidden = true
        if additionalInfoLabel.isHidden {
            serviceName2TopConstraint?.isActive = true
            serviceName2AdditionalInfoConstraint?.isActive = false
            serviceName2TokenConstraint?.isActive = false
            serviceName2BottomConstraint?.isActive = true
            serviceName2CenterYConstraint?.isActive = false
            additionalInfo2TokenConstraint?.isActive = false
        } else {
            serviceName2TopConstraint?.isActive = false
            serviceName2AdditionalInfoConstraint?.isActive = true
            serviceName2TokenConstraint?.isActive = false
            serviceName2BottomConstraint?.isActive = false
            serviceName2CenterYConstraint?.isActive = true
            additionalInfo2TokenConstraint?.isActive = false
        }
    }
    
    func setupConfiguration() {
        accessoryContainer.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(animateRefreshCounter))
        )
        tokenLabel.maskToken()
    }
    
    @objc
    func animateRefreshCounter() {
        guard isActive else { return }
        isActive = false
        refreshCounter.rotate()
        didTapRefreshCounter?(secret)
    }
    
    func updateAccessibility() {
        if isLocked {
            accessibilityElements = [categoryView, serviceNameLabel, additionalInfoLabel, refreshCounter]
        } else {
            accessibilityElements = [categoryView, serviceNameLabel, additionalInfoLabel, tokenLabel, refreshCounter]
        }
    }
}
