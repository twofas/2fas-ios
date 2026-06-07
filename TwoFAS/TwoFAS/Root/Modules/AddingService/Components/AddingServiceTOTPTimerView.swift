//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
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

struct AddingServiceTOTPTimerView: View {
    @Binding
    var text: String
    @Binding
    var willChangeSoon: Bool
    @Binding
    var animationProgress: CGFloat
    
    private let animation = Animation
        .linear(duration: 1)
        .repeatCount(1)
    private let style = StrokeStyle(lineWidth: 2, lineCap: .round)
    
    var body: some View {
        let color = Color(willChangeSoon ?
                        AppColor.accentsBrand.color(for: .dark) :
                        AppColor.labelsPrimary.color(for: .dark)
        )
        
        ZStack(alignment: .center) {
            Text(text)
                .font(Font(Theme.Fonts.Controls.counter))
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .foregroundColor(color)
                .animation(nil, value: text)

            Circle()
                .trim(from: 0, to: $animationProgress.animation(animation).wrappedValue)
                .stroke(color, style: style)
                .rotationEffect(.degrees(-90))
                .padding(0.5)
                .frame(width: 36, height: 36)
        }
        .animation(.linear(duration: 1), value: animationProgress)
        .animation(.easeInOut(duration: 0.5), value: willChangeSoon)
    }
}
