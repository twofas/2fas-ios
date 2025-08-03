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

final class ImporterPreimportSummaryPresenter {
    weak var view: ImporterPreimportSummaryViewControlling?
    
    private let flowController: ImporterPreimportSummaryFlowControlling
    private let interactor: ImporterPreimportSummaryModuleInteracting
    private let externalImportService: ExternalImportService
    
    var countNew: Int {
        interactor.countNew
    }
    
    var countTotal: Int {
        interactor.countTotal
    }
    
    var isBackupFile: Bool {
        externalImportService == .twofas
    }
    
    var additionalIcon: UIImage? {
        switch externalImportService {
        case .aegis: Asset.externalImportAegis.image
        case .raivo: Asset.externalImportRavio.image
        case .lastPass: Asset.externalImportLastPass.image
        case .andOTP: Asset.externalImportAndOTP.image
        case .authenticatorPro: Asset.externalImportAuthenticatorPro.image
        case .googleAuth, .twofas, .otpAuthFile, .clipboard: nil
        }
    }
    
    var title: String {
        switch externalImportService {
        case .aegis: T.Externalimport.aegisTitle
        case .raivo: T.Externalimport.raivoTitle
        case .lastPass: T.Externalimport.lastpassTitle
        case .andOTP: T.Externalimport.andotpTitle
        case .authenticatorPro: T.Externalimport.authenticatorproTitle
        case .googleAuth, .twofas: T.Backup.importBackupFile
        case .otpAuthFile, .clipboard: T.Backup.import
        }
    }
    
    var subtitle: String {
        switch externalImportService {
        case .aegis: T.Externalimport.aegisSuccessMsg
        case .raivo: T.Externalimport.raivoSuccessMsg
        case .lastPass: T.Externalimport.lastpassSuccessMsg
        case .andOTP: T.Externalimport.andotpSuccessMsg
        case .authenticatorPro: T.Externalimport.authenticatorproSuccessMsg
        case .googleAuth, .twofas: T.Backup.importOtherDevices
        case .otpAuthFile: "Contents of this file will be imported."
        case .clipboard: "Contents of clipboard will be imported."
        }
    }
    
    init(
        flowController: ImporterPreimportSummaryFlowControlling,
        interactor: ImporterPreimportSummaryModuleInteracting,
        externalImportService: ExternalImportService
    ) {
        self.flowController = flowController
        self.interactor = interactor
        self.externalImportService = externalImportService
    }
}

extension ImporterPreimportSummaryPresenter {
    func handleImport() {
        view?.showImporting()
        let resultCount = interactor.importFromFile()
        flowController.toImportSummary(count: resultCount)
    }
    
    func handleCancel() {
        flowController.toClose()
    }
}
