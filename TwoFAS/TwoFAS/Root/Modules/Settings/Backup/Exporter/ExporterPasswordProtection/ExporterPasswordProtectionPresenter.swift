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
final class ExporterPasswordProtectionPresenter {
    var password1: String = ""
    var password2: String = ""
    var password1Error: String?
    var password2Error: String?
    var showsBackButton: Bool = true

    var isExportEnabled: Bool {
        password1.count >= ExportFileRules.minLength &&
            password2.count >= ExportFileRules.minLength &&
            password1 == password2 &&
            password1Error == nil &&
            password2Error == nil
    }

    private let flowController: ExporterPasswordProtectionFlowControlling
    private let interactor: ExporterPasswordProtectionModuleInteracting

    init(
        flowController: ExporterPasswordProtectionFlowControlling,
        interactor: ExporterPasswordProtectionModuleInteracting
    ) {
        self.flowController = flowController
        self.interactor = interactor
    }

    func handleExport() {
        guard isExportEnabled else { return }
        let password = password1
        if interactor.isPINSet {
            flowController.toPINKeyboard(with: password)
        } else {
            interactor.export(with: password) { [weak self] url in
                if let url {
                    self?.flowController.toExport(with: url)
                } else {
                    self?.flowController.toExportError()
                }
            }
        }
    }

    func handleCancel() {
        flowController.toClose()
    }

    func handleFirstChanged(_ newValue: String) {
        if newValue.isEmpty {
            password1Error = nil
            return
        }
        if newValue.count < ExportFileRules.minLength {
            password1Error = T.Backup.toShortError
        } else {
            password1Error = nil
        }
        // Re-check second matches
        checkMatch()
    }

    func handleSecondChanged(_ newValue: String) {
        if newValue.isEmpty {
            password2Error = nil
            return
        }
        if newValue.count < ExportFileRules.minLength {
            password2Error = T.Backup.toShortError
        } else {
            password2Error = nil
        }
        checkMatch()
    }
}

private extension ExporterPasswordProtectionPresenter {
    func checkMatch() {
        guard !password1.isEmpty && !password2.isEmpty else { return }
        guard password1.count >= ExportFileRules.minLength,
              password2.count >= ExportFileRules.minLength else { return }
        if password1 != password2 {
            password2Error = T.Backup.passwordsDontMatch
        } else if password2Error == T.Backup.passwordsDontMatch {
            password2Error = nil
        }
    }
}
