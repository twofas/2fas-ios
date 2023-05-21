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

final class TokensTokenView: UILabel {
    private let maskedText = "••• •••"
    private let codeFont = UIFontMetrics(forTextStyle: .largeTitle)
        .scaledFont(for: UIFont.monospacedDigitSystemFont(ofSize: 50, weight: .thin))
    
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
        font = codeFont
        minimumScaleFactor = 0.5
        numberOfLines = 1
        allowsDefaultTighteningForTruncation = true
        adjustsFontSizeToFitWidth = true
        baselineAdjustment = .alignCenters
        textAlignment = .left
        isAccessibilityElement = true
    }
    
    var currentToken: String? { text }
    
    func mark() {
        guard !isMarked else { return }
        
        isMarked = true
        textColor = Theme.Colors.Text.theme
    }
    
    func clearMarking() {
        guard isMarked else { return }
        
        isMarked = false
        textColor = Theme.Colors.Text.main
    }
    
    func setToken(_ token: TokenValue) {
        guard previousToken != token || isMasked else { return }
        if isMasked {
            isMasked = false
        }
        text = token.formattedValue
        let tokenVO = (token.components(separatedBy: "")).joined(separator: " ")
        accessibilityLabel = T.Voiceover.tokenTapToCopy(tokenVO)
        
        let previous = previousToken
        previousToken = token
        if let element = UIAccessibility.focusedElement(using: nil) as? UILabel, element == self, previous != token {
            UIAccessibility.post(notification: .layoutChanged, argument: self)
        }
    }
    
    func maskToken() {
        isMasked = true
        text = maskedText
    }
        
    func clear() {
        previousToken = nil
    }
}
