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

final class TokensNextTokenView: UIView {
    private let animationDuration: TimeInterval = Theme.Animations.Timing.quick
    private let animationCurve = Theme.Animations.Curve.show
    
    private enum State {
        case hidden
        case animating
        case visible
    }
    
    private let nextTokenLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics(forTextStyle: .headline)
            .scaledFont(for: .systemFont(ofSize: 17, weight: .bold))
        label.adjustsFontForContentSizeCategory = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 1
        label.allowsDefaultTighteningForTruncation = true
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byTruncatingTail
        label.textColor = Theme.Colors.Text.main
        label.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        return label
    }()
    private let innerContainer = UIView()
    private let outerContainer = UIView()
    private let maskingView = UIView()
    
    private var movingConstraint: NSLayoutConstraint!
    private var lineHeight: CGFloat = 0
    private var currentState: State = .hidden
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        maskingView.backgroundColor = .black
        
        addSubview(outerContainer)
        outerContainer.pinToParent()
        outerContainer.mask = maskingView
        outerContainer.clipsToBounds = true
        
        outerContainer.addSubview(innerContainer, with: [
            innerContainer.leadingAnchor.constraint(equalTo: outerContainer.leadingAnchor),
            innerContainer.trailingAnchor.constraint(equalTo: outerContainer.trailingAnchor),
            heightAnchor.constraint(equalTo: outerContainer.heightAnchor)
        ])
        
        movingConstraint = innerContainer.topAnchor.constraint(equalTo: outerContainer.topAnchor)
        
        NSLayoutConstraint.activate([
            movingConstraint,
        ])
        
        innerContainer.addSubview(nextTokenLabel, with: [
            nextTokenLabel.leadingAnchor.constraint(equalTo: innerContainer.leadingAnchor),
            nextTokenLabel.trailingAnchor.constraint(equalTo: innerContainer.trailingAnchor),
            nextTokenLabel.topAnchor.constraint(equalTo: innerContainer.topAnchor),
            innerContainer.heightAnchor.constraint(equalTo: nextTokenLabel.heightAnchor)
        ])
    }
    
    func set(nextToken: TokenValue) {
        nextTokenLabel.text = T.Tokens.nextToken(nextToken.formattedValue)
        let tokenVO = (nextToken.components(separatedBy: "")).joined(separator: " ")
        nextTokenLabel.accessibilityValue = tokenVO
        
        updateConsts()
    }
    
    func showNextToken(animated: Bool) {
        let duration: TimeInterval = animated ? animationDuration : 0
        layoutIfNeeded()
        currentState = .animating
        movingConstraint.constant = 0
        
        UIView.animate(withDuration: duration, delay: 0, options: [animationCurve]) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.currentState = .visible
        }
    }
    
    func hideNextToken(animated: Bool) {
        let duration: TimeInterval = animated ? animationDuration : 0
        layoutIfNeeded()
        currentState = .animating
        movingConstraint.constant = -lineHeight
        
        UIView.animate(withDuration: duration, delay: 0, options: [animationCurve]) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.currentState = .hidden
            self.movingConstraint.constant = -self.lineHeight
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateConsts()
    }
    
    private func updateConsts() {
        lineHeight = nextTokenLabel.frame.height
        guard currentState == .hidden else { return }
        movingConstraint.constant = -lineHeight
    }
}
