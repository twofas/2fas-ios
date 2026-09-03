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

import Foundation

final class BrowserExtensionIntroPresenter {
    let steps: [BrowserExtensionIntroStep] = [
        .init(title: T.Browser.infoDescriptionFirst, icon: .download, description: nil, hasAction: false),
        .init(title: T.Browser.infoDescriptionSecond, icon: .link, description: nil, hasAction: true)
    ]

    private let flowController: BrowserExtensionIntroFlowControlling
    private let interactor: BrowserExtensionIntroModuleInteracting

    init(flowController: BrowserExtensionIntroFlowControlling, interactor: BrowserExtensionIntroModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension BrowserExtensionIntroPresenter {
    func handleAction() {
        checkPushNotificationPermission()
    }

    func handlePushNotificationClosed() {
        checkCameraPermission()
    }
}

private extension BrowserExtensionIntroPresenter {
    func checkPushNotificationPermission() {
        if interactor.shouldAskForPushNotifications {
            flowController.toPushNotifications()
        } else {
            checkCameraPermission()
        }
    }

    func checkCameraPermission() {
        if interactor.isCameraAvailable() {
            if interactor.isCameraAllowed() {
                flowController.toCamera()
            } else {
                interactor.registerCamera { [weak self] isGranted in
                    if isGranted {
                        self?.flowController.toCamera()
                    } else {
                        self?.cameraNotAvailable()
                    }
                }
            }
        } else {
            cameraNotAvailable()
        }
    }

    func cameraNotAvailable() {
        flowController.toCameraNotAvailable()
    }
}
