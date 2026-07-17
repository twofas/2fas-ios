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

final class RootNavigationController: UINavigationController {
    var rootFlowController: FlowController!
    var keepsFullStack: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        guard #unavailable(iOS 26.0) else { return }

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
        navigationBar.standardAppearance = navBarAppearance
        navigationBar.scrollEdgeAppearance = navBarAppearance
    }
}

extension RootNavigationController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard !keepsFullStack else { return }
        guard let last = viewControllers.last else { return }
        viewControllers = [last]
    }
}
