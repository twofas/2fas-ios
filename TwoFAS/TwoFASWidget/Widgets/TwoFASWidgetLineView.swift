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
    
    private var isAnyEntryHidden: Bool {
        entries.contains { $0.kind == .singleEntryHidden }
    }
    private let spacing: CGFloat = 10
    
    let entries: [CodeEntry.Entry]
    let isRevealTokenOverlayVisible: Bool
    
    @ViewBuilder
    var body: some View {
        VStack(spacing: 0) {
            ForEach(entries.filter { $0.kind != .placeholder }, id: \.self) { entry in
                let kind = entry.kind
                let reason: RedactionReasons = {
                    switch kind {
                    case .placeholder: return .placeholder
                    default: return []
                    }
                }()
                let codeReason: RedactionReason = {
                    switch kind {
                    case .placeholder, .singleEntryHidden: return .codePlaceholder
                    default: return .noPlaceholder
                    }
                }()

                generateLine(
                    entry: entry,
                    data: entry.data,
                    reason: reason
                )
                .frame(height: 49)
                .accessibility(hidden: codeReason == .codePlaceholder)
                .overlay {
                    CopyIntentButton(rawEntry: entry.data.rawEntry) {
                        Rectangle()
                            .foregroundStyle(Color.clear)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }

                if entry != entries.filter({ $0.kind != .placeholder }).last {
                    Divider()
                        .foregroundStyle(.gray15)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .blur(radius: isAnyEntryHidden ? 21 : 0)
        .overlay {
            if isRevealTokenOverlayVisible, isAnyEntryHidden, let secret = entries.first?.data.secret {
                RevealTokenIntentButton(secret: secret) {
                    RevealTokenOverlayView()
                }
            }
        }
    }
    
    @ViewBuilder
    private func generateLine(
        entry: CodeEntry.Entry,
        data: CodeEntry.EntryData,
        reason: RedactionReasons
    ) -> some View {
        HStack(alignment: .center, spacing: 0) {
            ServiceIconView(icon: data.icon, dimension: 24)
                .padding(.trailing, 12)
                .redacted(reason: reason)

            VStack(alignment: .leading, spacing: 2) {
                Text(data.name)
                    .foregroundStyle(.labelsPrimary)
                    .textStyle(.subheadline, .emphasized)
                    .redacted(reason: reason)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                
                if let info = data.info, !info.isEmpty {
                    Text(info)
                        .foregroundStyle(.labelsSecondary)
                        .textStyle(.caption1)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(verbatim: data.code)
                .foregroundStyle(.labelsPrimary)
                .textStyle(.token)
                .monospacedDigit()
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .contentTransition(.numericText())
                .redacted(reason: reason)
            
            CountdownTimerText(date: data.countdownTo)
                .redacted(reason: reason)
        }
    }
}
