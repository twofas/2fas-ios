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
        
        let codeReason: RedactionReason = {
            switch kind {
            case .placeholder, .singleEntryHidden: return .codePlaceholder
            default: return .noPlaceholder
            }
        }()
        
        if showLogo() {
            image()
        } else {
            VStack(alignment: .leading) {
                HStack {
                    IconRenderer(entry: entryValue)
                        .frame(width: 32, height: 32)
                    Spacer()
                    CountdownTimerText(date: entryData.countdownTo)
                        .redacted(reason: codeReason)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entryData.name)
                        .foregroundStyle(.textPrimary)
                        .font(.system(size: 12).weight(.regular).monospacedDigit())
                        .multilineTextAlignment(.leading)
                        .redacted(reason: codeReason)
                    Text(entryData.code)
                        .foregroundStyle(.textPrimary)
                        .font(.system(size: 31).weight(.light).monospacedDigit())
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.1)
                        .contentTransition(.numericText())
                        .redacted(reason: codeReason)
                    
                    if let info = entryData.info, !info.isEmpty {
                        Text(info)
                            .foregroundStyle(.textSecondary)
                            .lineLimit(1)
                            .font(.system(size: 12).weight(.regular))
                    }
                }
            }
            .blur(radius: kind == .singleEntryHidden ? 21 : 0)
            .accessibility(hidden: codeReason == .codePlaceholder)
            .overlay {
                if kind == .singleEntry {
                    CopyIntentButton(rawEntry: entryData.rawEntry) {
                        Rectangle()
                            .foregroundStyle(Color.clear)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else if kind == .singleEntryHidden {
                    RevealTokenIntentButton(secret: entryData.secret) {
                        RevealTokenOverlayView()
                    }
                }
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
}
