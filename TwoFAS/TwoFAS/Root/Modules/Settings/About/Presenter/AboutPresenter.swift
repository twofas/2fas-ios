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

@Observable
final class AboutPresenter {
    var sections: [AboutSection] = []
    var showsBackButton: Bool = true

    private let flowController: AboutFlowControlling
    let interactor: AboutModuleInteracting

    init(flowController: AboutFlowControlling, interactor: AboutModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }

    func handleBack() {
        flowController.close()
    }
}

extension AboutPresenter {
    var appVersion: String {
        interactor.currentAppVersion
    }

    func viewWillAppear() {
        reload()
    }

    func handleSelection(_ action: AboutCell.Action) {
        switch action {
        case .tos:
            flowController.toTOS()
        case .privacyPolicy:
            flowController.toPrivacyPolicy()
        case .writeReview:
            flowController.toWriteReview()
        case .share:
            flowController.toShare()
        case .sendLogs:
            flowController.toSendLogs()
        case .acknowledgements:
            flowController.toAcknowledgements()
        case .social(let channel):
            flowController.toSocial(channel)
        }
    }

    func handleToggle() {
        interactor.setCrashlyticsDisabled(!interactor.isCrashlyticsDisabled)
        reload()
    }
}

private extension AboutPresenter {
    func reload() {
        sections = buildMenu()
    }
}
