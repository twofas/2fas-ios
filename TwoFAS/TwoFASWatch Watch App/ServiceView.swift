//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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
import CommonWatch

struct ServiceView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private let spacing: CGFloat = 8
    
    let service: Service
    
    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: nil) {
            Spacer()
            HStack(alignment: .center, spacing: nil) {
                IconRenderer(service: service)
                Spacer()
                Text("0:00")
                //counterText(for: service.countdownTo)
                    .multilineTextAlignment(.trailing)
                    .font(Font.body.monospacedDigit())
                    .lineLimit(1)
                    .contentTransition(.numericText(countsDown: true))
            }
            Spacer(minLength: spacing * 3)
            VStack(alignment: .leading, spacing: 3) {
                Text(service.name)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                //Text(service.code)
                Text("666666")
                    .font(Font.system(.title).weight(.light).monospacedDigit())
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.2)
                    .contentTransition(.numericText())
                if let info = service.additionalInfo {
                    Text(info)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private func counterText(for date: Date?) -> some View {
        if let countdownTo = date {
            Text(countdownTo, style: .timer)
        } else {
            Text("0:00")
        }
    }
}
