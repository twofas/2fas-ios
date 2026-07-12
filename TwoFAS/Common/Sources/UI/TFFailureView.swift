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

public struct TFFailureView: View {
    private let title: String

    @State
    private var isVisible = false
    @State
    private var symbolBounce = 0

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        VStack(spacing: .L) {
            Spacer()
                .frame(maxHeight: .infinity)
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.accentsBrand)
                .symbolEffect(.bounce, value: symbolBounce)
            Text(title)
                .textStyle(.title3)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
                .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.85)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                isVisible = true
            }
            symbolBounce += 1
        }
    }
}
