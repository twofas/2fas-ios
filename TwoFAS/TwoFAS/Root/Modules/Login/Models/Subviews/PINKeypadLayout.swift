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
    
    private static let minSpacing: CGFloat = 16
    
    private var maxWidth: CGFloat { Self.buttonSize * Self.maxWidthFactor }
    private var maxHeight: CGFloat { Self.buttonSize * Self.maxHeightFactor }
    private var minHeight: CGFloat { Self.buttonSize * CGFloat(Self.rows) + Self.minSpacing * CGFloat(Self.rows - 1) }

    // MARK: Layout

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let availableW = proposal.width ?? maxWidth
        let availableH = proposal.height ?? maxHeight
        let height = max(min(availableH, maxHeight), minHeight)

        return CGSize(
            width: min(availableW, maxWidth),
            height: height
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let btn  = Self.buttonSize
        let cols = Self.columns
        let rows = Self.rows

        let layoutW = min(bounds.width, maxWidth)
        let layoutH = max(min(bounds.height, maxHeight), minHeight)

        // Equal horizontal gaps: left edge + gaps between cols + right edge = cols+1 slots
        let hGap = (layoutW - btn * CGFloat(cols)) / CGFloat(cols + 1)
        // Equal vertical gaps: top edge + gaps between rows + bottom edge = rows+1 slots
        let vGap = (layoutH - btn * CGFloat(rows)) / CGFloat(rows + 1)

        // Center the grid inside bounds if bounds is larger than layoutW/H
        let originX = round(bounds.minX + (bounds.width - layoutW) / 2)
        let originY = round(bounds.minY + (bounds.height - layoutH) / 2)

        let buttonProposal = ProposedViewSize(width: btn, height: btn)

        for (index, subview) in subviews.enumerated() {
            let col = index % cols
            let row = index / cols

            let cx = originX + CGFloat(col + 1) * hGap + CGFloat(col) * btn + btn / 2
            let cy = originY + CGFloat(row + 1) * vGap + CGFloat(row) * btn + btn / 2

            subview.place(at: CGPoint(x: round(cx), y: round(cy)), anchor: .center, proposal: buttonProposal)
        }
    }
}
