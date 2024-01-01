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
import Data
import Common

final class AddingServiceMainPresenter: ObservableObject {
    weak var view: AddingServiceMainViewControlling?
    
    @Published var freezeCamera = false
        
    private let flowController: AddingServiceMainFlowControlling
    private let interactor: AddingServiceMainModuleInteracting
    
    init(flowController: AddingServiceMainFlowControlling, interactor: AddingServiceMainModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
        
        interactor.shouldRename = { [weak self] in self?.handleShouldRename(currentName: $0, secret: $1) }
        interactor.serviceWasCreated = { [weak self] in self?.handleServiceWasCreated(serviceData: $0) }
    }
}

extension AddingServiceMainPresenter {
    func handleFoundCode(codeType: CodeType) {
        guard !freezeCamera else { return }
        freezeCamera = true
        
        switch codeType {
        case .service(let code):
            Log("CameraScannerPresenter: Found code: \(code)")
            if interactor.codeExists(code) {
                guard let description = interactor.serviceDescription(for: code) else { return }
                Log("CameraScannerPresenter: Found code: \(code) which is a duplicate of: \(description)")
                interactor.warning()
                flowController.toDuplicatedCode(usedIn: description)
            } else {
                Log("CameraScannerPresenter: Adding unique code: \(code)")
                interactor.addCode(code)
            }
        case .googleAuth(let codes):
            let importableCodes = interactor.filterImportableCodes(codes)
            flowController.toGoogleAuthSummary(
                importable: importableCodes.count,
                total: codes.count,
                codes: importableCodes
            )
        case .lastPass(let codes):
            let importableCodes = interactor.filterImportableCodes(codes)
            flowController.toLastPassSummary(
                importable: importableCodes.count,
                total: codes.count,
                codes: importableCodes
            )
        case .appStore:
            Log("CameraScannerPresenter: Found wrong code: \(codeType)", save: false)
            Log("CameraScannerPresenter: It's an app store link!")
            interactor.warning()
            flowController.toAppStore()
        case .twoFASWebExtension(let extensionID):
            Log("CameraScannerPresenter: Found 2FAS Web Extension code for: \(codeType)", save: false)
            Log("CameraScannerPresenter: It's a 2FAS Web Extension!")
            interactor.warning()
            if interactor.wasUserAskedAboutPush {
                flowController.toTwoFASWebExtensionPairing(for: extensionID)
            } else {
                flowController.toPushPermissions(for: extensionID)
            }
        case .support(let auditID):
            Log("CameraScannerPresenter: Found 2FAS support request. AuditID: \(auditID)")
            interactor.warning()
            flowController.toSendLogs(auditID: auditID)
        case .unknown:
            Log("CameraScannerPresenter: Found wrong code: \(codeType)", save: false)
            Log("CameraScannerPresenter: General wrong code")
            interactor.warning()
            flowController.toGeneralError()
        }
    }
        
    func handleToGallery() {
        flowController.toGallery()
    }
    
    func handleToAddManually() {
        flowController.toAddManually()
    }
    
    func handleToGuides() {
        flowController.toGuides()
    }
    
    func handleToAppSettings() {
        flowController.toAppSettings()
    }
    
    func handleCameraAvailability(callback: @escaping (Bool) -> Void) {
        interactor.checkCameraPermission { available in
            callback(available)
        }
    }
    
    func handleRename(newName: String, secret: String) {
        interactor.renameService(newName: newName, secret: secret)
        guard let serviceData = interactor.service(for: secret) else { return }
        flowController.toToken(serviceData: serviceData)
    }
    
    func handleCancelRename(secret: String) {
        interactor.cancelRenaming(secret: secret)
        guard let serviceData = interactor.service(for: secret) else { return }
        flowController.toToken(serviceData: serviceData)
    }
    
    func handleResumeCamera() {
        freezeCamera = false
    }
}

private extension AddingServiceMainPresenter {
    func handleShouldRename(currentName: String, secret: String) {
        flowController.toRename(currentName: currentName, secret: secret)
    }
    
    func handleServiceWasCreated(serviceData: ServiceData) {
        flowController.toToken(serviceData: serviceData)
    }
}
