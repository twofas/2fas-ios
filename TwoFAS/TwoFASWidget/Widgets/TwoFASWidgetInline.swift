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

import WidgetKit
import SwiftUI
import Common

struct TwoFASWidgetInline: View {
    @Environment(\.redactionReasons) private var reasons
    let entry: CodeEntry.Entry?
    
    @ViewBuilder
    var body: some View {
        if isRedacted() {
            codePlaceholder()
        } else {
            if let kind = entry?.kind, let entryData = entry?.data {
                if kind == .placeholder {
                    codePlaceholder()
                } else {
                    code(entryData.code)
                }
            } else {
                codePlaceholder()
            }
        }
    }
    
    func isRedacted() -> Bool {
        if #available(iOS 17.0, *) {
            if reasons.contains(.invalidated) {
                return true
            }
        }
        
        if reasons.contains(.placeholder) || reasons.contains(.privacy) {
            return true
        }
        
        return false
    }
    
    @ViewBuilder
    func codePlaceholder() -> some View {
        code(CodeEntry.Entry.placeholder().data.code)
            .redacted(reason: .placeholder)
    }
    
    @ViewBuilder
    func code(_ code: String) -> some View {
        
        Label {
            Text(code)
                .font(Font.system(.title).weight(.medium).monospacedDigit())
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .frame(alignment: .center)
        } icon: {
            Image(systemName: "key.horizontal.fill")
                .resizable()
                .frame(width: 12, height: 21, alignment: .center)
                .foregroundColor(.white)
        }
    }
}
