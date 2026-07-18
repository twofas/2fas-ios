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
import Common

@Observable
final class BrowserExtensionMainPresenter {
    var sections: [BrowserExtensionMainSection] = []
    var isLoading = false
    var showsBackButton = true
    var showRenameNickname = false

    static let nicknameMinLength = 3
    static let nicknameMaxLength = 60

    private let flowController: BrowserExtensionMainFlowControlling
    let interactor: BrowserExtensionMainModuleInteracting

    init(flowController: BrowserExtensionMainFlowControlling, interactor: BrowserExtensionMainModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }

    var currentNickname: String {
        interactor.deviceNickname
    }
}

extension BrowserExtensionMainPresenter {
    func viewWillAppear() {
        reload()
        interactor.updatePairedServices { [weak self] _ in self?.reload() }
    }

    func handleBack() {
        flowController.close()
    }

    func handleTap(_ cell: BrowserExtensionMainCell) {
        switch cell.kind {
        case .service(let name, let date, let id):
            flowController.toService(name: name, date: date, id: id)
        case .addNew:
            addNew()
        case .nickname:
            showRenameNickname = true
        }
    }

    func handleNameChange(_ newDeviceNickname: String) {
        isLoading = true
        interactor.changeDeviceNickname(newDeviceNickname) { [weak self] _ in
            self?.reload()
            self?.isLoading = false
        }
    }

    func isNicknameValid(_ value: String) -> Bool {
        let trimmed = value.trim()
        return trimmed.count >= Self.nicknameMinLength && trimmed.count <= Self.nicknameMaxLength
    }

    func handleServiceUnpairing(with id: String) {
        isLoading = true
        interactor.unpairService(with: id) { [weak self] _ in
            self?.reload()
            self?.isLoading = false
        }
    }

    func handleRefresh() {
        reload()
    }
}

private extension BrowserExtensionMainPresenter {
    func reload() {
        let menu = buildMenu()
        guard interactor.hasPairedServices else {
            flowController.toInitialScreen()
            return
        }
        flowController.toClearScreen()
        sections = menu
    }

    func addNew() {
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
