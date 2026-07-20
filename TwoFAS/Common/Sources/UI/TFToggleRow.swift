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

/// A capsule-shaped toggle row sitting on `.backgroundsSecondary`,
/// used for inline confirmation switches (e.g. "I want to delete this token").
///
/// - 16 pt horizontal insets
/// - Max corner radius from `TFCornerRadius` (`.extraLarge`)
/// - Uses `AppColor.accentsBrand` as the toggle tint
public struct TFToggleRow: View {
    private let title: String
    private let isElevated: Bool
    @Binding private var isOn: Bool

    /// - Parameter isElevated: Pass `true` when the row sits on a
    ///   `.backgroundsPrimaryElevated` screen, so it uses
    ///   `.backgroundsGroupedTertiary` instead of the default
    ///   `.backgroundsSecondary`.
    public init(_ title: String, isOn: Binding<Bool>, isElevated: Bool = false) {
        self.title = title
        self._isOn = isOn
        self.isElevated = isElevated
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .textStyle(.body)
                .foregroundStyle(AppColor.labelsPrimary)
                .multilineTextAlignment(.leading)
        }
        .tint(AppColor.accentsBrand)
        .padding(.horizontal, .XL)
        .padding(.vertical, .L)
        .background {
            RoundedRectangle(.extraLarge)
                .foregroundStyle(isElevated ? AppColor.backgroundsGroupedTertiary : AppColor.backgroundsSecondary)
        }
    }
}
