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
final class TransferPresenter {
    var sections: [TransferSection] = []
    var isExporting: Bool = false
    var isLocked: Bool = false

    private let flowController: TransferFlowControlling
    let interactor: TransferModuleInteracting

    init(flowController: TransferFlowControlling, interactor: TransferModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBecomeActive),
            name: .refreshTabContent,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func viewWillAppear() {
        reload()
    }

    func handleSelection(_ action: TransferCell.TransferAction) {
        switch action {
        case .aegis:
            flowController.toAegis()
        case .raivo:
            flowController.toRaivo()
        case .lastPass:
            flowController.toLastPass()
        case .googleAuth:
            flowController.toGoogleAuth()
        case .andOTP:
            flowController.toAndOTP()
        case .authenticatorPro:
            flowController.toAuthenticatorPro()
        case .otpAuthFileImport:
            flowController.toOpenTXTFile()
        case .otpAuthFileExport:
            guard interactor.hasPIN else {
                flowController.toSetupPIN()
                return
            }
            flowController.toSaveOTPAuthFile()
        case .exportQRCodes:
            guard interactor.hasPIN else {
                flowController.toSetupPIN()
                return
            }
            flowController.toExportQRCodes()
        }
    }

    func handleBack() {
        flowController.close()
    }

    func handleSaveOTPAuthFile() {
        isExporting = true
        Task {
            guard let url = await interactor.createOTPAuthCodesFile() else {
                await MainActor.run {
                    self.flowController.toError(T.Commons.fileCreationError)
                    self.isExporting = false
                }
                return
            }
            await MainActor.run {
                self.flowController.toShareOTPAuthFileContents(url) { [weak self] in
                    self?.interactor.cleanupTemporaryFiles(urls: [url])
                }
                self.isExporting = false
            }
        }
    }

    func handleExportQRCodes() {
        isExporting = true
        Task {
            guard let url = await interactor.createQRCodeFiles() else {
                await MainActor.run {
                    self.flowController.toError(T.Commons.fileCreationError)
                    self.isExporting = false
                }
                return
            }
            await MainActor.run {
                self.flowController.toShareQRCodes(url) { [weak self] in
                    self?.interactor.cleanupTemporaryFiles(urls: [url])
                }
                self.isExporting = false
            }
        }
    }
}

private extension TransferPresenter {
    func reload() {
        sections = buildMenu()
    }

    @objc func handleAppBecomeActive() {
        reload()
    }
}
