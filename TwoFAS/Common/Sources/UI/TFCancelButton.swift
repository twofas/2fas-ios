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

// MARK: - TFCancelButton

/// A borderless, large dismiss/cancel button from the 2FAS button design system.
///
/// Wraps `TFButton` with the fixed `.borderless` variant and `.large` size that
/// every cancel button across the app shares, so call sites only provide the
/// localized title and the action.
///
/// ```swift
/// TFCancelButton(T.Commons.cancel, action: cancel)
/// TFCancelButton(T.Commons.cancel) { dismiss() }
/// ```
public struct TFCancelButton: View {
    private let title: String
    private let action: () -> Void

    public init(
        _ title: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        TFButton(title, variant: .borderless, size: .large, action: action)
    }
}
