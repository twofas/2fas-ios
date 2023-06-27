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

final class TokensTokenView: UIView {
    private var displayLink: CADisplayLink?
    
    private let maskedText = "••• •••"
    private let carret = "_"
    private let invisibleSpace = " "
    
    private var isAnimating: Bool {
        displayLink != nil
    }
    private var currentText: String = ""
    
    let start: Double = 0
    let duration: CFTimeInterval = 0.7

    var end: Double = 0
    var startTime: CFTimeInterval = 0
    
    private let tokenLabel = TokensTokenLabel()
    private let spacingLabel: TokensTokenLabel = {
        let label = TokensTokenLabel()
        label.textColor = Theme.Colors.Fill.background
        return label
    }()
    
    private var isMarked = false
    private var isMasked = false
    private var previousToken: TokenValue?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(spacingLabel)
        spacingLabel.pinToParent()
        addSubview(tokenLabel)
        tokenLabel.pinToParent()
        
        NSLayoutConstraint.activate([
            spacingLabel.widthAnchor.constraint(equalTo: tokenLabel.widthAnchor),
            spacingLabel.heightAnchor.constraint(equalTo: tokenLabel.heightAnchor),
        ])
        
        spacingLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        spacingLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        spacingLabel.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        
        tokenLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        tokenLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        tokenLabel.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        
        isAccessibilityElement = true
    }
    
    var currentToken: String? { tokenLabel.text }
    
    func mark() {
        guard !isMarked else { return }
        
        isMarked = true
        tokenLabel.mark()
    }
    
    func clearMarking() {
        guard isMarked else { return }
        
        isMarked = false
        tokenLabel.clearMarking()
    }
    
    func setToken(_ token: TokenValue, animated: Bool) {
        guard previousToken != token || isMasked else { return }
        let formattedToken = token.formattedValue
        spacingLabel.text = formattedToken
        currentText = formattedToken
        if isMasked {
            isMasked = false
            if animated {
                resetAnimation()
                animate(newText: formattedToken)
            } else {
                clearAnimation()
                tokenLabel.text = formattedToken
            }
        } else {
            if !isAnimating {
                tokenLabel.text = formattedToken
            }
        }
        
        let tokenVO = (token.components(separatedBy: "")).joined(separator: " ")
        accessibilityLabel = T.Voiceover.tokenTapToCopy(tokenVO)
        isAccessibilityElement = true
        
        let previous = previousToken
        previousToken = token
        if let element = UIAccessibility.focusedElement(using: nil) as? UILabel, element == self, previous != token {
            UIAccessibility.post(notification: .layoutChanged, argument: self)
        }
    }
    
    func setKind(_ kind: TokensCellKind) {
        tokenLabel.setKind(kind)
        spacingLabel.setKind(kind)
    }
    
    func maskToken() {
        guard !isMarked else { return }
        isMasked = true
        currentText = maskedText
        spacingLabel.text = maskedText
        tokenLabel.text = maskedText
        clearAnimation()
        isAccessibilityElement = false
    }
    
    func clear() {
        previousToken = nil
    }
    
    private func resetAnimation() {
        startTime = 0
        tokenLabel.text = carret
    }
    
    private func clearAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        tokenLabel.text = currentText
        startTime = 0
    }
    
    private func animate(newText: String) {
        let chars = Double(newText.count)
        end = chars
        startTime = 0
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: RunLoop.Mode.default)
    }
        
    @objc
    private func tick() {
        guard let displayLink else {
            clearAnimation()
            return
        }
        
        let timestamp = displayLink.timestamp
        
        if startTime == 0 { // first tick
            startTime = timestamp
            return
        }
        
        let maxTime = startTime + duration
        
        guard timestamp < maxTime else {
            clearAnimation()
            return
        }
        
        let progress = (timestamp - startTime) / duration
        let progressInterval = (end - start) * Double(progress)
        
        let offset = Int(start + progressInterval)
        let matrix = currentText.map { $0.isWhitespace ? " " : invisibleSpace }.joined()
        
        if offset < currentText.count {
            let txt: String = {
                if offset == 0 {
                    return carret
                }
                return "\(currentText[0..<offset])\(carret)"
            }()
            let txtOverMatrix = "\(txt)\(matrix[(offset + 1)...])"

            tokenLabel.text = txtOverMatrix
        } else {
            tokenLabel.text = currentText
        }
    }
}

private class TokensTokenLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        minimumScaleFactor = 0.4
        numberOfLines = 1
        allowsDefaultTighteningForTruncation = true
        adjustsFontSizeToFitWidth = true
        baselineAdjustment = .alignCenters
        textAlignment = .left
        isAccessibilityElement = false
    }
    
    func mark() {
        textColor = Theme.Colors.Text.theme
    }
    
    func clearMarking() {
        textColor = Theme.Colors.Text.main
    }
    
    func setKind(_ kind: TokensCellKind) {
        switch kind {
        case .compact:
            font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .thin)
        case .normal:
            font = UIFontMetrics(forTextStyle: .largeTitle)
                .scaledFont(for: UIFont.monospacedDigitSystemFont(ofSize: 50, weight: .thin))
        default:
            break
        }
    }
}
