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
import Common
import Data

/// Drives the whole Guide flow through a single SwiftUI `NavigationStack`.
/// Builds the pushed screens (menu, pages) and plays the role of the modules'
/// flow controllers, delegating terminal actions (add manually, scanner, close)
/// to `GuideSelectorFlowController`.
final class GuideRouter: ObservableObject {
    @Published var path: [GuideRoute] = []

    weak var flowController: GuideSelectorFlowController?

    private var menuPresenter: GuideMenuPresenter?
    private var pagesPresenter: GuidePagesPresenter?

    @ViewBuilder
    func destination(for route: GuideRoute) -> some View {
        Group {
            switch route {
            case .menu:
                if let menuPresenter {
                    GuideMenuView(presenter: menuPresenter)
                }
            case .pages:
                if let pagesPresenter {
                    GuidePagesView(presenter: pagesPresenter)
                }
            }
        }
        .chevronOnlyBackButton()
    }

    private func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}

// MARK: - GuideSelectorFlowControlling

extension GuideRouter: GuideSelectorFlowControlling {
    func toClose() {
        flowController?.close()
    }

    func toGuideMenu(_ guide: GuideDescription) {
        menuPresenter = GuideMenuPresenter(flowController: self, guide: guide)
        path.append(.menu)
    }
}

// MARK: - GuideMenuFlowControlling

extension GuideRouter: GuideMenuFlowControlling {
    func toMenuPosition(_ menu: GuideDescription.MenuPosition) {
        pagesPresenter = GuidePagesPresenter(flowController: self, content: menu)
        path.append(.pages)
    }

    func back() {
        pop()
    }
}

// MARK: - GuidePagesFlowControlling

extension GuideRouter: GuidePagesFlowControlling {
    func toAddManually(with data: String?) {
        flowController?.addManually(with: data)
    }

    func toCodeScanner() {
        flowController?.codeScanner()
    }

    func toMenu() {
        pop()
    }

    func close() {
        flowController?.close()
    }
}
