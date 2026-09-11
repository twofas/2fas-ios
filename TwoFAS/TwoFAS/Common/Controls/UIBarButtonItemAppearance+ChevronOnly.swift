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

import UIKit

extension UIBarButtonItemAppearance {
    /// A back-button appearance that shows only the chevron (no previous-screen
    /// title). Applied globally via `UINavigationBarAppearance.backButtonAppearance`
    /// on iOS 18 and below; on iOS 26 the Liquid Glass back button is already
    /// chevron-only by default.
    ///
    /// The title is pushed far off-screen instead of hidden, which keeps the
    /// chevron pinned to the leading edge.
    static var chevronOnly: UIBarButtonItemAppearance {
        let appearance = UIBarButtonItemAppearance()
        let offset = UIOffset(horizontal: -10_000, vertical: 0)
        appearance.normal.titlePositionAdjustment = offset
        appearance.highlighted.titlePositionAdjustment = offset
        appearance.focused.titlePositionAdjustment = offset
        appearance.disabled.titlePositionAdjustment = offset
        return appearance
    }
}
