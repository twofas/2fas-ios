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
        ForEach(entries, id: \.self) { entry in
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
            
            generateLine(
                entry: entry,
                entryData: entryData,
                reason: reason,
                codeReason: codeReason
            )
                .accessibility(hidden: codeReason == .codePlaceholder)
                .overlay {
                    CopyIntentButton(rawEntry: entryData.rawEntry) {
                        Rectangle()
                            .foregroundStyle(Color.clear)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
        }
        .addWidgetContentMargins(standard: spacing)
    }
    
    @ViewBuilder
    private func generateLine(
        entry: CodeEntry.Entry,
        entryData: CodeEntry.EntryData,
        reason: RedactionReasons,
        codeReason: RedactionReason
    ) -> some View {
        HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
            IconRenderer(entry: entry)
                .frame(width: 24)
                .redacted(reason: reason)
            VStack(alignment: .leading, spacing: 3) {
                Text(entryData.name)
                    .font(.caption2)
                    .multilineTextAlignment(.leading)
                    .redacted(reason: reason)
                    .lineLimit(1)
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
            Text(verbatim: entryData.code)
                .font(Font.system(.title).weight(.light).monospacedDigit())
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.2)
                .lineLimit(1)
                .redacted(reason: codeReason)
                .contentTransition(.numericText())
                .frame(width: 100)
            counterText(for: entryData.countdownTo)
                .multilineTextAlignment(.trailing)
                .font(Font.body.monospacedDigit())
                .contentTransition(.numericText(countsDown: true))
                .lineLimit(1)
                .redacted(reason: reason)
                .frame(width: 40)
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
