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
import Data

/// Drives the whole Importer flow through a single SwiftUI `NavigationStack`.
/// The first determined screen becomes the stack root, every following one is pushed.
/// Plays the role of the modules' flow controllers, delegating terminal/UIKit actions
/// (document picker, alerts, close) to `ImporterOpenFileHeadlessFlowController`.
final class ImporterRouter: ObservableObject {
    @Published var root: ImporterRoute?
    @Published var path: [ImporterRoute] = []

    weak var flowController: ImporterOpenFileHeadlessFlowController?

    private var enterPasswordPresenter: ImporterEnterPasswordPresenter?
    private var preimportSummaryPresenter: ImporterPreimportSummaryPresenter?
    private var fileError: ImporterOpenFileError?

    // MARK: - Destinations

    @ViewBuilder
    func destination(for route: ImporterRoute) -> some View {
        Group {
            switch route {
            case .enterPassword:
                if let enterPasswordPresenter {
                    ImporterEnterPasswordView(presenter: enterPasswordPresenter)
                }
            case .preimportSummary:
                if let preimportSummaryPresenter {
                    ImporterPreimportSummaryView(presenter: preimportSummaryPresenter)
                }
            case .fileError:
                if let fileError {
                    ImporterFileErrorView(fileError: fileError, action: { [weak self] in
                        self?.toClose()
                    })
                }
            }
        }
        .chevronOnlyBackButton()
    }

    // MARK: - Navigation helper

    private func go(to route: ImporterRoute) {
        if root == nil {
            root = route
            flowController?.presentModalIfNeeded()
        } else {
            path.append(route)
        }
    }
}

// MARK: - ImporterOpenFileHeadlessFlowControlling + child flow controllers

extension ImporterRouter: ImporterOpenFileHeadlessFlowControlling {
    func toClose() {
        flowController?.close()
    }

    func toOpenFile() {
        flowController?.presentDocumentPicker()
    }

    func toEnterPassword(for data: ExchangeDataFormat, externalImportService: ExternalImportService) {
        let interactor = ModuleInteractorFactory.shared.importerEnterPasswordModuleInteractor(data: data)
        enterPasswordPresenter = ImporterEnterPasswordPresenter(
            flowController: self,
            interactor: interactor,
            externalImportService: externalImportService
        )
        go(to: .enterPassword)
    }

    func toPreimportSummary(
        countNew: Int,
        countTotal: Int,
        sections: [CommonSectionData],
        services: [ServiceData],
        externalImportService: ExternalImportService
    ) {
        let interactor = ModuleInteractorFactory.shared.importerPreimportSummaryModuleInteractor(
            countNew: countNew,
            countTotal: countTotal,
            sections: sections,
            services: services
        )
        preimportSummaryPresenter = ImporterPreimportSummaryPresenter(
            flowController: self,
            interactor: interactor,
            externalImportService: externalImportService
        )
        go(to: .preimportSummary)
    }

    func toFileError(error: ImporterOpenFileError) {
        fileError = error
        go(to: .fileError)
    }

    func toFileIsEmpty() {
        toFileError(error: .noNewServices)
    }

    func toWrongPassword() {
        flowController?.showWrongPassword()
    }

    func toImportSummary(count: Int) {
        flowController?.showImportSummary(count: count)
    }
}

extension ImporterRouter: ImporterEnterPasswordFlowControlling {}

extension ImporterRouter: ImporterPreimportSummaryFlowControlling {}

extension ImporterRouter: ImporterFileErrorFlowControlling {}

// MARK: - Root view

struct ImporterRootView: View {
    @ObservedObject
    var router: ImporterRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                if let root = router.root {
                    router.destination(for: root)
                } else {
                    Color.clear
                }
            }
            .navigationDestination(for: ImporterRoute.self) { route in
                router.destination(for: route)
            }
        }
    }
}
