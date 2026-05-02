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

import SwiftUI

// MARK: - TextStyle

/// Semantic text styles from the 2FAS Design System typography scale.
///
/// Usage:
/// ```swift
/// Text("Title").textStyle(.title2, .emphasized)
/// Text("Body copy").textStyle(.body, .regular, .loose)
/// Text("Note").textStyle(.footnote, .italic)
/// ```
@frozen
public enum TextStyle {
    /// SF Pro 34pt — maps to `Font.TextStyle.largeTitle`
    case largeTitle
    /// SF Pro 28pt — maps to `Font.TextStyle.title`
    case title1
    /// SF Pro 22pt — maps to `Font.TextStyle.title2`
    case title2
    /// SF Pro 20pt — maps to `Font.TextStyle.title3`
    case title3
    /// SF Pro 17pt Semibold — maps to `Font.TextStyle.headline`
    case headline
    /// SF Pro 17pt — maps to `Font.TextStyle.body`
    case body
    /// SF Pro 16pt — maps to `Font.TextStyle.callout`
    case callout
    /// SF Pro 15pt — maps to `Font.TextStyle.subheadline`
    case subheadline
    /// SF Pro 13pt — maps to `Font.TextStyle.footnote`
    case footnote
    /// SF Pro 12pt — maps to `Font.TextStyle.caption`
    case caption1
    /// SF Pro 11pt — maps to `Font.TextStyle.caption2`
    case caption2
}

// MARK: - TextStyleVariant

/// Weight and italic variants defined in the design system.
///
/// Available combinations per style:
/// - `.largeTitle`, `.title1–3`: `.regular` / `.medium` / `.emphasized`
/// - `.headline`: `.regular` (always semibold) / `.italic` (semibold italic)
/// - `.body`: `.regular` / `.medium` / `.emphasized` / `.italic` / `.emphasizedItalic`
/// - `.callout` and smaller: `.regular` / `.emphasized` / `.italic` / `.emphasizedItalic`
@frozen
public enum TextStyleVariant {
    /// SF Pro Regular
    case regular
    /// SF Pro Medium
    case medium
    /// SF Pro Bold (largeTitle/title1) or Semibold (title2 and smaller)
    case emphasized
    /// SF Pro Italic (Regular Italic for most; Semibold Italic for headline)
    case italic
    /// SF Pro Semibold Italic
    case emphasizedItalic
}

// MARK: - TextStyleLeading

/// Line height (leading) mode, matching the three Figma typography frames.
public enum TextStyleLeading {
    /// Tight leading — 2 pt less than standard.
    /// Note: SwiftUI may clamp negative lineSpacing on older OS versions.
    case tight
    /// Standard (original) leading — matches Apple HIG defaults.
    case standard
    /// Loose leading — 2 pt more than standard.
    case loose
}

// MARK: - Internal Attributes

private struct TextStyleAttributes {
    let size: CGFloat
    /// Absolute line height in points (for reference / UIKit use).
    let lineHeight: CGFloat
    let tracking: CGFloat
    let weight: Font.Weight
    let isItalic: Bool
    let semanticStyle: Font.TextStyle
}

// MARK: - Attributes Resolution

private extension TextStyle {
    func attributes(variant: TextStyleVariant, leading: TextStyleLeading) -> TextStyleAttributes {
        // Standard → base values; tight = −2 pt; loose = +2 pt.
        let pad: CGFloat
        switch leading {
        case .tight: pad = -2
        case .standard: pad = 0
        case .loose: pad = +2
        }
        
        switch self {
            
            // ── Titles ───────────────────────────────────────────────────────────
            
        case .largeTitle:
            return TextStyleAttributes(
                size: 34,
                lineHeight: 41 + pad,
                tracking: 0.40,
                weight: titleWeight( variant, emphasized: .bold),
                isItalic: false, semanticStyle: .largeTitle
            )
        case .title1:
            return TextStyleAttributes(
                size: 28, lineHeight: 34 + pad, tracking: 0.38,
                weight: titleWeight(variant, emphasized: .bold),
                isItalic: false, semanticStyle: .title
            )
        case .title2:
            return TextStyleAttributes(
                size: 22, lineHeight: 28 + pad, tracking: -0.26,
                weight: titleWeight(variant, emphasized: .semibold),
                isItalic: false, semanticStyle: .title2
            )
        case .title3:
            return TextStyleAttributes(
                size: 20, lineHeight: 25 + pad, tracking: -0.45,
                weight: titleWeight(variant, emphasized: .semibold),
                isItalic: false, semanticStyle: .title3
            )
            
            // ── Body-level ───────────────────────────────────────────────────────
            
        case .headline:
            // Headline is always semibold; variant only toggles italic.
            return TextStyleAttributes(
                size: 17, lineHeight: 22 + pad, tracking: -0.43,
                weight: .semibold,
                isItalic: variant == .italic || variant == .emphasizedItalic,
                semanticStyle: .headline
            )
        case .body:
            return TextStyleAttributes(
                size: 17, lineHeight: 22 + pad, tracking: -0.43,
                weight: bodyWeight(variant),
                isItalic: variant == .italic || variant == .emphasizedItalic,
                semanticStyle: .body
            )
        case .callout:
            return TextStyleAttributes(
                size: 16, lineHeight: 21 + pad, tracking: -0.31,
                weight: smallWeight(variant),
                isItalic: variant == .italic || variant == .emphasizedItalic,
                semanticStyle: .callout
            )
        case .subheadline:
            return TextStyleAttributes(
                size: 15, lineHeight: 20 + pad, tracking: -0.23,
                weight: smallWeight(variant),
                isItalic: variant == .italic || variant == .emphasizedItalic,
                semanticStyle: .subheadline
            )
            
            // ── Small ─────────────────────────────────────────────────────────────
            
        case .footnote:
            return TextStyleAttributes(
                size: 13, lineHeight: 18 + pad, tracking: -0.08,
                weight: smallWeight(variant),
                isItalic: variant == .italic || variant == .emphasizedItalic,
                semanticStyle: .footnote
            )
        case .caption1:
            // Tight frame uses Medium for .emphasized (vs Semibold in standard/loose).
            let w: Font.Weight = (leading == .tight && variant == .emphasized) ? .medium
            : (leading == .tight && variant == .emphasizedItalic) ? .medium
            : smallWeight(variant)
            return TextStyleAttributes(
                size: 12, lineHeight: 16 + pad, tracking: 0,
                weight: w,
                isItalic: variant == .italic || variant == .emphasizedItalic,
                semanticStyle: .caption
            )
        case .caption2:
            // Tight frame: lineHeight equals fontSize (11pt) — no breathing room.
            return TextStyleAttributes(
                size: 11, lineHeight: 13 + pad, tracking: 0.06,
                weight: smallWeight(variant),
                isItalic: variant == .italic || variant == .emphasizedItalic,
                semanticStyle: .caption2
            )
        }
    }
    
    // MARK: Weight helpers
    
    /// regular / medium / emphasized  (titles largeTitle–title3)
    private func titleWeight(_ variant: TextStyleVariant, emphasized: Font.Weight) -> Font.Weight {
        switch variant {
        case .medium: .medium
        case .emphasized, .emphasizedItalic: emphasized
        default: .regular
        }
    }
    
    /// regular / medium / emphasized / italic  (body only)
    private func bodyWeight(_ variant: TextStyleVariant) -> Font.Weight {
        switch variant {
        case .medium: .medium
        case .emphasized, .emphasizedItalic: .semibold
        default: .regular
        }
    }
    
    /// regular / emphasized / italic  (callout, subheadline, footnote, caption2; caption1 outside tight)
    private func smallWeight(_ variant: TextStyleVariant) -> Font.Weight {
        switch variant {
        case .emphasized, .emphasizedItalic: .semibold
        default: .regular
        }
    }
}

// MARK: - ViewModifier

private struct TextStyleModifier: ViewModifier {
    let style: TextStyle
    let variant: TextStyleVariant
    let leading: TextStyleLeading
    
    func body(content: Content) -> some View {
        let attrs = style.attributes(variant: variant, leading: leading)
        let baseFont = Font.system(size: attrs.size, weight: attrs.weight, design: .default)
        
        // Standard leading aligns with SF Pro's natural UIFont.lineHeight (no extra spacing).
        // Loose adds +2 pt; tight subtracts −2 pt (may be clamped to 0 on older OS).
        let lineSpacingDelta: CGFloat
        switch leading {
        case .tight:    lineSpacingDelta = -2
        case .standard: lineSpacingDelta =  0
        case .loose:    lineSpacingDelta =  2
        }
        
        return content
            .font(attrs.isItalic ? baseFont.italic() : baseFont)
            .tracking(attrs.tracking)
            .lineSpacing(lineSpacingDelta)
    }
}

// MARK: - View Extension

public extension View {
    /// Applies a named text style from the 2FAS Design System.
    ///
    /// - Parameters:
    ///   - style: Semantic text style (`.largeTitle`, `.body`, `.caption1`, …).
    ///   - variant: Weight/italic variant. Defaults to `.regular`.
    ///   - leading: Line height mode. Defaults to `.standard`.
    func textStyle(
        _ style: TextStyle,
        _ variant: TextStyleVariant = .regular,
        _ leading: TextStyleLeading = .standard
    ) -> some View {
        modifier(TextStyleModifier(style: style, variant: variant, leading: leading))
    }
}
