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
import Token
import Common

protocol TokenCounterConsumerWithCopy: TokenCounterConsumer {
    func copyToken() -> String?
}

final class ServiceAddedServiceContainerViewHOTP: UIView, ServiceAddedViewContaining, TokenCounterConsumerWithCopy {
    var didTapRefreshCounter: ((String) -> Void)?
    var editIconTapped: Callback?
    var serviceContainerTapped: Callback?
    
    private(set) var secret: String = ""
    let autoManagable = false
    
    private enum Consts {
        static let circularProgressSize: CGFloat = 28
        static let margin: CGFloat = 20
        static let imageSize: CGFloat = 40
        static let smallHeight: CGFloat = 15
    }
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    private let editIcon = EditCommonIcon()
    private let tokenLabel = TokenLabel()
    private let refreshCounter = RefreshTokenCounter()
    
    private var tokenValue: String?
    private var isActive = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(iconImageView, with: [
            iconImageView.topAnchor.constraint(equalTo: topAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Consts.margin),
            iconImageView.widthAnchor.constraint(equalToConstant: Consts.imageSize)
        ])
        
        addSubview(editIcon, with: [
            editIcon.centerXAnchor.constraint(equalTo: iconImageView.trailingAnchor),
            editIcon.centerYAnchor.constraint(
                equalTo: iconImageView.centerYAnchor,
                constant: -round(Theme.Metrics.serviceIconSize / 2.0)
            )
        ])
        
        addSubview(tokenLabel, with: [
            tokenLabel.topAnchor.constraint(equalTo: topAnchor, constant: Consts.smallHeight),
            tokenLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Consts.smallHeight),
            tokenLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Consts.margin)
        ])
        
        addSubview(refreshCounter, with: [
            refreshCounter.widthAnchor.constraint(equalToConstant: Consts.circularProgressSize),
            refreshCounter.heightAnchor.constraint(equalToConstant: Consts.circularProgressSize),
            refreshCounter.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Consts.margin),
            refreshCounter.centerYAnchor.constraint(equalTo: centerYAnchor),
            refreshCounter.leadingAnchor.constraint(equalTo: tokenLabel.trailingAnchor, constant: Consts.margin)
        ])
        
        setupAccessibility()
        refreshCounter.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(animateRefreshCounter))
        )
        
        tokenLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(serviceContainerAction)))
        tokenLabel.isUserInteractionEnabled = true
        
        iconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editIconAction)))
        editIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editIconAction)))
    }
    
    // MARK: - Public
    
    func setInitial(_ state: TokenCounterConsumerState) {
        switch state {
        case .locked:
            isActive = true
            tokenLabel.maskToken()
            tokenValue = nil
            
        case .unlocked(let isRefreshLocked, let currentToken):
            isActive = !isRefreshLocked
            tokenValue = currentToken
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
            tokenValue = nil
            tokenLabel.maskToken()
            
        case .unlocked(let isRefreshLocked, let currentToken):
            isActive = !isRefreshLocked
            tokenValue = currentToken
            tokenLabel.setToken(currentToken)
            if isRefreshLocked {
                refreshCounter.lock()
            } else {
                refreshCounter.unlock()
            }
        }
    }
    
    func copyToken() -> String? {
        tokenValue
    }
    
    func configure(iconImage: UIImage, serviceTypeName: String?, secret: String, showEditIcon: Bool) {
        iconImageView.image = iconImage
        iconImageView.accessibilityLabel = serviceTypeName
        iconImageView.isAccessibilityElement = true
        self.secret = secret
        editIcon.isHidden = !showEditIcon
        
        editIcon.isUserInteractionEnabled = showEditIcon
        iconImageView.isUserInteractionEnabled = showEditIcon
    }
    
    // MARK: - Private
    
    @objc
    private func animateRefreshCounter() {
        guard isActive else { return }
        isActive = false
        refreshCounter.rotate()
        didTapRefreshCounter?(secret)
    }
    
    @objc
    private func serviceContainerAction() {
        serviceContainerTapped?()
    }
    
    @objc
    private func editIconAction() {
        editIconTapped?()
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityElements = [iconImageView, tokenLabel]
    }
    
    override var intrinsicContentSize: CGSize { CGSize(width: UIView.noIntrinsicMetric, height: Consts.imageSize) }
}
