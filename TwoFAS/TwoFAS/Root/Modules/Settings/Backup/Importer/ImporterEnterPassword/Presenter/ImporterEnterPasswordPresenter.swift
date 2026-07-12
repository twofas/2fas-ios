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

@Observable
final class ImporterEnterPasswordPresenter {
    var password: String = ""
    var errorMessage: String?

    var isDecryptEnabled: Bool {
        password.count >= ExportFileRules.minLength && errorMessage == nil
    }

    private let flowController: ImporterEnterPasswordFlowControlling
    private let interactor: ImporterEnterPasswordModuleInteracting
    private let externalImportService: ExternalImportService

    init(
        flowController: ImporterEnterPasswordFlowControlling,
        interactor: ImporterEnterPasswordModuleInteracting,
        externalImportService: ExternalImportService
    ) {
        self.flowController = flowController
        self.interactor = interactor
        self.externalImportService = externalImportService
    }

    func handlePreimport() {
        guard isDecryptEnabled else {
            flowController.toFileError(error: .cantReadFile(reason: nil))
            return
        }
        switch interactor.openFile(with: password) {
        case .success(let data): parseData(data, externalImportService: externalImportService)
        case .cantReadFile: flowController.toFileError(error: .cantReadFile(reason: nil))
        case .wrongPassword: flowController.toWrongPassword()
        }
    }

    func handleCancel() {
        flowController.toClose()
    }

    func handleChange(_ newValue: String) {
        if newValue.isEmpty {
            errorMessage = nil
            return
        }
        if newValue.count < ExportFileRules.minLength {
            errorMessage = T.Backup.toShortError
        } else {
            errorMessage = nil
        }
    }
}

private extension ImporterEnterPasswordPresenter {
    func parseData(_ data: ExchangeDataServices, externalImportService: ExternalImportService) {
        let result = interactor.parseFile(with: data)

        if result.countNew > 0 {
            flowController.toPreimportSummary(
                countNew: result.countNew,
                countTotal: result.countTotal,
                sections: result.sections,
                services: result.services,
                externalImportService: externalImportService
            )
        } else {
            flowController.toFileIsEmpty()
        }
    }
}
