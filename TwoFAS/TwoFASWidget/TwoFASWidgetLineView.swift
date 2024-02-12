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

import WidgetKit
import SwiftUI
import Common

struct TwoFASWidgetLineView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private let spacing: CGFloat = 10
    
    let entries: [CodeEntry.Entry]
    
    @ViewBuilder
    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.fixed(24)),
                GridItem(.flexible()),
                GridItem(.fixed(100)),
                GridItem(.fixed(40))
            ],
            alignment: .center,
            spacing: 2 * spacing,
            pinnedViews: [],
            content: {
                ForEach(entries) { entry in
                    let entryData = entry.data
                    let kind = entry.kind
                    
                    let reason: RedactionReasons = {
                        switch kind {
                        case .placeholder: return .placeholder
                        default: return []
                        }
                    }()
                    
                    let codeReason: RedactionReason = {
                        switch kind {
                        case .placeholder: return .codePlaceholder
                        default: return .noPlaceholder
                        }
                    }()
                    
                    let tokenVO = (entryData.code.components(separatedBy: "")).joined(separator: " ")
                    
                    Group {
                        IconRenderer(entry: entry)
                            .redacted(reason: reason)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(entryData.name)
                                .font(.caption2)
                                .multilineTextAlignment(.leading)
                                .redacted(reason: reason)
                                .lineLimit(1)
                                .accessibility(label: Text("widget_service_name \(entryData.name)"))
                            let info = entryData.info ?? ""
                            Text(info)
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .redacted(reason: reason)
                        }.frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: .topLeading
                        )
                        Text(entryData.code)
                            .font(Font.system(.title).weight(.light).monospacedDigit())
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.2)
                            .lineLimit(1)
                            .redacted(reason: codeReason)
                            .accessibility(label: Text("widget_token \(tokenVO)"))
                        counterText(for: entryData.countdownTo)
                            .multilineTextAlignment(.trailing)
                            .font(Font.body.monospacedDigit())
                            .lineLimit(1)
                            .redacted(reason: reason)
                    }
                    .accessibility(hidden: codeReason == .codePlaceholder)
                }
            })
        .addWidgetContentMargins(standard: spacing)
    }
    
    private func counterText(for date: Date?) -> Text {
        if let countdownTo = date {
            return Text(countdownTo, style: .timer)
        }
        return Text("0:00")
    }
}
