//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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
import CommonWatch

struct PINKeyboardLayout: Layout {
    private let spacing: CGFloat = 1
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        print(">>>! \(proposal)")
        
        let maxWidth = subviews.reduce(into: 0, { result, subview in
            result = max(result, subview.sizeThatFits(proposal).width)
        })
        
        let maxHeight = subviews.reduce(into: 0, { result, subview in
            result = max(result, subview.sizeThatFits(proposal).height)
        })
        
        print(">>> \(maxWidth), \(maxHeight)")
        
        return CGSize(
            width: maxWidth * 3 + 2 * spacing,
            height: maxHeight * 4 + 3 * spacing
        )
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let lastColumn: Int = 2
        let lastRow: Int = 3
        
        print(">>> \(proposal), \(bounds)")
        
        let elementWidth = floor((bounds.width - CGFloat(lastColumn) * spacing)/CGFloat(lastColumn + 1))
        let elementHeight = floor((bounds.height - CGFloat(lastRow) * spacing)/CGFloat(lastRow + 1))
        
        var item: Int = 0
        
        for row in 0...lastRow {
            for column in 0...lastColumn {
                guard let view = subviews[safe: item] else { break }
                view.place(at: CGPoint(
                    x: CGFloat(column) * elementWidth + spacing * CGFloat(column),
                    y: CGFloat(row) * elementHeight + spacing * CGFloat(row)
                ),
                    proposal: .init(width: elementWidth, height: elementHeight)
                )
                item += 1
            }
        }
    }
    
    
}

