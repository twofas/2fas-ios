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

struct RevealTokenImage: View {
    var body: some View {
        Image("eye.slash2")
            .background(
                Circle()
                    .fill(Color.gray5)
                    .frame(width: 40, height: 40)
            )
    }
}

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
        
//        let reason: RedactionReasons = {
//            switch kind {
//            case .placeholder: return .placeholder
//            default: return []
//            }
//        }()
        
        let codeReason: RedactionReason = {
            switch kind {
            case .placeholder, .singleEntryHidden: return .codePlaceholder
            default: return .noPlaceholder
            }
        }()
        
//        let countDownReason: RedactionReasons = {
//            switch kind {
//            case .placeholder, .singleEntryHidden: return .placeholder
//            default: return []
//            }
//        }()
        
        if showLogo() {
            image()
        } else {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    IconRenderer(entry: entryValue)
                        .frame(width: 32, height: 32)
                    Spacer()
                    counterText(for: entryData.countdownTo)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .frame(width: 40)
                        .foregroundStyle(.primaryWhite)
                        .multilineTextAlignment(.center)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .contentTransition(.numericText(countsDown: true))
                        .background {
                            Capsule()
                                .fill(Color.primaryGreen)
                        }
                        .shadow(color: Color.primaryGreen.opacity(0.3), radius: 10, x: 0, y: 2)
                        .overlay {
                            Capsule()
                                .stroke(Color.primaryWhite, lineWidth: 1)
                        }
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(entryData.name)
                        .foregroundStyle(.primaryBlack)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                    Text(entryData.code)
                        .foregroundStyle(.primaryBlack)
                        .font(Font.system(.title).weight(.semibold).monospacedDigit())
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.2)
                        .contentTransition(.numericText())
                }
            }
            .blur(radius: kind == .singleEntryHidden ? 25 : 0)
            .widgetBackground(backgroundView: Color.primaryWhite)
            .accessibility(hidden: codeReason == .codePlaceholder)
            .overlay {
                if kind == .singleEntry {
                    CopyIntentButton(
                        rawEntry: entryData.rawEntry,
                        secret: kind == .singleEntryHidden ? entry?.data.secret : nil
                    ) {
                        Rectangle()
                            .foregroundStyle(Color.clear)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else if kind == .singleEntryHidden, let secret = entry?.data.secret {
                    RevealTokenIntentButton(secret: secret) {
                        VStack {
                            Spacer()
                            RevealTokenImage()
                            Spacer()
                            Text("Reveal for 60 seconds")
                                .foregroundStyle(Color.gray10)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    
    @ViewBuilder
    private func counterText(for date: Date?) -> some View {
        if let countdownTo = date {
            Text(countdownTo, style: .timer)
        } else {
            Text("0:00")
        }
    }
}
