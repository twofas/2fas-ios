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
    
    private let hMargin: CGFloat = Spacing.XL.rawValue
    private let vMargin: CGFloat = Spacing.L.rawValue

    private let tokenLabel: TokensTokenView = {
        let view = TokensTokenView()
        view.setKind(.normal)
        return view
    }()
    private let refreshCounter: RefreshTokenCounter = {
        let view = RefreshTokenCounter()
        view.adjustsImageSizeForAccessibilityContentSizeCategory(true)
        view.setKind(.normal)
        return view
    }()
    
    private(set) var secret: String = ""
    private var serviceTypeName: String = ""
    private var isActive = true
    private var shouldAnimate = true

    private var withAdditionalInfoConstraints: [NSLayoutConstraint] = []
    private var withoutAdditionalInfoConstraints: [NSLayoutConstraint] = []

    private let groupContainer = UIView()
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
        line.backgroundColor = AppColor.separatorsOpaque.uiColor
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
        } else {
            additionalInfoLabel.isHidden = true
            additionalInfoLabel.clear()
        }
        applyAdditionalInfoLayout(hasAdditionalInfo: !trimmedAdditionalInfo.isEmpty)

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
            tokenLabel.setToken(currentToken, tokenType: .hotp, animated: false)
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
            tokenLabel.setToken(currentToken, tokenType: .hotp, animated: shouldAnimate)
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
        contentView.backgroundColor = AppColor.backgroundsPrimary.uiColor
        backgroundColor = AppColor.backgroundsPrimary.uiColor
    }
    
    func setupLayout() {
        let tokenTopSpacing = Spacing.SM.rawValue
        let logoViewTopOffset = vMargin
        let accessoryContainerTopOffset = vMargin
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
        
        contentView.addSubview(groupContainer, with: [
            groupContainer.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: hMargin),
            groupContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        let groupTopMargin = groupContainer.topAnchor.constraint(
            greaterThanOrEqualTo: contentView.topAnchor,
            constant: Spacing.XL.rawValue
        )
        groupTopMargin.priority = .defaultHigh
        let groupBottomMargin = groupContainer.bottomAnchor.constraint(
            lessThanOrEqualTo: contentView.bottomAnchor,
            constant: -Spacing.XL.rawValue
        )
        groupBottomMargin.priority = .defaultHigh
        NSLayoutConstraint.activate([groupTopMargin, groupBottomMargin])

        groupContainer.addSubview(serviceNameLabel, with: [
            serviceNameLabel.leadingAnchor.constraint(equalTo: groupContainer.leadingAnchor),
            serviceNameLabel.trailingAnchor.constraint(equalTo: groupContainer.trailingAnchor),
            serviceNameLabel.topAnchor.constraint(equalTo: groupContainer.topAnchor)
        ])

        groupContainer.addSubview(additionalInfoLabel, with: [
            additionalInfoLabel.leadingAnchor.constraint(equalTo: groupContainer.leadingAnchor),
            additionalInfoLabel.trailingAnchor.constraint(equalTo: groupContainer.trailingAnchor),
            additionalInfoLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor)
        ])

        groupContainer.addSubview(tokenLabel, with: [
            tokenLabel.leadingAnchor.constraint(equalTo: groupContainer.leadingAnchor),
            tokenLabel.trailingAnchor.constraint(equalTo: groupContainer.trailingAnchor),
            tokenLabel.bottomAnchor.constraint(equalTo: groupContainer.bottomAnchor)
        ])

        withAdditionalInfoConstraints = [
            tokenLabel.topAnchor.constraint(equalTo: additionalInfoLabel.bottomAnchor, constant: tokenTopSpacing)
        ]
        withoutAdditionalInfoConstraints = [
            tokenLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: tokenTopSpacing)
        ]
        NSLayoutConstraint.activate(withoutAdditionalInfoConstraints)

        contentView.addSubview(accessoryContainer, with: [
            groupContainer.trailingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor, constant: -hMargin),
            accessoryContainer.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -hMargin + 4
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
            refreshCounter.centerYAnchor.constraint(equalTo: accessoryContainer.centerYAnchor),
            refreshCounter.widthAnchor.constraint(equalToConstant: RefreshTokenCounter.sizeNormal),
            refreshCounter.heightAnchor.constraint(equalToConstant: RefreshTokenCounter.sizeNormal)
        ])
        
        tokenLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        tokenLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        tokenLabel.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
    }
    
    func applyAdditionalInfoLayout(hasAdditionalInfo: Bool) {
        NSLayoutConstraint.deactivate(withAdditionalInfoConstraints)
        NSLayoutConstraint.deactivate(withoutAdditionalInfoConstraints)
        if hasAdditionalInfo {
            NSLayoutConstraint.activate(withAdditionalInfoConstraints)
        } else {
            NSLayoutConstraint.activate(withoutAdditionalInfoConstraints)
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
}
