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

public struct TFDoubleIconArrow: View {
    private let leadingSymbol: IconName
    private let trailingSymbol: IconName
    private let spacing: Spacing

    public init(leadingSymbol: IconName, trailingSymbol: IconName, spacing: Spacing = .XL) {
        self.leadingSymbol = leadingSymbol
        self.trailingSymbol = trailingSymbol
        self.spacing = spacing
    }

    public var body: some View {
        HStack(spacing: spacing) {
            Image(icon: leadingSymbol)
                .textStyle(.iconLarge)
                .foregroundStyle(.accentsBrand)
                .symbolBounceOnAppear(delay: 0.2)
            ArrowIcon()
            Image(icon: trailingSymbol)
                .textStyle(.iconLarge)
                .foregroundStyle(.accentsBrand)
                .symbolBounceOnAppear(delay: 0.8)
        }
    }
}
