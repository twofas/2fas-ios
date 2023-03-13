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

protocol TokenTimerConsumerWithCopy: TokenTimerConsumer {
    func copyToken() -> String?
}

final class ServiceAddedServiceContainerViewTOTP: UIView, ServiceAddedViewContaining, TokenTimerConsumerWithCopy {
    var didTapRefreshCounter: ((String) -> Void)? // not used
    private(set) var secret: String = ""
    let autoManagable = false
    
    var serviceContainerTapped: Callback?
    var editIconTapped: Callback?
    
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
    private let circularProgress = CircleProgress()
    private var tokenValue: String = ""
    
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
        
        addSubview(circularProgress, with: [
            circularProgress.widthAnchor.constraint(equalToConstant: Consts.circularProgressSize),
            circularProgress.heightAnchor.constraint(equalToConstant: Consts.circularProgressSize),
            circularProgress.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Consts.margin),
            circularProgress.centerYAnchor.constraint(equalTo: centerYAnchor),
            circularProgress.leadingAnchor.constraint(equalTo: tokenLabel.trailingAnchor, constant: Consts.margin)
        ])
        circularProgress.setClearBackground()
        setupAccessibility()
        editIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editIconAction)))
        iconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editIconAction)))
        tokenLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(serviceContainerAction)))
        
        tokenLabel.isUserInteractionEnabled = true
    }
    
    // MARK: - Public
    
    func setInitial(
        _ progress: Int,
        period: Int,
        currentToken: TokenValue,
        nextToken: TokenValue,
        willChangeSoon: Bool
    ) {
        circularProgress.setPeriod(period)
        circularProgress.setProgress(progress, animated: false)
        tokenLabel.setToken(currentToken)
        shouldMark(willChangeSoon: willChangeSoon)
        tokenValue = currentToken
    }
    
    func setUpdate(
        _ progress: Int,
        isPlanned: Bool,
        currentToken: TokenValue,
        nextToken: TokenValue,
        willChangeSoon: Bool
    ) {
        circularProgress.setProgress(progress, animated: isPlanned)
        tokenLabel.setToken(currentToken)
        shouldMark(willChangeSoon: willChangeSoon)
        tokenValue = currentToken
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
    
    private func shouldMark(willChangeSoon: Bool) {
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
    
    @objc
    private func editIconAction() {
        editIconTapped?()
    }
    
    @objc
    private func serviceContainerAction() {
        serviceContainerTapped?()
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityElements = [iconImageView, tokenLabel, circularProgress]
    }
    
    override var intrinsicContentSize: CGSize { CGSize(width: UIView.noIntrinsicMetric, height: Consts.imageSize) }
}
