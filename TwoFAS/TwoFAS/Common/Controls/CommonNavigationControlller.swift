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

import UIKit
import Common

class CommonNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard #unavailable(iOS 26.0) else { return }

        navigationBar.tintColor = AppColor.accentsBrand.uiColor

        let shadowLine = Asset.shadowLine.image
            .withRenderingMode(.alwaysTemplate)
            .resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .tile)

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.shadowImage = shadowLine
        navBarAppearance.shadowColor = AppColor.separatorsOpaque.uiColor
        navBarAppearance.titleTextAttributes = [.foregroundColor: AppColor.labelsPrimary.uiColor]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: AppColor.labelsPrimary.uiColor]
        navBarAppearance.backgroundColor = AppColor.backgroundsPrimary.uiColor
        navBarAppearance.backButtonAppearance = .chevronOnly
        navigationBar.standardAppearance = navBarAppearance
        navigationBar.scrollEdgeAppearance = navBarAppearance
    }
}
