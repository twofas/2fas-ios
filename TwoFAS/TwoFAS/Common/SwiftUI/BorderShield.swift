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

struct BorderShield: View {
    let showDeleteIcon: Bool
    
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    
    private let circleFrame: CGFloat = 26
    
    var body: some View {
        if #available(iOS 26.0, *) {
            VStack {
                Asset.introductionaryLogo.swiftUIImage
            }
            .frame(width: 72, height: 72)
            .background(
                LinearGradient(
                    colors: [
                        AppColor.backgroundsGroupedPrimaryElevated.color(for: colorScheme),
                        colorScheme == .dark ? AppColor.graysBlack.color(for: colorScheme).opacity(0.1)
                        : AppColor.graysWhite.color(for: colorScheme)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: TFCornerRadius.badge.rawValue)
                    .inset(by: 0.5)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppColor.bordersPrimary.color(for: colorScheme).opacity(0.15),
                                AppColor.bordersPrimary.color(for: colorScheme).opacity(0),
                                AppColor.bordersPrimary.color(for: colorScheme).opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: TFCornerRadius.badge.rawValue))
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: TFCornerRadius.badge.rawValue))
            .overlay(alignment: .topTrailing, content: {
                if showDeleteIcon {
                    ZStack {
                        Circle()
                            .frame(width: circleFrame, height: circleFrame)
                            .background(.backgroundsPrimary)
                            .clipShape(Circle())
                        RoundedRectangle(.large)
                            .frame(width: 10, height: 2)
                            .foregroundStyle(colorScheme == .dark ? .graysBlack : .graysWhite)
                    }
                    .background(.clear)
                    .offset(x: round(circleFrame / 3.0), y: round(-circleFrame / 3.0))
                }
            })
            .padding(.top, .XL)
        }
    }
}
