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

struct IntroductionPaging: View {
    @Binding
    var showPaging: Bool
    @Binding
    var activePage: Int
    let dotsCount: Int
    
    private let circleSize: CGFloat = 8
    
    var body: some View {
        HStack(spacing: .M) {
            ForEach(0..<dotsCount, id: \.self) { index in
                dot(isActive: activePage == index)
            }
        }
        .isHidden(!showPaging, remove: false)
    }
    
    @ViewBuilder
    private func dot(isActive: Bool) -> some View {
        Circle()
            .frame(width: circleSize, height: circleSize)
            .foregroundStyle(.labelsPrimary)
            .opacity(isActive ? 1 : 0.3)
            .animation(.easeInOut, value: isActive)
    }
}
