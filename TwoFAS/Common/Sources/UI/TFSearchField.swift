//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

#if os(iOS)
public struct TFSearchField: View {
    @Binding
    private var text: String
    private let prompt: String

    @FocusState
    private var isFocused: Bool
    @State
    private var clearTapped = false
    @Environment(\.colorScheme)
    private var colorScheme

    public init(text: Binding<String>, prompt: String) {
        self._text = text
        self.prompt = prompt
    }

    public var body: some View {
        HStack(spacing: .M) {
            Image(icon: .magnifyingglass)
                .textStyle(.title3)
                .foregroundStyle(.labelsPrimary)
                .accessibilityHidden(true)

            TextField("", text: $text, prompt: Text(prompt).foregroundStyle(AppColor.graysGray))
                .focused($isFocused)
                .textStyle(.body)
                .foregroundStyle(.labelsPrimary)
                .accentColor(AppColor.accentsBrand.color(for: colorScheme))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .onSubmit {
                    isFocused = false
                }

            if !text.isEmpty {
                Button {
                    clearTapped.toggle()
                    text = ""
                } label: {
                    Image(icon: .xmarkCircleFill)
                        .resizable()
                        .frame(width: Size.mediumIconSize, height: Size.mediumIconSize)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.labelsTertiary)
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: clearTapped) { _, new in new }
            }
        }
        .padding(.horizontal, .L)
        .frame(minHeight: Size.searchFieldHeight)
        .background {
            Capsule()
                .foregroundStyle(AppColor.fillsTertiary)
        }
        .contentShape(Capsule())
        .onTapGesture {
            isFocused = true
        }
    }
}

private extension Size {
    static let searchFieldHeight: CGFloat = 44
}

#Preview {
    TFSearchFieldPreview()
}

private struct TFSearchFieldPreview: View {
    @State
    private var text = ""

    var body: some View {
        TFSearchField(text: $text, prompt: "Search")
            .padding()
    }
}
#endif
