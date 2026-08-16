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
    static let buttonSize: CGFloat = TFPinButton.size

    private static let columns = 3
    private static let rows = 4

    // Max dimensions expressed as multiples of buttonSize — calculated independently.
    private static let maxWidthFactor: CGFloat = 7
    private static let maxHeightFactor: CGFloat = 8
    
    private static let minSpacing: CGFloat = 8

    private var maxWidth: CGFloat { Self.buttonSize * Self.maxWidthFactor }
    private var maxHeight: CGFloat { Self.buttonSize * Self.maxHeightFactor }

    // MARK: Layout

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let availableW = proposal.width ?? maxWidth
        let availableH = proposal.height ?? maxHeight

        return CGSize(
            width: min(availableW, maxWidth),
            height: min(availableH, maxHeight)
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let cols = Self.columns
        let rows = Self.rows

        let layoutW = min(bounds.width, maxWidth)
        let layoutH = min(bounds.height, maxHeight)

        let cellW = max(0, (layoutW - Self.minSpacing * CGFloat(cols + 1)) / CGFloat(cols))
        let cellH = max(0, (layoutH - Self.minSpacing * CGFloat(rows + 1)) / CGFloat(rows))

        // Center the grid inside bounds if bounds is larger than layoutW/H
        let originX = round(bounds.minX + (bounds.width - layoutW) / 2)
        let originY = round(bounds.minY + (bounds.height - layoutH) / 2)

        let cellProposal = ProposedViewSize(width: cellW, height: cellH)

        for (index, subview) in subviews.enumerated() {
            let col = index % cols
            let row = index / cols

            let cx = originX + Self.minSpacing * CGFloat(col + 1) + cellW * CGFloat(col) + cellW / 2
            let cy = originY + Self.minSpacing * CGFloat(row + 1) + cellH * CGFloat(row) + cellH / 2

            subview.place(at: CGPoint(x: round(cx), y: round(cy)), anchor: .center, proposal: cellProposal)
        }
    }
}
