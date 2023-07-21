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
import UIKit
import CodeSupport
import Common
import Storage

final class SelectFromGalleryPresenter {
    private let flowController: SelectFromGalleryFlowControlling
    private let interactor: SelectFromGalleryModuleInteracting
    
    init(flowController: SelectFromGalleryFlowControlling, interactor: SelectFromGalleryModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
        
        interactor.shouldRename = { [weak self] in self?.handleShouldRename(currentName: $0, secret: $1) }
        interactor.serviceWasCreated = { [weak self] in self?.handleServiceWasCreated(serviceData: $0) }
    }
}

extension SelectFromGalleryPresenter {
    func handlePickerDidCancel() {
        flowController.toCancel()
    }
    
    func handleScanError() {
        flowController.toErrorWhileScanning()
    }
    
    func handleScannedImage(_ image: UIImage) {
        interactor.scanImage(image) { [weak self] result in
            switch result {
            case .noCodes:
                self?.flowController.toNoCodesFound()
            case .scanError:
                self?.flowController.toErrorWhileScanning()
            case .codeTypes(let codeTypes):
                self?.handleCodeTypes(codeTypes)
            }
        }
    }
    
    func handleGoogleAuthImport(_ codes: [Code]) {
        guard !codes.isEmpty else { return }
        interactor.addSelectedCodes(codes)
        flowController.toDidImport()
    }
    
    func handleLastPassImport(_ codes: [Code]) {
        guard !codes.isEmpty else { return }
        interactor.addSelectedCodes(codes)
        flowController.toDidImport()
    }
    
    func handleSelectedCode(_ code: Code) {
        handleService(code)
    }
    
    func handleRename(newName: String, secret: String) {
        interactor.renameService(newName: newName, secret: secret)
    }
    
    func handleCancelRename(secret: String) {
        interactor.cancelRenaming(secret: secret)
    }
}

private extension SelectFromGalleryPresenter {
    func handleCodeTypes(_ codeTypes: [CodeType]) {
        guard codeTypes.count > 1 else {
            handleOneCodeType(codeTypes.first!)
            return
        }
        
        let filteredCodes: [Code] = codeTypes.compactMap({
            switch $0 {
            case .service(let code): return code
            default: return nil
            }
        })
        
        if filteredCodes.count == 1 {
            handleService(filteredCodes.first!)
            return
        }
        
        Log("SelectFromGalleryPresenter: Handling multiple codes - user should select")
        flowController.toSelectCode(from: filteredCodes)
    }
    
    func handleOneCodeType(_ codeType: CodeType) {
        switch codeType {
        case .service(let code):
            handleService(code)
        case .googleAuth(let codes):
            Log("SelectFromGalleryPresenter: Found Google Auth codes: \(codes.count)")
            Log("Codes: \(codes)", save: false)
            
            let importableCodes = interactor.filterImportableCodes(codes)
            flowController.toGoogleAuthSummary(
                importable: importableCodes.count,
                total: codes.count,
                codes: importableCodes
            )
        case .lastPass(let codes):
            Log("SelectFromGalleryPresenter: Found LastPass codes: \(codes.count)")
            Log("Codes: \(codes)", save: false)
            
            let importableCodes = interactor.filterImportableCodes(codes)
            flowController.toLastPassSummary(
                importable: importableCodes.count,
                total: codes.count,
                codes: importableCodes
            )
        case .appStore:
            Log("SelectFromGalleryPresenter: Found wrong code", save: false)
            Log("SelectFromGalleryPresenter: It's app store link!")
            flowController.toAppStore()
        case .support(let auditID):
            Log("SelectFromGalleryPresenter: Found support link! AuditID: \(auditID)")
            flowController.toSendLogs(auditID: auditID)
        default:
            Log("SelectFromGalleryPresenter: Found wrong code", save: false)
            Log("SelectFromGalleryPresenter: General wrong code")
            flowController.toErrorWhileScanning()
        }
    }
    
    func handleService(_ code: Code) {
        Log("SelectFromGalleryPresenter: Found code: \(code)")
        if interactor.codeExists(code) {
            flowController.toDuplicatedCode(usedIn: interactor.codeUsedIn(code))
            return
        }
        interactor.addSelectedCode(code)
    }
    
    func handleShouldRename(currentName: String, secret: String) {
        flowController.toRename(currentName: currentName, secret: secret)
    }
    
    func handleServiceWasCreated(serviceData: ServiceData) {
        flowController.toDidAddCode(serviceData: serviceData)
    }
}
