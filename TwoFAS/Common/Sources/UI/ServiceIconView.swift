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

public struct ServiceIconView: View {
    @Environment(\.colorScheme)
    private var colorScheme
    
    private let circleSize: CGFloat = 52
    private let iconSize: CGFloat = 32
    
    public let icon: IconDetails
    public let showBackground: Bool
    
    public init(icon: IconDetails, showBackground: Bool = true) {
        self.icon = icon
        self.showBackground = showBackground
    }
    
    public var body: some View {
        ZStack {
            switch icon {
            case .brand:
                ZStack {
                    if showBackground {
                        Circle()
                            .frame(width: circleSize, height: circleSize)
                            .foregroundStyle(.backgroundsSecondary)
                    }
                    
                    if let iconImage = icon.iconImage {
                        Image(uiImage: iconImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: iconSize, height: iconSize)
                    }
                }
                .frame(width: circleSize, height: circleSize)
            case .label(let title, let tintColor):
                Circle()
                    .frame(width: circleSize, height: circleSize)
                    .foregroundStyle(tintColor.color(for: colorScheme))
                    .overlay {
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .black.opacity(0), location: 0.00),
                                Gradient.Stop(color: .black.opacity(0.1), location: 1.00)
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                        .clipShape(Circle())
                    }
                Text(title)
                    .textStyle(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.graysWhite)
            }
        }
        .accessibilityHidden(true)
    }
}
