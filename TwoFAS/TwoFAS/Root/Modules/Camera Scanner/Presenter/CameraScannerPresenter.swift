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
import Data

final class CameraScannerPresenter {
    weak var view: CameraScannerViewControlling?
        
    private var lockScanning = false
    
    private let flowController: CameraScannerFlowControlling
    private let interactor: CameraScannerModuleInteracting
    
    init(flowController: CameraScannerFlowControlling, interactor: CameraScannerModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
        
        interactor.shouldRename = { [weak self] in self?.handleShouldRename(currentName: $0, secret: $1) }
        interactor.serviceWasCreated = { [weak self] in self?.handleServiceWasCreated(serviceData: $0) }
    }
}

extension CameraScannerPresenter {
    func viewDidAppear() {
        if interactor.isCameraAvailable() {
            if !interactor.isCameraAllowed() {
                interactor.registerCamera { [weak self] isGranted in
                    if !isGranted {
                        self?.handleCameraNotAvailable()
                    }
                }
            }
        } else {
            handleCameraNotAvailable()
        }
    }
    
    func handleOpenGallery() {
        lockScanning = true
        flowController.toGallery()
    }
    
    func handleGalleryCancelled() {
        lockScanning = false
    }
    
    func handleCancel() {
        flowController.toFinish()
    }
    
    func handleResumeScanning() {
        view?.disableOverlay()
        lockScanning = false
    }
    
    func handleGoogleAuthImport(_ codes: [Code]) {
        guard !codes.isEmpty else { return }
        AppEventLog(.importGoogleAuth)
        interactor.addCodes(codes)
        flowController.toImportSummary(count: codes.count)
    }
    
    func handleLastPassImport(_ codes: [Code]) {
        guard !codes.isEmpty else { return }
        AppEventLog(.importLastPass)
        interactor.addCodes(codes)
        flowController.toImportSummary(count: codes.count)
    }
    
    func handleDidFound(_ codeType: CodeType) {
        guard !lockScanning else { return }
        lockScanning = true
        
        switch codeType {
        case .service(let code):
            Log("CameraScannerPresenter: Found code: \(code)")
            if interactor.codeExists(code) {
                guard let description = interactor.serviceDescription(for: code) else { return }
                Log("CameraScannerPresenter: Found code: \(code) which is a duplicate of: \(description)")
                view?.enableOverlay()
                view?.feedback()
                flowController.toDuplicatedCode { [weak self] in
                    self?.interactor.addCode(code, force: true)
                }
            } else {
                Log("CameraScannerPresenter: Adding unique code: \(code)")
                view?.freezeCamera()
                interactor.addCode(code, force: false)
            }
        case .googleAuth(let codes):
            view?.enableOverlay()
            let importableCodes = interactor.filterImportableCodes(codes)
            flowController.toGoogleAuthSummary(
                importable: importableCodes.count,
                total: codes.count,
                codes: importableCodes
            )
        case .lastPass(let codes):
            view?.enableOverlay()
            let importableCodes = interactor.filterImportableCodes(codes)
            flowController.toLastPassSummary(
                importable: importableCodes.count,
                total: codes.count,
                codes: importableCodes
            )
        case .appStore:
            Log("CameraScannerPresenter: Found wrong code: \(codeType)", save: false)
            Log("CameraScannerPresenter: It's an app store link!")
            view?.enableOverlay()
            view?.feedback()
            flowController.toAppStore()
        case .twoFASWebExtension(let extensionID):
            Log("CameraScannerPresenter: Found 2FAS Web Extension code for: \(codeType)", save: false)
            Log("CameraScannerPresenter: It's a 2FAS Web Extension!")
            view?.enableOverlay()
            view?.feedback()
            if interactor.wasUserAskedAboutPush {
                flowController.toTwoFASWebExtensionPairing(for: extensionID)
            } else {
                flowController.toPushPermissions(extensionID: extensionID)
            }
        case .support(let auditID):
            Log("CameraScannerPresenter: Found 2FAS support request. AuditID: \(auditID)")
            view?.enableOverlay()
            view?.feedback()
            flowController.toSendLogs(auditID: auditID)
        case .unknown:
            Log("CameraScannerPresenter: Found wrong code: \(codeType)", save: false)
            Log("CameraScannerPresenter: General wrong code")
            view?.enableOverlay()
            view?.feedback()
            flowController.toGeneralError()
        }
    }
    
    func handleCameraNotAvailable() {
        view?.feedback()
        
        flowController.toCameraNotAvailable()
    }
    
    func handleCameraError(_ str: String) {
        view?.enableOverlay()
        view?.feedback()
        flowController.toCameraError(str)
    }
    
    func handleRename(newName: String, secret: String) {
        interactor.renameService(newName: newName, secret: secret)
    }
    
    func handleCancelRename(secret: String) {
        interactor.cancelRenaming(secret: secret)
    }
}

private extension CameraScannerPresenter {
    func handleShouldRename(currentName: String, secret: String) {
        flowController.toRename(currentName: currentName, secret: secret)
    }
    
    func handleServiceWasCreated(serviceData: ServiceData) {
        flowController.toServiceWasCreated(serviceData: serviceData)
    }
}
