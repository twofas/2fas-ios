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

struct AddingServiceIcon: View {
    @Environment(\.colorScheme)
    private var colorScheme
    
    private let circleSize: CGFloat = 52
    private let iconSize: CGFloat = 32
    
    let icon: IconDetails
    
    var body: some View {
        ZStack {
            switch icon {
            case .brand(let iconTypeID):
                Circle()
                    .frame(width: circleSize, height: circleSize)
                    .foregroundStyle(.backgroundsSecondary)
                
                if let iconImage = icon.iconImage {
                    Image(uiImage: iconImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                }
            case .label(let title, let tintColor):
                Circle()
                    .frame(width: circleSize, height: circleSize)
                    .foregroundStyle(tintColor.color(for: colorScheme))
                Text(title)
                    .textStyle(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.graysWhite)
            }
        }
        .accessibilityHidden(true)
    }
}
