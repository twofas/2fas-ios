//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
//  Contributed by Grzegorz Machnio. All rights reserved.
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

struct CountdownTimerText: View {
    let date: Date?

    private var timerText: some View {
        if let countdownTo = date {
            Text(countdownTo, style: .timer)
        } else {
            Text("0:00")
        }
    }
    
    var body: some View {
        timerText
            .frame(width: 40, height: 18)
            .foregroundStyle(.textPrimary)
            .multilineTextAlignment(.trailing)
            .font(.caption.weight(.semibold).monospacedDigit())
            .lineLimit(1)
            .contentTransition(.numericText(countsDown: true))
    }
}
