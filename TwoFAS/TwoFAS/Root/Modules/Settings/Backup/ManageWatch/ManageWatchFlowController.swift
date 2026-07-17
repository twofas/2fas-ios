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
import SwiftUI
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
    private weak var presenter: ManageWatchPresenter?

    static func present(
        on viewController: UIViewController,
        parent: ManageWatchFlowControllerParent
    ) {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        let flowController = ManageWatchFlowController(viewController: hosting)
        let interactor = ModuleInteractorFactory.shared.manageWatchModuleInteractor()
        flowController.parent = parent
        let presenter = ManageWatchPresenter(
            flowController: flowController,
            interactor: interactor
        )
        flowController.presenter = presenter
        hosting.rootView = AnyView(ManageWatchView(presenter: presenter))
        hosting.view.backgroundColor = AppColor.backgroundsTertiary.uiColor

        hosting.configureAsModal()
        viewController.present(hosting, animated: true)
    }
}

extension ManageWatchFlowController: ManageWatchFlowControlling {
    func close() {
        parent?.closeManageFlow()
    }

    func toCamera() {
        guard let vc = _viewController else { return }
        CameraScannerFlowController.present(on: vc, parent: self)
    }

    func toRename(_ pairedWatch: PairedWatch) {
        let alert = AlertControllerPromptFactory.create(
            title: T.Backup.managePairedWatchesRenameTitle,
            message: T.Backup.managePairedWatchesRenameDescription,
            actionName: T.Backup.managePairedWatchesRenameAction,
            defaultText: pairedWatch.deviceName,
            inputConfiguration: .name,
            action: { [weak self] deviceName in
                self?.presenter?.handleRename(deviceName, pairedWatch)
            },
            cancel: {},
            verify: { deviceName in
                ServiceRules.isAppleWatchNameValid(deviceName: deviceName)
            }
        )

        _viewController?.present(alert, animated: true, completion: nil)
    }
}

extension ManageWatchFlowController: CameraScannerFlowControllerParent {
    func cameraScannerDidFinish() {
        presenter?.handleReloadList()
        _viewController?.dismiss(animated: true)
    }
    func cameraScannerDidImport(count: Int) {}
    func cameraScannerServiceWasCreated(serviceData: ServiceData) {}
}
