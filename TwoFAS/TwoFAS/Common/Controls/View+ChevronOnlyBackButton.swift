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
import UIKit

extension View {
    /// Renders the navigation back button as a chevron only (no previous-screen
    /// title) inside a SwiftUI `NavigationStack` on iOS 18 and below.
    ///
    /// SwiftUI ignores the global `UINavigationBarAppearance.backButtonAppearance`
    /// proxy, so this reaches the stack's underlying `UINavigationController` and
    /// sets `backButtonDisplayMode = .minimal` on every item. That keeps the real
    /// system back button (and the interactive swipe-back gesture) while hiding the
    /// title. Apply it to each pushed destination view.
    ///
    /// On iOS 26 the Liquid Glass back button is already chevron-only, so this is
    /// a no-op there.
    @ViewBuilder
    func chevronOnlyBackButton() -> some View {
        if #available(iOS 26.0, *) {
            self
        } else {
            background(MinimalBackButtonConfigurator())
        }
    }
}

/// Empty helper view controller that walks up to its enclosing
/// `UINavigationController` and forces a minimal (chevron-only) back button on
/// every item in the stack.
private struct MinimalBackButtonConfigurator: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {
        uiViewController.applyMinimalBackButton()
    }

    final class Controller: UIViewController {
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            applyMinimalBackButton()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            applyMinimalBackButton()
        }

        func applyMinimalBackButton() {
            // Defer so the navigation stack has finished wiring up this controller.
            DispatchQueue.main.async { [weak self] in
                guard let controllers = self?.navigationController?.viewControllers else { return }
                for controller in controllers {
                    controller.navigationItem.backButtonDisplayMode = .minimal
                }
            }
        }
    }
}
