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
import Observation
import Data
import Common

enum AddingServiceAlert: Identifiable, Hashable {
    var id: Self { self }

    case cantPairWatch
    case appStore
    case generalError
    case duplicatedCode(code: Code)
}

@Observable
final class AddingServicePresenter {
    var freezeCamera = false
    var isCameraUnavailable = false
    var alert: AddingServiceAlert?

    // Renaming
    var showRename = false {
        didSet { updateKeyboardAvoidance() }
    }
    var currentName = ""
    var secret = ""

    // PairWatchQuestion
    var showPairWatchQuestion = false {
        didSet { updateKeyboardAvoidance() }
    }
    var deviceCodePath: DeviceCodePath?

    private let flowController: AddingServiceFlowControlling
    private let interactor: AddingServiceModuleInteracting

    init(flowController: AddingServiceFlowControlling, interactor: AddingServiceModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor

        interactor.shouldRename = { [weak self] in self?.handleShouldRename(currentName: $0, secret: $1) }
        interactor.serviceWasCreated = { [weak self] in self?.handleServiceWasCreated(serviceData: $0) }
        interactor.checkCameraPermission { [weak self] available in
            self?.isCameraUnavailable = !available
        }
        flowController.onOverlayDismissed = { [weak self] in self?.handleOverlayDismissed() }
    }
}

extension AddingServicePresenter {
    func handleFoundCode(codeType: CodeType) {
        guard !freezeCamera else { return }
        freezeCamera = true
        
        switch codeType {
        case .service(let code):
            Log("AddingServiceMainPresenter: Found code: \(code)")
            if interactor.codeExists(code) {
                guard let description = interactor.serviceDescription(for: code) else { return }
                Log("AddingServiceMainPresenter: Found code: \(code) which is a duplicate of: \(description)")
                alert = .duplicatedCode(code: code)
            } else {
                Log("AddingServiceMainPresenter: Adding unique code: \(code)")
                interactor.addCode(code, force: false)
            }
        case .googleAuth(let codes):
            let importableCodes = interactor.filterImportableCodes(codes)
            flowController.toGoogleAuthSummary(
                importable: importableCodes.count,
                total: codes.count,
                codes: importableCodes
            )
        case .lastPass(let codes, let totalCodesCount):
            let importableCodes = interactor.filterImportableCodes(codes)
            flowController.toLastPassSummary(
                importable: importableCodes.count,
                total: totalCodesCount,
                codes: importableCodes
            )
        case .appStore:
            Log("AddingServiceMainPresenter: Found wrong code: \(codeType)", save: false)
            Log("AddingServiceMainPresenter: It's an app store link!")
            alert = .appStore
        case .twoFASWebExtension(let extensionID):
            Log("AddingServiceMainPresenter: Found 2FAS Web Extension code for: \(codeType)", save: false)
            Log("AddingServiceMainPresenter: It's a 2FAS Web Extension!")
            if interactor.wasUserAskedAboutPush {
                flowController.toTwoFASWebExtensionPairing(for: extensionID)
            } else {
                flowController.toPushPermissions(for: extensionID)
            }
        case .pairWatch(let deviceCodePath):
            Log("AddingServiceMainPresenter: Found Device Code Path: \(deviceCodePath.codePath)")
            if interactor.canPairWatch {
                self.deviceCodePath = deviceCodePath
                showPairWatchQuestion = true
            } else {
                alert = .cantPairWatch
            }
        case .open:
            Log("CameraScannerPresenter: Found 2FAS open request.")
        case .unknown:
            Log("AddingServiceMainPresenter: Found wrong code: \(codeType)", save: false)
            Log("AddingServiceMainPresenter: General wrong code")
            alert = .generalError
        }
    }
    
    func onForceAddCode(_ code: Code) {
        interactor.addCode(code, force: true)
    }
        
    func handleToGallery() {
        presentOverlay()
        flowController.toGallery()
    }

    func handleToAddManually() {
        presentOverlay()
        flowController.toAddManually()
    }

    func handleToGuides() {
        presentOverlay()
        flowController.toGuides()
    }
    
    func handleToAppSettings() {
        flowController.toAppSettings()
    }
    
    func handleRename(newName: String) {
        guard secret.isEmpty == false else { return }
        interactor.renameService(newName: newName, secret: secret)
        guard let serviceData = interactor.service(for: secret) else { return }
        self.currentName = ""
        self.secret = ""
        flowController.toToken(serviceData: serviceData)
    }
    
    func handleCancelRename() {
        guard secret.isEmpty == false else { return }
        let secretValue = secret
        interactor.cancelRenaming(secret: secretValue)
        self.currentName = ""
        self.secret = ""
        guard let serviceData = interactor.service(for: secretValue) else { return }
        flowController.toToken(serviceData: serviceData)
    }
    
    func handleResumeCamera() {
        freezeCamera = false
    }
    
    func onClose() {
        flowController.close()
    }
    
    func handleAppleWatchPairing(deviceName: String) {
        guard let deviceCodePath else { return }
        interactor.pairAppleWatch(deviceCodePath: deviceCodePath, deviceName: deviceName)
        flowController.close()
    }
}

private extension AddingServicePresenter {
    func handleShouldRename(currentName: String, secret: String) {
        self.currentName = currentName
        self.secret = secret
        showRename = true
    }

    func handleServiceWasCreated(serviceData: ServiceData) {
        flowController.toToken(serviceData: serviceData)
    }

    func presentOverlay() {
        freezeCamera = true
    }

    func handleOverlayDismissed() {
        freezeCamera = false
    }

    func updateKeyboardAvoidance() {
        flowController.setCardAvoidsKeyboard(showRename || showPairWatchQuestion)
    }
}
