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

final class ImporterOpenFilePresenter {
    private let flowController: ImporterOpenFileHeadlessFlowControlling
    private let interactor: ImporterOpenFileModuleInteracting
    
    private var didHandleURL = false
    
    init(flowController: ImporterOpenFileHeadlessFlowControlling, interactor: ImporterOpenFileModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension ImporterOpenFilePresenter {
    func handleFileOpen(_ url: URL) {
        interactor.openFile(url) { [weak self] result in
            switch result {
            case .success(let data): self?.parseData(data)
            case .failure(let error):
                switch error {
                case .cantReadFile(let reason):
                    self?.flowController.toFileError(error: .cantReadFile(reason: reason))
                }
            }
        }
    }
    
    func start() {
        guard !didHandleURL else { return }
        didHandleURL = true
        if let url = interactor.url {
            handleFileOpen(url)
        } else {
            flowController.toOpenFile()
        }
    }
}

private extension ImporterOpenFilePresenter {
    func parseData(_ data: Data) {
        guard let result = interactor.parseContent(data) else {
            flowController.toFileError(error: .cantReadFile(reason: nil))
            return
        }
        switch result {
        case .twoFAS(let data): checkTwoFAS(data)
        case .lastPass(let result):
            switch result {
            case .success(let lastPassData):
                let parseResult = interactor.parseLastPass(lastPassData)
                if parseResult.isEmpty {
                    flowController.toFileIsEmpty()
                } else {
                    flowController.toPreimportSummary(
                        countNew: interactor.countNewServices(parseResult),
                        countTotal: lastPassData.accounts.count,
                        sections: [],
                        services: parseResult,
                        externalImportService: .lastPass
                    )
                }
            }
        case .raivo(let raivoData):
            let parseResult = interactor.parseRaivo(raivoData)
            if parseResult.isEmpty {
                flowController.toFileIsEmpty()
            } else {
                flowController.toPreimportSummary(
                    countNew: interactor.countNewServices(parseResult),
                    countTotal: raivoData.count,
                    sections: [],
                    services: parseResult,
                    externalImportService: .raivo
                )
            }
        case .andOTP(let andOTPData):
            let parseResult = interactor.parseAndOTP(andOTPData)
            if parseResult.isEmpty {
                flowController.toFileIsEmpty()
            } else {
                flowController.toPreimportSummary(
                    countNew: interactor.countNewServices(parseResult),
                    countTotal: andOTPData.count,
                    sections: [],
                    services: parseResult,
                    externalImportService: .andOTP
                )
            }
        case .authenticatorPro(let data):
            let parseResult = interactor.parseAuthenticatorPro(data)
            if parseResult.isEmpty {
                flowController.toFileIsEmpty()
            } else {
                flowController.toPreimportSummary(
                    countNew: interactor.countNewServices(parseResult),
                    countTotal: data.count,
                    sections: [],
                    services: parseResult,
                    externalImportService: .authenticatorPro
                )
            }
        case .aegis(let result):
            switch result {
            case .error, .encrypted:
                flowController.toFileError(error: .cantReadFile(reason: result.localizedDescription))
            case .success(let AEGISData):
                let parseResult = interactor.parseAEGIS(AEGISData)
                if parseResult.isEmpty {
                    flowController.toFileIsEmpty()
                } else {
                    flowController.toPreimportSummary(
                        countNew: interactor.countNewServices(parseResult),
                        countTotal: AEGISData.db.entries.count,
                        sections: [],
                        services: parseResult,
                        externalImportService: .aegis
                    )
                }
            }
        }
    }
    
    // MARK: -
    
    func checkTwoFAS(_ data: ExchangeDataFormat) {
        switch interactor.checkTwoFAS(data) {
        case .unencrypted: twoFASSummary(for: data)
        case .encrypted: flowController.toEnterPassword(for: data, externalImportService: .twofas)
        case .newerSchema: flowController.toFileError(error: .newerSchema)
        }
    }
    
    func twoFASSummary(for data: ExchangeDataFormat) {
        let sections = interactor.parseSectionsTwoFAS(data)
        let services = interactor.parseTwoFASServices(with: data.services, sections: sections)
        let countNew = interactor.countNewServices(services)
        if countNew > 0 {
            flowController.toPreimportSummary(
                countNew: countNew,
                countTotal: services.count,
                sections: sections,
                services: services,
                externalImportService: .twofas
            )
        } else {
            flowController.toFileIsEmpty()
        }
    }
}
