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

public struct AdaptiveReadableContainer<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private let iphoneMaxWidth: CGFloat
    private let ipadMaxWidth: CGFloat
    private let horizontalMargin: CGFloat
    private let verticalMargin: CGFloat
    @ViewBuilder
    private let content: Content
    
    public init(
        iphoneMaxWidth: CGFloat = .infinity,
        ipadMaxWidth: CGFloat = 720,
        horizontalMargin: CGFloat = Spacing.XXXL.value,
        verticalMargin: CGFloat = Spacing.XL.value,
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
    
    public var body: some View {
        VStack(spacing: .zero) {
            content
                .frame(maxWidth: maxWidth, alignment: .center)
                .padding(.horizontal, horizontalMargin)
                .padding(.vertical, verticalMargin)
        }
    }
}
