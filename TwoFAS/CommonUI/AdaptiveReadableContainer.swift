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
import UIKit

struct AdaptiveReadableContainer<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    let iphoneMaxWidth: CGFloat
    let ipadMaxWidth: CGFloat
    let horizontalMargin: CGFloat
    let verticalMargin: CGFloat
    @ViewBuilder let content: Content
    
    init(
        iphoneMaxWidth: CGFloat = .infinity,
        ipadMaxWidth: CGFloat = 720,
        horizontalMargin: CGFloat = 20,
        verticalMargin: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.iphoneMaxWidth = iphoneMaxWidth
        self.ipadMaxWidth = ipadMaxWidth
        self.horizontalMargin = horizontalMargin
        self.verticalMargin = verticalMargin
        self.content = content()
    }
    
    private var maxWidth: CGFloat {
        horizontalSizeClass == .compact ? iphoneMaxWidth : ipadMaxWidth
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                content
                    .frame(maxWidth: maxWidth, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .contentMargins(.horizontal, horizontalMargin, for: .scrollContent)
            .contentMargins(.vertical, verticalMargin, for: .scrollContent)
        }
    }
}

