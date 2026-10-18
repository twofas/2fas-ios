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

/// Prominent save/confirm action for navigation bars.
///
/// When enabled the button is filled with the app tint and a white label.
/// When disabled it collapses to a plain, dimmed label.
///
/// ```swift
/// ToolbarItem(placement: .topBarTrailing) {
///     TFSaveButton(T.Commons.pair, isEnabled: presenter.isAddServiceEnabled) {
///         presenter.handlePair()
///     }
/// }
/// ```
public struct TFSaveButton: View {
    private let title: String
    private let isEnabled: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .textStyle(.body, .emphasized)
                .foregroundStyle(isEnabled ? .graysWhite : .labelsVibrantTertiary)
        }
        .modify {
            if isEnabled {
                $0.buttonStyle(.borderedProminent)
                    .tint(.accentsBrand)
            } else {
                $0
            }
        }
        .disabled(!isEnabled)
    }
}
