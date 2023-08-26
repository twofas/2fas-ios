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

final class TokensTOTPCompactCell: UICollectionViewCell, TokenTimerConsumer, TokensTOTPCellType {
    static let reuseIdentifier = "TokensTOTPCompactCell"
    let autoManagable = true
    
    var didTapUnlock: ((TokenTimerConsumer) -> Void)?
    
    private let hMargin: CGFloat = Theme.Metrics.doubleMargin
    private let sMargin: CGFloat = Theme.Metrics.standardMargin
    private let vMargin: CGFloat = Theme.Metrics.mediumMargin
    
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
    private let nextTokenLabel: TokensNextTokenView = {
        let view = TokensNextTokenView()
        view.setKind(.compact)
        return view
    }()
    private let circularProgress: TokensCircleProgress = {
        let view = TokensCircleProgress()
        view.setKind(.compact)
        return view
    }()
    
    private(set) var secret: String = ""
    private var serviceTypeName: String = ""
    
    private var useNextToken = false
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
    private var revealButton: TokensRevealButton = {
        let button = TokensRevealButton()
        button.setKind(.compact)
        return button
    }()
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
        if let additionalInfo, !additionalInfo.isEmpty {
            additionalInfoLabel.isHidden = false
            additionalInfoLabel.setText(additionalInfo)
        } else {
            additionalInfoLabel.isHidden = true
            additionalInfoLabel.clear()
        }
        
        clearTokenMarking()
        categoryView.setColor(category)
        logoView.configure(with: logoType)

        self.useNextToken = useNextToken
        self.shouldAnimate = shouldAnimate
        
        isLocked = false
        showToken()
        
        nextTokenLabel.hideNextToken(animated: false)
    }
    
    func setInitial(_ state: TokenTimerInitialConsumerState) {
        switch state {
        case .locked:
            isLocked = true
            
            nextTokenLabel.hideNextToken(animated: false)
            tokenLabel.maskToken()
            hideToken()
            circularProgress.isHidden = true
            revealButton.isHidden = false
        case .unlocked(let progress, let period, let currentToken, let nextToken, let willChangeSoon):
            let wasLocked = isLocked && shouldAnimate && !willChangeSoon
            isLocked = false
            
            circularProgress.isHidden = false
            revealButton.isHidden = true
            circularProgress.setPeriod(period)
            circularProgress.setProgress(progress, animated: false)
            tokenLabel.setToken(currentToken, animated: wasLocked)
            nextTokenLabel.set(nextToken: nextToken)
            showToken()
            shouldMark(willChangeSoon: willChangeSoon, isPlanned: false)
        }
        updateAccessibility()
    }
    
    func setUpdate(_ state: TokenTimerUpdateConsumerState) {
        switch state {
        case .locked:
            guard !isLocked else { return }
            isLocked = true
            
            nextTokenLabel.hideNextToken(animated: true)
            tokenLabel.maskToken()
            hideToken()
            circularProgress.isHidden = true
            revealButton.isHidden = false
        case .unlocked(let progress, let isPlanned, let currentToken, let nextToken, let willChangeSoon):
            let blockAnimation = isLocked && willChangeSoon
            isLocked = false
            
            circularProgress.isHidden = false
            revealButton.isHidden = true
            circularProgress.setProgress(progress, animated: isPlanned)
            tokenLabel.setToken(currentToken, animated: !isPlanned && !blockAnimation)
            showToken()
            shouldMark(willChangeSoon: willChangeSoon, isPlanned: isPlanned && !blockAnimation)
            nextTokenLabel.set(nextToken: nextToken)
        }
        updateAccessibility()
    }
}

private extension TokensTOTPCompactCell {
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

        contentView.addSubview(nextTokenLabel, with: [
            nextTokenLabel.leadingAnchor.constraint(equalTo: tokenLabel.trailingAnchor, constant: hMargin),
            nextTokenLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vMargin)
        ])

        contentView.addSubview(accessoryContainer, with: [
            nextTokenLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -hMargin
            ),
            serviceNameLabel.trailingAnchor.constraint(
                equalTo: accessoryContainer.leadingAnchor,
                constant: -hMargin
            ),
            accessoryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sMargin),
            accessoryContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vMargin),
            accessoryContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vMargin)
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
            revealButton.leadingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor),
            revealButton.trailingAnchor.constraint(equalTo: accessoryContainer.trailingAnchor),
            revealButton.topAnchor.constraint(equalTo: accessoryContainer.topAnchor),
            revealButton.bottomAnchor.constraint(equalTo: accessoryContainer.bottomAnchor),
            revealButton.heightAnchor.constraint(greaterThanOrEqualToConstant: TokensRevealButton.size),
            revealButton.widthAnchor.constraint(equalToConstant: TokensRevealButton.size)
        ])
        
        tokenLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        nextTokenLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
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
    
    func updateAccessibility() {
        if isLocked {
            accessibilityElements = [categoryView, serviceNameLabel, additionalInfoLabel, accessoryContainer]
        } else {
            accessibilityElements = [
                categoryView,
                serviceNameLabel,
                additionalInfoLabel,
                tokenLabel,
                nextTokenLabel,
                circularProgress
            ]
        }
    }
}
