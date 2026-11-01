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
import Common
import Data

@Observable
final class ComposeServiceRouter {
    var path: [ComposeServiceRoute] = []

    weak var presenter: ComposeServicePresenter?
    weak var viewController: UIViewController?

    private var iconEditorPresenter: IconEditorPresenter?
    private var userIconInfoPresenter: UserIconInfoPresenter?
    private var advancedSummaryPresenter: ComposeServiceAdvancedSummaryPresenter?
    private var webExtensionPresenter: ComposeServiceWebExtensionPresenter?
    private var categorySelectionPresenter: ComposeServiceCategorySelectionPresenter?

    // MARK: - Navigation intents (called by ComposeServicePresenter)

    func showIconEditor(value: IconEditorValue, animated: Bool) {
        iconEditorPresenter = IconEditorPresenter(
            flowController: self,
            interactor: ModuleInteractorFactory.shared.iconEditorModuleInteractor(),
            value: value
        )
        push(.iconEditor, animated: animated)
    }

    func showAdvancedSummary(settings: ComposeServiceAdvancedSettings) {
        let interactor = ModuleInteractorFactory
            .shared
            .composeServiceAdvancedSummaryModuleInteractor(settings: settings)
        advancedSummaryPresenter = ComposeServiceAdvancedSummaryPresenter(
            flowController: self,
            interactor: interactor
        )
        push(.advancedSummary)
    }

    func showBrowserExtension(secret: String) {
        let interactor = ModuleInteractorFactory.shared.composeServiceWebExtensionModuleInteractor(secret: secret)
        webExtensionPresenter = ComposeServiceWebExtensionPresenter(flowController: self, interactor: interactor)
        push(.browserExtension)
    }

    func showCategorySelection(selectedSection: SectionID?) {
        let interactor = ModuleInteractorFactory
            .shared
            .composeServiceCategorySelectionModuleInteractor(with: selectedSection)
        categorySelectionPresenter = ComposeServiceCategorySelectionPresenter(
            flowController: self,
            interactor: interactor
        )
        push(.categorySelection)
    }

    // MARK: - Destinations

    @ViewBuilder
    func destination(for route: ComposeServiceRoute) -> some View {
        Group {
            switch route {
            case .iconEditor:
                if let iconEditorPresenter {
                    IconEditorView(presenter: iconEditorPresenter)
                }
            case .userIconInfo:
                if let userIconInfoPresenter {
                    UserIconInfoView(presenter: userIconInfoPresenter)
                }
            case .advancedSummary:
                if let advancedSummaryPresenter {
                    ComposeServiceAdvancedSummaryView(presenter: advancedSummaryPresenter)
                }
            case .browserExtension:
                if let webExtensionPresenter {
                    ComposeServiceWebExtensionView(presenter: webExtensionPresenter)
                }
            case .categorySelection:
                if let categorySelectionPresenter {
                    ComposeServiceCategorySelectionView(presenter: categorySelectionPresenter)
                }
            }
        }
        .chevronOnlyBackButton()
    }

    // MARK: - Stack helpers

    private func push(_ route: ComposeServiceRoute, animated: Bool = true) {
        if animated {
            path.append(route)
        } else {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                path.append(route)
            }
        }
    }

    private func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}

// MARK: - IconEditorFlowControlling

extension ComposeServiceRouter: IconEditorFlowControlling {
    func toSave(_ value: IconEditorValue) {
        presenter?.handleIconEditorSave(value)
        pop()
    }

    func toUserIcon() {
        AppEventLog(.orderIconClick)
        AppEventLog(.orderIconAsUser)
        userIconInfoPresenter = UserIconInfoPresenter(flowController: self)
        push(.userIconInfo)
    }

    func toCompanyIcon() {
        AppEventLog(.orderIconClick)
        AppEventLog(.orderIconAsCompany)
        UIApplication.shared.open(
            URL(string: "https://2fas.com/your-branding/")!,
            options: [:],
            completionHandler: nil
        )
    }
}

// MARK: - UserIconInfoFlowControlling

extension ComposeServiceRouter: UserIconInfoFlowControlling {
    func toSocial() {
        UIApplication.shared.open(SocialChannel.discord.url, completionHandler: nil)
    }

    func toShare() {
        let vc = ShareActivityController.createWithText(T.Tokens.requestIconProviderMessage)
        viewController?.present(vc, animated: true, completion: nil)
    }
}

// MARK: - ComposeServiceAdvancedSummaryFlowControlling

extension ComposeServiceRouter: ComposeServiceAdvancedSummaryFlowControlling {}

// MARK: - ComposeServiceWebExtensionFlowControlling

extension ComposeServiceRouter: ComposeServiceWebExtensionFlowControlling {
    func toFinish() {
        pop()
    }
}

// MARK: - ComposeServiceCategorySelectionFlowControlling

extension ComposeServiceRouter: ComposeServiceCategorySelectionFlowControlling {
    func toChangeSection(_ sectionID: SectionID?) {
        presenter?.handleSectionSelected(sectionID)
    }
}

extension ComposeServiceRouter {
    func close() {
        pop()
    }
}
