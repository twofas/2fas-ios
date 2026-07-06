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
    
    private let hMargin: CGFloat = Spacing.XL.rawValue
    private let sMargin: CGFloat = Spacing.M.rawValue
    private let vMargin: CGFloat = Spacing.L.rawValue
    private let manualOffset: CGFloat = 3
    
    private var showTokenWithAdditionalInfoConstraints: [NSLayoutConstraint] = []
    private var showTokenWithoutAdditionalInfoConstraints: [NSLayoutConstraint] = []
    private var hideTokenWithAdditionalInfoConstraints: [NSLayoutConstraint] = []
    private var hideTokenWithoutAdditionalInfoConstraints: [NSLayoutConstraint] = []

    private var hasAdditionalInfo = false
    
    private let tokenLabel: TokensTokenView = {
        let view = TokensTokenView()
        view.setKind(.compact)
        return view
    }()
    private let refreshCounter: RefreshTokenCounter = {
        let view = RefreshTokenCounter()
        view.adjustsImageSizeForAccessibilityContentSizeCategory(false)
        view.setKind(.compact)
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
        let trimmedAdditionalInfo = additionalInfo?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmedAdditionalInfo.isEmpty {
            additionalInfoLabel.isHidden = false
            additionalInfoLabel.setText(trimmedAdditionalInfo)
            hasAdditionalInfo = true
        } else {
            additionalInfoLabel.isHidden = true
            additionalInfoLabel.clear()
            hasAdditionalInfo = false
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
            tokenLabel.setToken(currentToken, tokenType: .hotp, animated: false)
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
            tokenLabel.setToken(currentToken, tokenType: .hotp, animated: shouldAnimate)
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
            additionalInfoLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: hMargin)
        ])

        contentView.addSubview(tokenLabel, with: [
            tokenLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: hMargin),
            tokenLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -vMargin + tokenBottomOffset
            )
        ])

        let serviceNameTop = serviceNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vMargin)
        let serviceNameBottom = serviceNameLabel.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -vMargin
        )
        let serviceNameCenterY = serviceNameLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor)
        let tokenFromServiceName = tokenLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor)
        let tokenFromAdditionalInfo = tokenLabel.topAnchor.constraint(equalTo: additionalInfoLabel.bottomAnchor)
        let additionalInfoTop = additionalInfoLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor)
        let additionalInfoWidth = additionalInfoLabel.widthAnchor.constraint(equalTo: serviceNameLabel.widthAnchor)
        let additionalInfoHeight = additionalInfoLabel.heightAnchor.constraint(equalTo: serviceNameLabel.heightAnchor)

        showTokenWithAdditionalInfoConstraints = [
            serviceNameTop,
            additionalInfoTop,
            additionalInfoWidth,
            additionalInfoHeight,
            tokenFromAdditionalInfo
        ]
        showTokenWithoutAdditionalInfoConstraints = [
            serviceNameTop,
            tokenFromServiceName
        ]
        hideTokenWithAdditionalInfoConstraints = [
            serviceNameCenterY,
            additionalInfoTop,
            additionalInfoWidth,
            additionalInfoHeight
        ]
        hideTokenWithoutAdditionalInfoConstraints = [
            serviceNameTop,
            serviceNameBottom
        ]

        NSLayoutConstraint.activate(showTokenWithoutAdditionalInfoConstraints)

        contentView.addSubview(accessoryContainer, with: [
            tokenLabel.trailingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor, constant: -hMargin),
            serviceNameLabel.trailingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor, constant: -hMargin),
            accessoryContainer.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -hMargin + 4
            ),
            accessoryContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vMargin),
            accessoryContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vMargin)
        ])
        
        accessoryContainer.addSubview(refreshCounter, with: [
            refreshCounter.leadingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor),
            refreshCounter.trailingAnchor.constraint(equalTo: accessoryContainer.trailingAnchor),
            refreshCounter.centerYAnchor.constraint(equalTo: accessoryContainer.centerYAnchor),
            refreshCounter.widthAnchor.constraint(equalToConstant: RefreshTokenCounter.sizeCompact),
            refreshCounter.heightAnchor.constraint(equalToConstant: RefreshTokenCounter.sizeCompact)
        ])
        
        tokenLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        tokenLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        tokenLabel.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
    }
    
    func showToken() {
        tokenLabel.isHidden = false
        deactivateAllVerticalGroups()
        if hasAdditionalInfo {
            NSLayoutConstraint.activate(showTokenWithAdditionalInfoConstraints)
        } else {
            NSLayoutConstraint.activate(showTokenWithoutAdditionalInfoConstraints)
        }
    }

    func hideToken() {
        tokenLabel.isHidden = true
        deactivateAllVerticalGroups()
        if hasAdditionalInfo {
            NSLayoutConstraint.activate(hideTokenWithAdditionalInfoConstraints)
        } else {
            NSLayoutConstraint.activate(hideTokenWithoutAdditionalInfoConstraints)
        }
    }

    private func deactivateAllVerticalGroups() {
        NSLayoutConstraint.deactivate(showTokenWithAdditionalInfoConstraints)
        NSLayoutConstraint.deactivate(showTokenWithoutAdditionalInfoConstraints)
        NSLayoutConstraint.deactivate(hideTokenWithAdditionalInfoConstraints)
        NSLayoutConstraint.deactivate(hideTokenWithoutAdditionalInfoConstraints)
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
