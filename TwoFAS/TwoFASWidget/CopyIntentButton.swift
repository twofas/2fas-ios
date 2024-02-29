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

struct CopyIntentButton<Content>: View where Content: View {
    private let appIntent: CopyTokenIntent?
    private let content: () -> Content
    
    init(rawEntry: CodeEntry.EntryData.RawEntryData?, @ViewBuilder content: @escaping () -> Content) {
        if let rawEntry {
            self.appIntent = CopyTokenIntent(
                secret: rawEntry.secret,
                period: rawEntry.period,
                digits: rawEntry.digits,
                algorithm: rawEntry.algorithm,
                tokenType: rawEntry.tokenType
            )
        } else {
            self.appIntent = nil
        }
        self.content = content
    }
    
    @ViewBuilder
    var body: some View {
        if #available(iOS 17.0, *) {
            if let appIntent {
                Button(intent: appIntent, label: {
                    content()
                })
                .buttonStyle(.plain)
            } else {
                content()
            }
        } else {
            content()
        }
    }
}
