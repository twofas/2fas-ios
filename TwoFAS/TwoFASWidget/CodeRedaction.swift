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

enum RedactionReason {
    case codePlaceholder
    case noPlaceholder
}

struct CodePlaceholder: ViewModifier {
    private let toRange = Int(Digits.defaultValue.rawValue)
    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .accessibility(label: Text("widget__placeholder"))
            .accessibility(hidden: true)
            .opacity(0)
            .overlay(
                HStack(alignment: .center, spacing: 5) {
                    ForEach(0..<toRange, id: \.self) { index in
                        placeholder()
                        if index == Int(floor(CGFloat(Digits.defaultValue.rawValue - 1) / 2.0)) {
                            Spacer()
                        }
                    }
                }
                    .padding(.leading, 12)
            )
    }
    
    private func placeholder() -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color(UIColor.systemGray4))
            .frame(width: 12, height: 26, alignment: .leading)
    }
}

struct RedactableView: ViewModifier {
    let reason: RedactionReason?
    
    @ViewBuilder
    func body(content: Content) -> some View {
        switch reason {
        case .codePlaceholder:
            content
                .modifier(CodePlaceholder())
        case .noPlaceholder:
            content
        case nil:
            content
        }
    }
}

extension View {
    func redacted(reason: RedactionReason?) -> some View {
        self
            .modifier(RedactableView(reason: reason))
    }
}
