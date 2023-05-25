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
    private let vMargin: CGFloat = Theme.Metrics.mediumMargin
    
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
    
    private let categoryView = TokensCategoryComponent()
    private var logoView: TokensLogoComponent = {
        let comp = TokensLogoComponent()
        comp.setKind(.compact)
        return comp
    }()
    private var serviceNameLabel: TokensServiceNameComponent = {
        let comp = TokensServiceNameComponent()
        comp.setKind(.compact)
        return comp
    }()
    private var additionalInfoLabel: TokensAdditionalInfoComponent = {
        let comp = TokensAdditionalInfoComponent()
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
        //        setupAccessibility() // TODO: Add accessibility
    }
    
    private func setupBackground() {
        contentView.backgroundColor = Theme.Colors.Fill.background
        backgroundColor = Theme.Colors.Fill.background
    }
    
    private func setupLayout() {
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
            serviceNameLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: hMargin),
            serviceNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vMargin)
        ])
        
        contentView.addSubview(additionalInfoLabel, with: [
            additionalInfoLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: hMargin),
            additionalInfoLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor),
            additionalInfoLabel.widthAnchor.constraint(equalTo: serviceNameLabel.widthAnchor)
        ])
        
        contentView.addSubview(tokenLabel, with: [
            additionalInfoLabel.bottomAnchor.constraint(equalTo: tokenLabel.topAnchor),
            tokenLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: hMargin),
            tokenLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -vMargin + tokenBottomOffset
            )
        ])
        
        contentView.addSubview(nextTokenLabel, with: [
            nextTokenLabel.leadingAnchor.constraint(equalTo: tokenLabel.trailingAnchor, constant: hMargin),
            nextTokenLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vMargin)
        ])

        contentView.addSubview(accessoryContainer, with: [
            nextTokenLabel.trailingAnchor.constraint(
                greaterThanOrEqualTo: accessoryContainer.leadingAnchor,
                constant: -hMargin
            ),
            serviceNameLabel.trailingAnchor.constraint(
                greaterThanOrEqualTo: accessoryContainer.leadingAnchor,
                constant: -hMargin
            ),
            accessoryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -hMargin),
            accessoryContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vMargin),
            accessoryContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vMargin)
        ])
        
        accessoryContainer.addSubview(circularProgress, with: [
            circularProgress.leadingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor),
            circularProgress.trailingAnchor.constraint(equalTo: accessoryContainer.trailingAnchor),
            circularProgress.topAnchor.constraint(greaterThanOrEqualTo: accessoryContainer.topAnchor),
            circularProgress.bottomAnchor.constraint(lessThanOrEqualTo: accessoryContainer.bottomAnchor),
            circularProgress.centerYAnchor.constraint(equalTo: accessoryContainer.centerYAnchor)
        ])
        
        tokenLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        nextTokenLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        
        // TODO: Remove - for tests only
        serviceNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        serviceNameLabel.isUserInteractionEnabled = true
        // Add eye icon, add lock from global var
    }
    
    @objc func didTap() {
        didTapUnlock?(self)
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
        if let additionalInfo {
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
        
        if useNextToken {
            nextTokenLabel.isHidden = false
        } else {
            nextTokenLabel.isHidden = true
            nextTokenLabel.set(nextToken: .empty)
        }
        self.shouldAnimate = shouldAnimate
    }
    
    func setInitial(_ state: TokenTimerInitialConsumerState) {
        switch state {
        case .locked:
            isLocked = true
            
            nextTokenLabel.hideNextToken(animated: false)
            tokenLabel.maskToken()
            //circularProgress.isHidden = true
            // show eye
        case .unlocked(let progress, let period, let currentToken, let nextToken, let willChangeSoon):
            isLocked = false
            
            //circularProgress.isHidden = false
            circularProgress.setPeriod(period)
            circularProgress.setProgress(progress, animated: false)
            tokenLabel.setToken(currentToken)
            nextTokenLabel.set(nextToken: nextToken)
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
            //circularProgress.isHidden = true
            // show eye
        case .unlocked(let progress, let isPlanned, let currentToken, let nextToken, let willChangeSoon):
            isLocked = false
            
            //circularProgress.isHidden = false
            circularProgress.setProgress(progress, animated: isPlanned)
            tokenLabel.setToken(currentToken)
            shouldMark(willChangeSoon: willChangeSoon, isPlanned: isPlanned)
            nextTokenLabel.set(nextToken: nextToken)
        }
    }
    
    private func shouldMark(willChangeSoon: Bool, isPlanned: Bool) {
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
    
    private func markToken() {
        tokenLabel.mark()
        circularProgress.mark()
    }
    
    private func clearTokenMarking() {
        tokenLabel.clearMarking()
        circularProgress.unmark()
    }
}
