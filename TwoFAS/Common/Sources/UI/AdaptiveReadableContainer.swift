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
    public static var defaultIPhoneMaxWidth: CGFloat { .infinity }
    public static var defaultIPadMaxWidth: CGFloat { 720 }
    public static var defaultHorizontalMargin: CGFloat { Spacing.XL.value }

    /// The width the container, with its defaults, gives its content out of `available`:
    /// for a host that lays something out to match the content without being inside.
    public static func readableWidth(available: CGFloat, sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        let maxWidth = sizeClass == .compact ? defaultIPhoneMaxWidth : defaultIPadMaxWidth
        return min(maxWidth, available - 2 * defaultHorizontalMargin)
    }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private let iphoneMaxWidth: CGFloat
    private let ipadMaxWidth: CGFloat
    private let horizontalMargin: CGFloat
    private let verticalMargin: CGFloat
    @ViewBuilder
    private let content: Content
    
    public init(
        iphoneMaxWidth: CGFloat = defaultIPhoneMaxWidth,
        ipadMaxWidth: CGFloat = defaultIPadMaxWidth,
        horizontalMargin: CGFloat = defaultHorizontalMargin,
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
