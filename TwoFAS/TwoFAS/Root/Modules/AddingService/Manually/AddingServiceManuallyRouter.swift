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

final class AddingServiceManuallyRouter: ObservableObject {
    @Published var path: [AddingServiceManuallyRoute] = []

    var flowController: AddingServiceManuallyFlowController?
    weak var presenter: AddingServiceManuallyPresenter?

    private var advancedSettingsPresenter: AddingServiceAdvancedSettingsPresenter?
    private var iconEditorPresenter: IconEditorPresenter?
    private var userIconInfoPresenter: UserIconInfoPresenter?

    @ViewBuilder
    func destination(for route: AddingServiceManuallyRoute) -> some View {
        Group {
            switch route {
            case .advancedSettings:
                if let advancedSettingsPresenter {
                    AddingServiceAdvancedSettingsView(presenter: advancedSettingsPresenter)
                }
            case .iconEditor:
                if let iconEditorPresenter {
                    IconEditorView(presenter: iconEditorPresenter)
                }
            case .userIconInfo:
                if let userIconInfoPresenter {
                    UserIconInfoView(presenter: userIconInfoPresenter)
                }
            }
        }
        .chevronOnlyBackButton()
    }
}

// MARK: - AddingServiceManuallyFlowControlling

extension AddingServiceManuallyRouter: AddingServiceManuallyFlowControlling {
    func toClose(_ serviceData: ServiceData) {
        flowController?.close(serviceData)
    }

    func toClose() {
        flowController?.cancel()
    }

    func toAdvancedSettings(_ settings: AddingServiceAdvancedSettings) {
        advancedSettingsPresenter = AddingServiceAdvancedSettingsPresenter(
            flowController: self,
            settings: settings
        )
        path.append(.advancedSettings)
    }

    func toIconEditor(_ value: IconEditorValue) {
        iconEditorPresenter = IconEditorPresenter(
            flowController: self,
            interactor: ModuleInteractorFactory.shared.iconEditorModuleInteractor(),
            value: value
        )
        path.append(.iconEditor)
    }
}

// MARK: - AddingServiceAdvancedSettingsFlowControlling

extension AddingServiceManuallyRouter: AddingServiceAdvancedSettingsFlowControlling {
    func toUpdate(_ settings: AddingServiceAdvancedSettings) {
        presenter?.handleAdvancedSettings(settings)
    }
}

// MARK: - IconEditorFlowControlling

extension AddingServiceManuallyRouter: IconEditorFlowControlling {
    func toSave(_ value: IconEditorValue) {
        presenter?.handleIconEditorSave(value)
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func toUserIcon() {
        AppEventLog(.orderIconClick)
        AppEventLog(.orderIconAsUser)
        userIconInfoPresenter = UserIconInfoPresenter(flowController: self)
        path.append(.userIconInfo)
    }

    func toCompanyIcon() {
        AppEventLog(.orderIconClick)
        AppEventLog(.orderIconAsCompany)
        guard let url = URL(string: "https://2fas.com/your-branding/") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: - UserIconInfoFlowControlling

extension AddingServiceManuallyRouter: UserIconInfoFlowControlling {
    func toSocial() {
        UIApplication.shared.open(SocialChannel.discord.url, completionHandler: nil)
    }

    func toShare() {
        flowController?.share(T.Tokens.requestIconProviderMessage)
    }
}
