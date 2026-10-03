//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

final class TokensTOTPTokenView: UIView {
    private let tokenView = TokensTokenView()
    private let nextTokenView = TokensNextTokenView()

    private let nextTokenLeadingSpacing = Spacing.L.rawValue

    private var kindConstraints: [NSLayoutConstraint] = []
    private var useNextToken = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addSubview(tokenView, with: [
            tokenView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tokenView.topAnchor.constraint(equalTo: topAnchor),
            tokenView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        addSubview(nextTokenView, with: [
            nextTokenView.leadingAnchor.constraint(equalTo: tokenView.trailingAnchor, constant: nextTokenLeadingSpacing)
        ])

        tokenView.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)

        accessibilityElements = [tokenView, nextTokenView]
    }

    override var forFirstBaselineLayout: UIView { tokenView }
    override var forLastBaselineLayout: UIView { tokenView }

    func setKind(_ kind: TokensCellKind) {
        tokenView.setKind(kind)
        nextTokenView.setKind(kind)

        NSLayoutConstraint.deactivate(kindConstraints)
        switch kind {
        case .normal:
            kindConstraints = [
                nextTokenView.lastBaselineAnchor.constraint(equalTo: tokenView.lastBaselineAnchor),
                nextTokenView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
            ]
            tokenView.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
            tokenView.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        case .compact:
            kindConstraints = [
                nextTokenView.lastBaselineAnchor.constraint(equalTo: tokenView.lastBaselineAnchor, constant: -1),
                nextTokenView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]
            nextTokenView.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        case .edit, .pass:
            kindConstraints = [
                nextTokenView.lastBaselineAnchor.constraint(equalTo: tokenView.lastBaselineAnchor),
                nextTokenView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
            ]
        }
        NSLayoutConstraint.activate(kindConstraints)
    }

    /// Prepares the view for a new token (e.g. on cell reuse).
    func reset(useNextToken: Bool) {
        self.useNextToken = useNextToken
        tokenView.clear()
        tokenView.clearMarking()
        nextTokenView.hideNextToken(animated: false)
    }

    func lock(animated: Bool) {
        nextTokenView.hideNextToken(animated: animated)
        tokenView.maskToken()
    }

    /// - Parameters:
    ///   - animateToken: animates appearance of the current token (e.g. after unlocking)
    ///   - animateTransition: animates marking and showing/hiding of the next token
    func setToken(
        _ token: TokenValue,
        nextToken: TokenValue,
        tokenType: TokenType,
        willChangeSoon: Bool,
        animateToken: Bool,
        animateTransition: Bool
    ) {
        tokenView.setToken(token, tokenType: tokenType, animated: animateToken)
        setWillChangeSoon(willChangeSoon, animated: animateTransition)
        // Set after show/hide so the next token isn't replaced while it's animating out
        nextTokenView.set(nextToken: nextToken, tokenType: tokenType)
    }
}

private extension TokensTOTPTokenView {
    func setWillChangeSoon(_ willChangeSoon: Bool, animated: Bool) {
        if useNextToken {
            if willChangeSoon {
                nextTokenView.showNextToken(animated: animated)
            } else {
                nextTokenView.hideNextToken(animated: animated)
            }
        }
        if willChangeSoon {
            tokenView.mark()
        } else {
            tokenView.clearMarking()
        }
    }
}
