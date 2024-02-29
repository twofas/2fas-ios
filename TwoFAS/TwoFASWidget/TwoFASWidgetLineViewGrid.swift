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

import WidgetKit
import SwiftUI
import Common

struct TwoFASWidgetLineViewGrid: View {
    @Environment(\.colorScheme) var colorScheme
    
    private let spacing: CGFloat = 8
    private let minSize: CGFloat = 170
    
    let entries: [CodeEntry.Entry]
    
    @ViewBuilder
    var body: some View {
        let halfElements: Int = 6
        let firstHalf = Array(entries.prefix(halfElements))
        let secondHalf = Array(entries.suffix(halfElements))
        LazyVGrid(
            columns: [
                GridItem(.flexible(minimum: minSize)),
                GridItem(.flexible(minimum: minSize))
            ],
            alignment: .leading,
            spacing: 2 * spacing,
            pinnedViews: [],
            content: {
                TwoFASWidgetLineView(entries: firstHalf)
                TwoFASWidgetLineView(entries: secondHalf)
            })
        .addWidgetContentMargins(standard: spacing)
    }
}
