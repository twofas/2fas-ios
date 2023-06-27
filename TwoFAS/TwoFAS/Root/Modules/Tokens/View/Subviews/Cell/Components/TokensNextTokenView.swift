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
    private let animationCurve = UIView.AnimationOptions.curveEaseInOut
    
    private enum State {
        case hidden
        case animating
        case visible
    }
    
    private let nextTokenLabel = TokensNextTokenLabel()
    private let innerContainer = UIView()
    private let outerContainer = UIView()
    private let maskingView = UIView()
    
    private var movingConstraint: NSLayoutConstraint!
    private var lineHeight: CGFloat = 0
    private var lineWidth: CGFloat = 0
    private var currentState: State = .hidden
    private var kind: TokensCellKind = .normal
    
    private var options: UIView.AnimationOptions = []
    
    private var currentValue: TokenValue?
    
    private var constraintValue: CGFloat {
        switch kind {
        case .compact, .edit: return -lineWidth
        case .normal: return -lineHeight
        }
    }
    
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
        options = [animationCurve, .beginFromCurrentState]
        
        addSubview(outerContainer)
        outerContainer.pinToParent()
        outerContainer.mask = maskingView
        outerContainer.clipsToBounds = true
        
        outerContainer.addSubview(innerContainer, with: [
            innerContainer.widthAnchor.constraint(equalTo: outerContainer.widthAnchor),
            heightAnchor.constraint(equalTo: outerContainer.heightAnchor)
        ])
        
        innerContainer.addSubview(nextTokenLabel, with: [
            nextTokenLabel.leadingAnchor.constraint(equalTo: innerContainer.leadingAnchor),
            nextTokenLabel.trailingAnchor.constraint(equalTo: innerContainer.trailingAnchor),
            nextTokenLabel.topAnchor.constraint(equalTo: innerContainer.topAnchor),
            innerContainer.heightAnchor.constraint(equalTo: nextTokenLabel.heightAnchor),
            outerContainer.heightAnchor.constraint(equalTo: innerContainer.heightAnchor)
        ])
        
        nextTokenLabel.text = TokenValue.empty
        setNextTokenHidden()
        
        nextTokenLabel.isAccessibilityElement = false
    }
    
    func set(nextToken: TokenValue) {
        guard currentState != .animating, currentValue != nextToken else { return }
        currentValue = nextToken

        nextTokenLabel.text = nextToken.formattedValue
        let tokenVO = (nextToken.components(separatedBy: "")).joined(separator: " ")
        accessibilityValue = T.Tokens.nextToken(tokenVO)
        
        updateConsts()
    }
    
    func showNextToken(animated: Bool) {
        guard currentState == .hidden || currentState == .animating else {
            nextTokenLabel.alpha = 1
            movingConstraint.constant = 0
            layoutIfNeeded()
            return
        }
        
        isAccessibilityElement = true
       
        nextTokenLabel.textColor = Theme.Colors.Text.main
        
        if animated {
            currentState = .animating
            nextTokenLabel.alpha = 0
            movingConstraint.constant = 0
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: options) {
                self.layoutIfNeeded()
                self.nextTokenLabel.alpha = 1
            } completion: { _ in
                self.currentState = .visible
                self.movingConstraint.constant = 0
            }
        } else {
            nextTokenLabel.alpha = 1
            currentState = .visible
            movingConstraint.constant = 0
            
            layoutIfNeeded()
        }
    }
    
    func hideNextToken(animated: Bool) {
        guard currentState == .visible || currentState == .animating else {
            setNextTokenHidden()
            return
        }
        
        isAccessibilityElement = false
        currentState = .animating
        nextTokenLabel.alpha = 1
        movingConstraint.constant = constraintValue
        
        if animated {
            UIView.animate(withDuration: animationDuration, delay: 0, options: options) {
                self.layoutIfNeeded()
                self.nextTokenLabel.alpha = 0
            } completion: { _ in
                self.currentState = .hidden
                self.movingConstraint.constant = self.constraintValue
            }
        } else {
            setNextTokenHidden()
            
            movingConstraint.constant = constraintValue
            currentState = .hidden
            layoutIfNeeded()
        }
    }
    
    func setKind(_ kind: TokensCellKind) {
        self.kind = kind
        switch kind {
        case .compact:
            movingConstraint = innerContainer.leadingAnchor.constraint(equalTo: outerContainer.leadingAnchor)
            NSLayoutConstraint.activate([
                innerContainer.topAnchor.constraint(equalTo: outerContainer.topAnchor),
                movingConstraint
            ])
            
            nextTokenLabel.setContentCompressionResistancePriority(.defaultHigh + 2, for: .horizontal)
        case .normal:
            movingConstraint = innerContainer.topAnchor.constraint(equalTo: outerContainer.topAnchor)
            NSLayoutConstraint.activate([
                innerContainer.leadingAnchor.constraint(equalTo: outerContainer.leadingAnchor),
                movingConstraint
            ])
        default:
            break
        }
        nextTokenLabel.setKind(kind)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateConsts()
    }
    
    private func setNextTokenHidden() {
        nextTokenLabel.textColor = Theme.Colors.Fill.background.withAlphaComponent(0.1)
        nextTokenLabel.alpha = 0.1
    }
    
    private func updateConsts() {
        lineHeight = nextTokenLabel.frame.height
        lineWidth = nextTokenLabel.frame.width
        maskingView.frame = CGRect(origin: .zero, size: outerContainer.frame.size)
        
        guard currentState == .hidden else { return }
        movingConstraint.constant = constraintValue
    }
}
