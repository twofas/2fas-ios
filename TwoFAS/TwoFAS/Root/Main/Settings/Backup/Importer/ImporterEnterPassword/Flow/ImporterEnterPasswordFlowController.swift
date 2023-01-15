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

protocol ImporterEnterPasswordFlowControllerParent: AnyObject {
    func hidePasswordImport()
    func showPreimportSummary(count: Int, sections: [CommonSectionData], services: [ServiceData])
    func showFileError(error: ImporterOpenFileError)
    func showFileIsEmpty()
    func showWrongPassword()
}

protocol ImporterEnterPasswordFlowControlling: AnyObject {
    func toClose()
    func toPreimportSummary(count: Int, sections: [CommonSectionData], services: [ServiceData])
    func toFileError(error: ImporterOpenFileError)
    func toFileIsEmpty()
    func toWrongPassword()
}

final class ImporterEnterPasswordFlowController: FlowController {
    private weak var parent: ImporterEnterPasswordFlowControllerParent?
    
    static func push(
        in navigationController: UINavigationController,
        parent: ImporterEnterPasswordFlowControllerParent,
        data: ExchangeDataFormat
    ) {
        let view = ImporterEnterPasswordViewController()
        let flowController = ImporterEnterPasswordFlowController(viewController: view)
        flowController.parent = parent
        let interactor = InteractorFactory.shared.importerEnterPasswordModuleInteractor(
            data: data
        )
        let presenter = ImporterEnterPasswordPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: true)
    }
}

extension ImporterEnterPasswordFlowController: ImporterEnterPasswordFlowControlling {
    func toClose() {
        parent?.hidePasswordImport()
    }
    
    func toPreimportSummary(count: Int, sections: [CommonSectionData], services: [ServiceData]) {
        parent?.showPreimportSummary(count: count, sections: sections, services: services)
    }
    
    func toFileError(error: ImporterOpenFileError) {
        parent?.showFileError(error: error)
    }
    
    func toFileIsEmpty() {
        parent?.showFileIsEmpty()
    }
    
    func toWrongPassword() {
        parent?.showWrongPassword()
    }
}
