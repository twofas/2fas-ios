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

final class InfoNextTokenView: UIView {
    private let lineHeight: CGFloat = GridCollectionViewCell.Consts.smallHeight
    private let animationDuration: TimeInterval = Theme.Animations.Timing.quick
    private let animationCurve = Theme.Animations.Curve.show
    
    private let infoLabel = UILabel()
    private let nextTokenLabel = UILabel()
    private let innerContainer = UIView()
    private let outerContainer = UIView()
    private let maskingView = UIView()
    
    private var movingConstraint: NSLayoutConstraint!
    private var hasInfo = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        configure(infoLabel)
        configure(nextTokenLabel)
        
        maskingView.backgroundColor = .black
        
        addSubview(outerContainer)
        outerContainer.pinToParent()
        outerContainer.mask = maskingView
        outerContainer.clipsToBounds = true
        
        outerContainer.addSubview(innerContainer, with: [
            innerContainer.leadingAnchor.constraint(equalTo: outerContainer.leadingAnchor),
            innerContainer.trailingAnchor.constraint(equalTo: outerContainer.trailingAnchor),
            innerContainer.heightAnchor.constraint(equalToConstant: lineHeight * 2)
        ])
        
        movingConstraint = innerContainer.topAnchor.constraint(equalTo: outerContainer.topAnchor)
        
        NSLayoutConstraint.activate([
            movingConstraint,
            outerContainer.heightAnchor.constraint(equalToConstant: lineHeight)
        ])
        
        innerContainer.addSubview(nextTokenLabel, with: [
            nextTokenLabel.leadingAnchor.constraint(equalTo: innerContainer.leadingAnchor),
            nextTokenLabel.trailingAnchor.constraint(equalTo: innerContainer.trailingAnchor),
            nextTokenLabel.topAnchor.constraint(equalTo: innerContainer.topAnchor),
            nextTokenLabel.heightAnchor.constraint(equalToConstant: lineHeight)
        ])
        innerContainer.addSubview(infoLabel, with: [
            infoLabel.leadingAnchor.constraint(equalTo: innerContainer.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: innerContainer.trailingAnchor),
            infoLabel.topAnchor.constraint(equalTo: nextTokenLabel.bottomAnchor),
            infoLabel.heightAnchor.constraint(equalToConstant: lineHeight),
            infoLabel.bottomAnchor.constraint(equalTo: innerContainer.bottomAnchor)
        ])
        
        accessibilityElements = [infoLabel, nextTokenLabel]
        accessibilityTraits = .updatesFrequently
        
        nextTokenLabel.accessibilityLabel = T.Tokens.nextTokenTitle
        
        movingConstraint.constant = -lineHeight
    }
    
    private func configure(_ label: UILabel) {
        label.font = Theme.Fonts.TokenCell.description
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 1
        label.allowsDefaultTighteningForTruncation = true
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setInfoAccessibility() {
        infoLabel.isAccessibilityElement = hasInfo
    }
    
    func set(info: String?) {
        infoLabel.text = info
        if let info, !info.isEmpty {
            infoLabel.accessibilityLabel = T.Voiceover.additionalInfo(info)
            hasInfo = true
        } else {
            hasInfo = false
        }
        setInfoAccessibility()
    }
    
    func set(nextToken: TokenValue) {
        nextTokenLabel.text = T.Tokens.nextToken(nextToken.formattedValue)
        let tokenVO = (nextToken.components(separatedBy: "")).joined(separator: " ")
        nextTokenLabel.accessibilityValue = tokenVO
    }
    
    func showInfo(animated: Bool) {
        let duration: TimeInterval = animated ? animationDuration : 0
        layoutIfNeeded()
        movingConstraint.constant = -lineHeight
        setInfoAccessibility()
        nextTokenLabel.isAccessibilityElement = false
        if let element = UIAccessibility.focusedElement(using: nil) as? UILabel, element == nextTokenLabel {
            UIAccessibility.post(notification: .layoutChanged, argument: infoLabel)
        }
        UIView.animate(withDuration: duration, delay: 0, options: [animationCurve]) {
            self.layoutIfNeeded()
        }
    }
    
    func showNextToken(animated: Bool) {
        let duration: TimeInterval = animated ? animationDuration : 0
        layoutIfNeeded()
        movingConstraint.constant = 0
        infoLabel.isAccessibilityElement = false
        nextTokenLabel.isAccessibilityElement = true
        if let element = UIAccessibility.focusedElement(using: nil) as? UILabel, element == infoLabel {
            UIAccessibility.post(notification: .layoutChanged, argument: nextTokenLabel)
        }
        UIView.animate(withDuration: duration, delay: 0, options: [animationCurve]) {
            self.layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        maskingView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: lineHeight)
    }
    
    override var intrinsicContentSize: CGSize { CGSize(width: UIView.noIntrinsicMetric, height: lineHeight) }
}
