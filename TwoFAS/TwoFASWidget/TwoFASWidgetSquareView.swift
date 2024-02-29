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

struct TwoFASWidgetSquareView: View {
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode
    
    private let spacing: CGFloat = 8
    
    let entry: CodeEntry.Entry?
        
    private var entryValue: CodeEntry.Entry {
        if let entry {
            return entry
        }
        return .placeholder()
    }
    
    @ViewBuilder
    var body: some View {
        let entryData = entryValue.data
        let kind = entryValue.kind
        
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
        if showLogo() {
            image()
        } else {
            CopyIntentButton(rawEntry: entryData.rawEntry) {
                VStack(alignment: .leading, spacing: nil) {
                    Spacer()
                    HStack(alignment: .center, spacing: nil) {
                        IconRenderer(entry: entryValue)
                            .redacted(reason: reason)
                        Spacer()
                        counterText(for: entryData.countdownTo)
                            .multilineTextAlignment(.trailing)
                            .font(Font.body.monospacedDigit())
                            .lineLimit(1)
                            .redacted(reason: reason)
                            .contentTransition(.numericText(countsDown: true))
                    }
                    Spacer(minLength: spacing * 3)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(entryData.name)
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                            .redacted(reason: reason)
                        Text(entryData.code)
                            .font(Font.system(.title).weight(.light).monospacedDigit())
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.2)
                            .redacted(reason: codeReason)
                            .contentTransition(.numericText())
                        let info = entryData.info ?? ""
                        Text(info)
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .redacted(reason: reason)
                    }
                    Spacer()
                }
                .addWidgetContentMargins(standard: spacing)
                .accessibility(hidden: codeReason == .codePlaceholder)
            }
        }
    }
    
    @ViewBuilder
    func image() -> some View {
        Image("LogoWidgetMono")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: 40, height: 40, alignment: .center)
            .widgetAccentable()
            .opacity(0.4)
            .unredacted()
            .addWidgetContentMargins()
    }
    
    func showLogo() -> Bool {
        if #available(iOS 17.0, *) {
            if redactionReasons.contains(.invalidated) {
                return true
            }
        }

        return false
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
