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
import Common

struct PINKeypadLayout: Layout {
    // Layout is driven by the button's *visible* size (the 64 pt circle). The
    // extra tappable inset is intentionally ignored here and simply overlaps the
    // gaps between keys.
    static let buttonSize: CGFloat = TFPinButton.size

    private static let columns = 3
    private static let rows = 4

    // Horizontal spacing between keys and the outer horizontal margin both scale
    // together with the available width, between their min and max bounds.
    private static let hSpacingMin: CGFloat = TFPinButton.tapInset * 2 // 12
    private static let hSpacingMax: CGFloat = 54
    private static let hMarginMin: CGFloat = TFPinButton.tapInset       // 6
    private static let hMarginMax: CGFloat = 51

    // Vertical spacing is uniform: the gap between rows equals the top/bottom
    // margin, and scales together with the available height.
    private static let vSpacingMin: CGFloat = 12
    private static let vSpacingMax: CGFloat = 24

    private static var minWidth: CGFloat {
        hMarginMin * 2 + buttonSize * CGFloat(columns) + hSpacingMin * CGFloat(columns - 1)
    }
    private static var maxWidth: CGFloat {
        hMarginMax * 2 + buttonSize * CGFloat(columns) + hSpacingMax * CGFloat(columns - 1)
    }
    private static var minHeight: CGFloat {
        vSpacingMin * CGFloat(rows + 1) + buttonSize * CGFloat(rows)
    }
    private static var maxHeight: CGFloat {
        vSpacingMax * CGFloat(rows + 1) + buttonSize * CGFloat(rows)
    }

    // MARK: Layout

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let availableW = proposal.width ?? Self.maxWidth
        let availableH = proposal.height ?? Self.maxHeight

        return CGSize(
            width: clamp(availableW, Self.minWidth, Self.maxWidth),
            height: clamp(availableH, Self.minHeight, Self.maxHeight)
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let cols = Self.columns

        let layoutW = clamp(bounds.width, Self.minWidth, Self.maxWidth)
        let layoutH = clamp(bounds.height, Self.minHeight, Self.maxHeight)

        let tH = fraction(layoutW, Self.minWidth, Self.maxWidth)
        let tV = fraction(layoutH, Self.minHeight, Self.maxHeight)

        let hSpacing = lerp(Self.hSpacingMin, Self.hSpacingMax, tH)
        let hMargin = lerp(Self.hMarginMin, Self.hMarginMax, tH)
        let vSpacing = lerp(Self.vSpacingMin, Self.vSpacingMax, tV)

        // Center the grid inside bounds.
        let originX = bounds.minX + (bounds.width - layoutW) / 2
        let originY = bounds.minY + (bounds.height - layoutH) / 2

        let cellProposal = ProposedViewSize(width: Self.buttonSize, height: Self.buttonSize)

        for (index, subview) in subviews.enumerated() {
            let col = index % cols
            let row = index / cols

            let cx = originX + hMargin + CGFloat(col) * (Self.buttonSize + hSpacing) + Self.buttonSize / 2
            let cy = originY + vSpacing + CGFloat(row) * (Self.buttonSize + vSpacing) + Self.buttonSize / 2

            subview.place(at: CGPoint(x: round(cx), y: round(cy)), anchor: .center, proposal: cellProposal)
        }
    }

    // MARK: Helpers

    private func clamp(_ value: CGFloat, _ lower: CGFloat, _ upper: CGFloat) -> CGFloat {
        min(max(value, lower), upper)
    }

    private func fraction(_ value: CGFloat, _ lower: CGFloat, _ upper: CGFloat) -> CGFloat {
        guard upper > lower else { return 0 }
        return clamp((value - lower) / (upper - lower), 0, 1)
    }

    private func lerp(_ from: CGFloat, _ to: CGFloat, _ t: CGFloat) -> CGFloat {
        from + (to - from) * t
    }
}
