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

public struct GradientIconTile: View {
    private let systemName: String
    private let size: CGFloat
    
    private let iconSize: CGFloat = 17

    public init(systemName: String, size: CGFloat = 30) {
        self.systemName = systemName
        self.size = size
    }

    public var body: some View {
        let corner = TFCornerRadius.small.value
        ZStack {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(Self.gradient)
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .inset(by: 0.5)
                .stroke(AppColor.bordersPrimary, lineWidth: 1)
            Image(systemName: systemName)
                .textStyle(.body)
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }

    private static let gradient = LinearGradient(
        stops: [
            Gradient.Stop(color: Color(red: 1, green: 0.4, blue: 0.41), location: 0.00),
            Gradient.Stop(color: Color(red: 0.93, green: 0.11, blue: 0.14), location: 1.00)
        ],
        startPoint: UnitPoint(x: 0.5, y: 0),
        endPoint: UnitPoint(x: 0.5, y: 1)
    )
}
