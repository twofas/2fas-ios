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

import SwiftUI
import Common

protocol ExternalImportInstructionsFlowControllerParent: AnyObject {
    func instructionsClose()
    func instructionsOpenFile(service: ExternalImportService)
    func instructionsCamera()
    func instructionsGallery()
    func instructionsFromClipboard()
}

protocol ExternalImportInstructionsFlowControlling: AnyObject {
    func close()
    func toOpenFile(service: ExternalImportService)
    func toCamera()
    func toGallery()
    func toFromClipboard()
}

final class ExternalImportInstructionsFlowController: FlowController {
    private weak var parent: ExternalImportInstructionsFlowControllerParent?

    static func push(
        in navigationController: UINavigationController,
        parent: ExternalImportInstructionsFlowControllerParent,
        service: ExternalImportService
    ) {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        let flowController = ExternalImportInstructionsFlowController(viewController: hosting)
        flowController.parent = parent
        let presenter = ExternalImportInstructionsPresenter(
            flowController: flowController,
            service: service
        )
        let secondaryAction: Callback? = presenter.hasSecondaryAction ? presenter.handleSecondaryAction : nil
        hosting.rootView = AnyView(
            ExternalImportInstructionsView(
                sourceLogo: AnyView(presenter.sourceLogo),
                sourceName: presenter.sourceName,
                info: presenter.info,
                action: presenter.handleAction,
                actionName: presenter.actionName,
                secondaryActionName: presenter.secondaryActionName,
                secondaryAction: secondaryAction,
                close: presenter.handleCancel
            )
        )
        hosting.view.backgroundColor = AppColor.backgroundsPrimary.uiColor

        navigationController.pushViewController(hosting, animated: true)
    }
}

extension ExternalImportInstructionsFlowController: ExternalImportInstructionsFlowControlling {
    func close() {
        parent?.instructionsClose()
    }
    
    func toOpenFile(service: ExternalImportService) {
        parent?.instructionsOpenFile(service: service)
    }
    
    func toCamera() {
        parent?.instructionsCamera()
    }
    
    func toGallery() {
        parent?.instructionsGallery()
    }
    
    func toFromClipboard() {
        parent?.instructionsFromClipboard()
    }
}
