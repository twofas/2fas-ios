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

final class AskForAuthRouter: ObservableObject {
    @Published var path: [AskForAuthRoute] = []

    var flowController: AskForAuthFlowController?

    private var selectServicePresenter: SelectServicePresenter?

    @ViewBuilder
    func destination(for route: AskForAuthRoute) -> some View {
        Group {
            switch route {
            case .selectService:
                if let selectServicePresenter {
                    SelectServiceView(presenter: selectServicePresenter)
                }
            }
        }
        .chevronOnlyBackButton()
    }
}

extension AskForAuthRouter: AskForAuthFlowControlling {
    func toAuth(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest) {
        flowController?.allow(auth: auth, pair: pair)
    }

    func toSelectService(auth: WebExtensionAwaitingAuth) {
        selectServicePresenter = SelectServicePresenter(
            interactor: ModuleInteractorFactory.shared.selectServiceModuleInteractor(),
            flowController: self,
            authRequest: auth
        )
        path.append(.selectService)
    }

    func toCancel(tokenRequestID: String) {
        flowController?.deny(tokenRequestID: tokenRequestID)
    }
}

extension AskForAuthRouter: SelectServiceFlowControlling {
    func toServiceSelection(with serviceData: ServiceData, authRequest: WebExtensionAwaitingAuth, save: Bool) {
        flowController?.didSelectService(serviceData, auth: authRequest, save: save)
    }
}
