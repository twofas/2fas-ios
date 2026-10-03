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

final class TokensTokenLabel: UILabel {
    enum Role {
        case primary
        case next
    }

    private let role: Role
    private let minScaleFactor: CGFloat = 0.8
    private let bottomInset: CGFloat = 1
    private let topInset: CGFloat = 1
    private var baseFont = TextStyle.token.uiFont()

    var digitHeight: CGFloat { ceil(font.capHeight) + bottomInset + topInset }

    init(role: Role = .primary) {
        self.role = role
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        self.role = .primary
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        numberOfLines = 1
        textAlignment = .left
        isAccessibilityElement = false
        font = baseFont
    }

    override var intrinsicContentSize: CGSize {
        guard let text, !text.isEmpty else {
            return CGSize(width: UIView.noIntrinsicMetric, height: digitHeight)
        }
        let naturalWidth = (text as NSString).size(withAttributes: [.font: baseFont]).width
        return CGSize(width: ceil(naturalWidth), height: digitHeight)
    }

    override func drawText(in rect: CGRect) {
        let lineTop = (bounds.maxY - bottomInset - font.ascender).rounded(.down)
        let lineRect = CGRect(
            x: rect.minX,
            y: lineTop,
            width: rect.width,
            height: ceil(font.lineHeight)
        )
        super.drawText(in: lineRect)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateFittedFont()
    }

    private func updateFittedFont() {
        guard let text, !text.isEmpty, bounds.width > 0 else { return }
        let fittedSize = fittedFontSize(for: text, maxWidth: bounds.width)
        guard abs(fittedSize - font.pointSize) > 0.01 else { return }
        font = baseFont.withSize(fittedSize)
        invalidateIntrinsicContentSize()
        superview?.invalidateIntrinsicContentSize()
        superview?.setNeedsLayout()
    }

    private func fittedFontSize(for text: String, maxWidth: CGFloat) -> CGFloat {
        let naturalWidth = (text as NSString).size(withAttributes: [.font: baseFont]).width
        guard naturalWidth > maxWidth + 0.5 else { return baseFont.pointSize }
        let scale = max(minScaleFactor, maxWidth / naturalWidth)
        return floor(baseFont.pointSize * scale)
    }

    func mark() {
        textColor = AppColor.accentsBrand.uiColor
    }

    func clearMarking() {
        textColor = AppColor.labelsPrimary.uiColor
    }

    func setKind(_ kind: TokensCellKind) {
        switch (role, kind) {
        case (.primary, .compact):
            baseFont = TextStyle.compactToken.uiFont()
        case (.primary, .normal):
            baseFont = TextStyle.token.uiFont()
        case (.next, .compact), (.next, .normal):
            baseFont = TextStyle.smallToken.uiFont()
        default:
            return
        }
        font = baseFont
        invalidateIntrinsicContentSize()
    }
}
