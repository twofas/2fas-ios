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

final class TokensTOTPCell: UICollectionViewCell, TokenTimerConsumer, TokensTOTPCellType {
    static let reuseIdentifier = "TokensTOTPCell"
    let autoManagable = true
    
    var didTapUnlock: ((TokenTimerConsumer) -> Void)?
    
    private let tokenLabel: TokensTokenView = {
        let view = TokensTokenView()
        view.setKind(.normal)
        return view
    }()
    private let nextTokenLabel: TokensNextTokenView = {
        let view = TokensNextTokenView()
        view.setKind(.normal)
        return view
    }()
    private let circularProgress: TokensCircleProgress = {
        let view = TokensCircleProgress()
        view.setKind(.normal)
        return view
    }()
    
    private(set) var secret: String = ""
    private var serviceTypeName: String = ""
    
    private var useNextToken = false
    private var isLocked = false
    private var shouldAnimate = true

    private var withAdditionalInfoConstraints: [NSLayoutConstraint] = []
    private var withoutAdditionalInfoConstraints: [NSLayoutConstraint] = []

    private let groupContainer = UIView()
    private let categoryView = TokensCategory()
    private var revealButton: TokensRevealButton = {
        let button = TokensRevealButton()
        button.setKind(.normal)
        return button
    }()
    
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
        setupRevealButton()
    }
    
    func update(
        name: String,
        secret: String,
        serviceTypeName: String,
        additionalInfo: String?,
        logoType: LogoType,
        category: TintColor,
        useNextToken: Bool,
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

        clearTokenMarking()
        categoryView.setColor(category)
        logoView.configure(with: logoType)
        
        isLocked = false

        self.useNextToken = useNextToken
        self.shouldAnimate = shouldAnimate
        
        nextTokenLabel.hideNextToken(animated: false)
    }
    
    func setInitial(_ state: TokenTimerInitialConsumerState) {
        switch state {
        case .locked:
            isLocked = true
            
            nextTokenLabel.hideNextToken(animated: false)
            tokenLabel.maskToken()
            circularProgress.isHidden = true
            revealButton.isHidden = false
        case .unlocked(let progress, let period, let currentToken, let nextToken, let tokenType, let willChangeSoon):
            let wasLocked = isLocked && shouldAnimate && !willChangeSoon
            isLocked = false

            circularProgress.isHidden = false
            revealButton.isHidden = true

            circularProgress.setPeriod(period)
            circularProgress.setProgress(progress, animated: false)
            tokenLabel.setToken(currentToken, tokenType: tokenType, animated: wasLocked)
            nextTokenLabel.set(nextToken: nextToken, tokenType: tokenType)
            shouldMark(willChangeSoon: willChangeSoon, isPlanned: false)
        }
    }
    
    func setUpdate(_ state: TokenTimerUpdateConsumerState) {
        switch state {
        case .locked:
            guard !isLocked else { return }
            isLocked = true
            
            nextTokenLabel.hideNextToken(animated: true)
            tokenLabel.maskToken()
            circularProgress.isHidden = true
            revealButton.isHidden = false
        case .unlocked(let progress, let isPlanned, let currentToken, let nextToken, let tokenType, let willChangeSoon):
            let blockAnimation = isLocked && willChangeSoon
            isLocked = false
            
            circularProgress.isHidden = false
            revealButton.isHidden = true
            
            circularProgress.setProgress(progress, animated: isPlanned)
            tokenLabel.setToken(currentToken, tokenType: tokenType, animated: !isPlanned && !blockAnimation)
            shouldMark(willChangeSoon: willChangeSoon, isPlanned: isPlanned && !blockAnimation)
            nextTokenLabel.set(nextToken: nextToken, tokenType: tokenType)
        }
    }
}

private extension TokensTOTPCell {
    func setupBackground() {
        contentView.backgroundColor = AppColor.backgroundsPrimary.uiColor
        backgroundColor = AppColor.backgroundsPrimary.uiColor
    }
    
    func setupLayout() {
        let tokenNegativeMargin = Spacing.SM.rawValue
        let hMargin: CGFloat = Spacing.XL.rawValue

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
            logoView.topAnchor.constraint(equalTo: contentView.topAnchor),
            logoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.addSubview(groupContainer, with: [
            groupContainer.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: Spacing.L.rawValue),
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
            tokenLabel.bottomAnchor.constraint(equalTo: groupContainer.bottomAnchor)
        ])

        withAdditionalInfoConstraints = [
            tokenLabel.topAnchor.constraint(equalTo: additionalInfoLabel.bottomAnchor, constant: tokenNegativeMargin)
        ]
        withoutAdditionalInfoConstraints = [
            tokenLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: tokenNegativeMargin)
        ]
        NSLayoutConstraint.activate(withoutAdditionalInfoConstraints)

        contentView.addSubview(nextTokenLabel, with: [
            nextTokenLabel.leadingAnchor.constraint(equalTo: tokenLabel.trailingAnchor, constant: hMargin),
            nextTokenLabel.topAnchor.constraint(equalTo: tokenLabel.topAnchor),
            nextTokenLabel.bottomAnchor.constraint(equalTo: tokenLabel.bottomAnchor)
        ])

        contentView.addSubview(accessoryContainer, with: [
            groupContainer.trailingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor, constant: -hMargin),
            accessoryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -hMargin),
            accessoryContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            accessoryContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            nextTokenLabel.trailingAnchor
                .constraint(lessThanOrEqualTo: accessoryContainer.leadingAnchor, constant: -tokenNegativeMargin)
        ])
        
        accessoryContainer.addSubview(circularProgress, with: [
            circularProgress.leadingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor),
            circularProgress.trailingAnchor.constraint(equalTo: accessoryContainer.trailingAnchor),
            circularProgress.topAnchor.constraint(greaterThanOrEqualTo: accessoryContainer.topAnchor),
            circularProgress.bottomAnchor.constraint(lessThanOrEqualTo: accessoryContainer.bottomAnchor),
            circularProgress.centerXAnchor.constraint(equalTo: accessoryContainer.centerXAnchor),
            circularProgress.centerYAnchor.constraint(equalTo: accessoryContainer.centerYAnchor)
        ])
        
        accessoryContainer.addSubview(revealButton, with: [
            revealButton.centerXAnchor.constraint(equalTo: accessoryContainer.centerXAnchor),
            revealButton.centerYAnchor.constraint(equalTo: accessoryContainer.centerYAnchor)
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

    func setupRevealButton() {
        revealButton.addTarget(self, action: #selector(ditTapReveal), for: .touchUpInside)
    }
    
    @objc
    func ditTapReveal() {
        didTapUnlock?(self)
    }
    
    func shouldMark(willChangeSoon: Bool, isPlanned: Bool) {
        if useNextToken {
            if willChangeSoon {
                nextTokenLabel.showNextToken(animated: isPlanned && shouldAnimate)
            } else {
                nextTokenLabel.hideNextToken(animated: isPlanned && shouldAnimate)
            }
        }
        if willChangeSoon {
            markToken()
        } else {
            clearTokenMarking()
        }
    }
    
    func markToken() {
        tokenLabel.mark()
        circularProgress.mark()
    }
    
    func clearTokenMarking() {
        tokenLabel.clearMarking()
        circularProgress.unmark()
    }
}
