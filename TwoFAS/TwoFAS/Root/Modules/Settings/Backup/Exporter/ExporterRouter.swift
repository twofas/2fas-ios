//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

import SwiftUI
import Common

/// Drives the whole Exporter flow through a single SwiftUI `NavigationStack`.
/// Builds the pushed screens and plays the role of the modules' flow controllers,
/// translating their callbacks into stack pushes and into the terminal actions
/// handled by `ExporterMainScreenFlowController` (share sheet, error alert, close).
final class ExporterRouter: ObservableObject {
    @Published var path: [ExporterRoute] = []

    weak var flowController: ExporterMainScreenFlowController?

    private var passwordProtectionPresenter: ExporterPasswordProtectionPresenter?
    private var pinPresenter: ExporterPINPresenter?

    // MARK: - Destinations

    @ViewBuilder
    func destination(for route: ExporterRoute) -> some View {
        switch route {
        case .passwordProtection:
            if let passwordProtectionPresenter {
                ExporterPasswordProtectionView(presenter: passwordProtectionPresenter)
            }
        case .pin:
            if let pinPresenter {
                ExporterPINView(presenter: pinPresenter)
            }
        }
    }

    // MARK: - Stack helpers

    private func pushPasswordProtection() {
        let interactor = ModuleInteractorFactory.shared.exporterPasswordProtectionModuleInteractor()
        passwordProtectionPresenter = ExporterPasswordProtectionPresenter(
            flowController: self,
            interactor: interactor
        )
        path.append(.passwordProtection)
    }

    private func pushPIN(password: String?) {
        let interactor = ModuleInteractorFactory.shared.exporterPINModuleInteractor()
        pinPresenter = ExporterPINPresenter(
            flowController: self,
            interactor: interactor,
            password: password
        )
        path.append(.pin)
    }
}

// MARK: - ExporterMainScreenFlowControlling

extension ExporterRouter: ExporterMainScreenFlowControlling {
    func toClose() {
        flowController?.finishExporter()
    }

    func toPasswordProtection() {
        pushPasswordProtection()
    }

    func toPINKeyboard() {
        pushPIN(password: nil)
    }

    func toExport(with url: URL) {
        flowController?.shareExport(url: url)
    }

    func toExportError() {
        flowController?.showExportError()
    }
}

// MARK: - ExporterPasswordProtectionFlowControlling

extension ExporterRouter: ExporterPasswordProtectionFlowControlling {
    func toPINKeyboard(with password: String) {
        pushPIN(password: password)
    }

    func back() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}

// MARK: - ExporterPINFlowControlling

extension ExporterRouter: ExporterPINFlowControlling {}
