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
import Common

protocol ImporterPreimportSummaryFlowControllerParent: AnyObject {
    func hidePreimportSummary()
    func showImportSummary(count: Int)
    func showFileError(error: ImporterOpenFileError)
}

protocol ImporterPreimportSummaryFlowControlling: AnyObject {
    func toClose()
    func toImportSummary(count: Int)
    func toFileError(error: ImporterOpenFileError)
}

final class ImporterPreimportSummaryFlowController: FlowController {
    private weak var parent: ImporterPreimportSummaryFlowControllerParent?
    
    static func push(
        in navigationController: UINavigationController,
        parent: ImporterPreimportSummaryFlowControllerParent,
        count: Int,
        sections: [CommonSectionData],
        services: [ServiceData]
    ) {
        let view = ImporterPreimportSummaryViewController()
        let flowController = ImporterPreimportSummaryFlowController(viewController: view)
        flowController.parent = parent
        let interactor = InteractorFactory.shared.importerPreimportSummaryModuleInteractor(
            count: count,
            sections: sections,
            services: services
        )
        let presenter = ImporterPreimportSummaryPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: true)
    }
}

extension ImporterPreimportSummaryFlowController: ImporterPreimportSummaryFlowControlling {
    func toClose() {
        parent?.hidePreimportSummary()
    }
    
    func toImportSummary(count: Int) {
        parent?.showImportSummary(count: count)
    }
    
    func toFileError(error: ImporterOpenFileError) {
        parent?.showFileError(error: error)
    }
}
