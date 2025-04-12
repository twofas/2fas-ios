//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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
import Data

protocol ManageWatchFlowControllerParent: AnyObject {
    func closeManageFlow()
}

protocol ManageWatchFlowControlling: AnyObject {
    func close()
    func toCamera()
    func toRename(_ pairedWatch: PairedWatch)
}

final class ManageWatchFlowController: FlowController {
    private weak var parent: ManageWatchFlowControllerParent?
    
    static func present(
        on viewController: UIViewController,
        parent: ManageWatchFlowControllerParent
    ) {
        let view = ManageWatchViewController()
        let flowController = ManageWatchFlowController(viewController: view)
        let interactor = ModuleInteractorFactory.shared.manageWatchModuleInteractor()
        flowController.parent = parent
        let presenter = ManageWatchPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        
        view.configureAsModal()
        viewController.present(view, animated: true)
    }
}

extension ManageWatchFlowController: ManageWatchFlowControlling {
    func close() {
        parent?.closeManageFlow()
    }
    
    func toCamera() {
        guard let viewController = _viewController as? ManageWatchViewController else { return }
        CameraScannerFlowController.present(on: viewController, parent: self)
    }
    
    func toRename(_ pairedWatch: PairedWatch) {
        let alert = AlertControllerPromptFactory.create(
            title: "Watch Renaaming",
            message: "Enter new device name",
            actionName: "Name your device",
            defaultText: "Apple Watch",
            inputConfiguration: .name,
            action: { [weak self] deviceName in
                self?.viewController.presenter.handleRename(deviceName, pairedWatch)
            },
            cancel: {},
            verify: { deviceName in
                ServiceRules.isAppleWatchNameValid(deviceName: deviceName)
            }
        )
        
        viewController.present(alert, animated: true, completion: nil)
    }
}

extension ManageWatchFlowController {
    var viewController: ManageWatchViewController { _viewController as! ManageWatchViewController }
}

extension ManageWatchFlowController: CameraScannerFlowControllerParent {
    func cameraScannerDidFinish() {
        viewController.presenter.handleReloadList()
        viewController.dismiss(animated: true)
    }
    func cameraScannerDidImport(count: Int) {}
    func cameraScannerServiceWasCreated(serviceData: ServiceData) {}
}
