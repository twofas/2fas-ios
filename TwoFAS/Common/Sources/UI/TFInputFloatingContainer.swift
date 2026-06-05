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

struct TFInputFloatingContainer<Content: View, TrailingAccessory: View>: View {
    @Environment(\.isEnabled)
    private var isEnabled
    @Binding
    private var isEditing: Bool
    @Binding
    private var movePlaceholderUp: Bool
    private let title: String
    @Binding
    private var errorMessage: String?
    private let content: Content
    private let trailingAccessory: TrailingAccessory

    init(
        isEditing: Binding<Bool>,
        movePlaceholderUp: Binding<Bool>,
        title: String,
        errorMessage: Binding<String?>,
        @ViewBuilder content: () -> Content,
        @ViewBuilder trailingAccessory: () -> TrailingAccessory
    ) {
        _isEditing = isEditing
        _movePlaceholderUp = movePlaceholderUp
        self.title = title
        _errorMessage = errorMessage
        self.content = content()
        self.trailingAccessory = trailingAccessory()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .S) {
            HStack(spacing: .M) {
                VStack(alignment: .leading, spacing: movePlaceholderUp ? Spacing.XS.rawValue : 0) {
                    Text(title)
                        .foregroundStyle(isEnabled ? .labelsSecondary : .labelsQuaternary)
                        .textStyle(.caption1)
                        .opacity(movePlaceholderUp ? 1 : 0)
                        .frame(height: movePlaceholderUp ? nil : 0, alignment: .leading)
                        .padding(.top, .S)

                    HStack {
                        content
                    }
                    .clipShape(Rectangle())
                    .animation(Animation.easeInOut(duration: AnimationTiming.duration), value: isEditing)
                    .padding(.bottom, errorMessage == nil ? Spacing.S.rawValue : 0)
                }
                .frame(maxWidth: .infinity, alignment: movePlaceholderUp ? .topLeading : .leading)
                .animation(Animation.easeInOut(duration: AnimationTiming.duration), value: movePlaceholderUp)

                trailingAccessory
            }
            HStack(spacing: .S) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .frame(width: Size.smallIconSize, height: Size.smallIconSize)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.accentsBrand)
                
                Text(errorMessage ?? "")
                    .textStyle(.caption2)
                    .foregroundStyle(.accentsBrand)
            }
            .padding(.bottom, .S)
            .isHidden(errorMessage == nil, remove: true)
            .animation(Animation.easeInOut(duration: AnimationTiming.duration), value: isEditing)
        }
        .frame(minHeight: Size.textFieldHeight)
    }
}
