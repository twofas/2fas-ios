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

final class GridViewCounterItemCell: GridCollectionViewCell, TokenCounterConsumer {
    static let reuseIdentifier = "GridViewCounterItemCell"
    
    let autoManagable = true
    var didTapRefreshCounter: ((Secret) -> Void)?
    
    private enum ViewItemConsts {
        static let circularProgressSize: CGFloat = 28
        static let stackViewLeading: CGFloat = 80
        static let tokenHeight: CGFloat = 60
    }
    private let tokenLabel = TokenLabel()
    private let refreshCounter = RefreshTokenCounter()
    
    private(set) var secret: String = ""
    private var serviceTypeName: String = ""
    private var isActive = true
    
    func update(
        name: String,
        secret: String,
        serviceTypeName: String,
        additionalInfo: String,
        iconType: IconType,
        category: TintColor
    ) {
        tokenLabel.clear()
        nameLabel.text = name
        self.secret = secret
        self.serviceTypeName = serviceTypeName
        infoNextToken.set(info: additionalInfo)
        categoryView.backgroundColor = category.color
        categoryView.accessibilityLabel = T.Voiceover.badgeColor(category.localizedName)
        configureIcon(with: iconType, serviceTypeName: serviceTypeName)
        setupAccessibility()
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
    
    override func setupLayout() {
        super.setupLayout()
        tokenLabel.maskToken()
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
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Consts.smallHeight),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Consts.smallHeight),
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
        
        contentView.addSubview(refreshCounter, with: [
            refreshCounter.widthAnchor.constraint(equalToConstant: ViewItemConsts.circularProgressSize),
            refreshCounter.heightAnchor.constraint(equalToConstant: ViewItemConsts.circularProgressSize),
            refreshCounter.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Consts.margin),
            refreshCounter.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.heightAnchor.constraint(equalToConstant: Consts.smallHeight),
            tokenLabel.heightAnchor.constraint(equalToConstant: ViewItemConsts.tokenHeight),
            infoNextToken.heightAnchor.constraint(equalToConstant: Consts.smallHeight),
            stackView.trailingAnchor.constraint(
                lessThanOrEqualTo: refreshCounter.leadingAnchor,
                constant: -Consts.margin
            )
        ])
        
        setupConfiguration()
    }
    
    private func setupConfiguration() {
        refreshCounter.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(animateRefreshCounter))
        )
    }
    
    @objc
    private func animateRefreshCounter() {
        guard isActive else { return }
        isActive = false
        refreshCounter.rotate()
        didTapRefreshCounter?(secret)
    }
    
    override func setupAccessibility() {
        super.setupAccessibility()
        
        var accViews: [UIView] = [categoryView]
        if let current = currentAccessibilityIcon {
            accViews.append(current)
        }
        accViews.append(contentsOf: [nameLabel, tokenLabel, infoNextToken])
        accessibilityElements = accViews
    }
}
