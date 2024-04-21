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
    
    @ObservedObject
    var presenter: ServicePresenter
    
    private let spacing: CGFloat = 8
    
    @ViewBuilder
    var body: some View {
        Group {
            if presenter.isHOTP {
                unsupportedHOTP()
            } else {
                list()
            }
        }
        .navigationTitle {
            Text(presenter.name)
                .lineLimit(1)
        }
        .scenePadding()
    }
    
    @ViewBuilder
    private func list() -> some View {
        TimelineView(.explicit(presenter.timelineEntries())) { context in
            VStack(alignment: .leading, spacing: nil) {
                HStack(alignment: .center, spacing: nil) {
                    IconRenderer(service: presenter.service)
                    Spacer()
                    counterText(for: presenter.timeToNextDate(for: context.date))
                        .multilineTextAlignment(.trailing)
                        .font(Font.body.monospacedDigit())
                        .lineLimit(1)
                        .contentTransition(.numericText(countsDown: true))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 3) {
                    Text(presenter.calculateToken(for: context.date))
                        .font(Font.system(.title).weight(.light).monospacedDigit())
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.2)
                        .contentTransition(.numericText())
                        .foregroundColor(.primary)
                        .layoutPriority(1)
                    if let info = presenter.additionalInfo {
                        Text(info)
                            .lineLimit(1)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                        .frame(maxHeight: .infinity)
                }
                .frame(alignment: .leading)
                .padding(.top, 4)
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    presenter.toggleFavorite()
                } label: {
                    if presenter.isFavorite {
                        Image(systemName: "star.fill")
                    } else {
                        Image(systemName: "star")
                    }
                }
                .controlSize(.mini)
                .background(Color.accentColor, in: Circle())
            }
        }
    }
    
    @ViewBuilder
    private func unsupportedHOTP() -> some View {
        Text(T.Tokens.hotpNotSupported)
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
