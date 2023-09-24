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
import CodeSupport

protocol AddingServiceFlowControllerParent: AnyObject {
    func addingServiceDismiss()
    func addingServiceToGallery()
    func addingServiceToGoogleAuthSummary(importable: Int, total: Int, codes: [Code])
    func addingServiceToLastPassSummary(importable: Int, total: Int, codes: [Code])
    func addingServiceToSendLogs(auditID: UUID)
    func addingServiceToPushPermissions(for extensionID: Common.ExtensionID)
    func addingServiceToTwoFASWebExtensionPairing(for extensionID: Common.ExtensionID)
    func addingServiceClose(_ serviceData: ServiceData)
    func addingServiceToGuides()
}

protocol AddingServiceFlowControlling: AnyObject {
    func toMain()
}

final class AddingServiceFlowController: FlowController {
    private weak var parent: AddingServiceFlowControllerParent?
    
    static func present(
        on viewController: UIViewController,
        parent: AddingServiceFlowControllerParent
    ) {
        let view = AddingServiceViewController()
        let flowController = AddingServiceFlowController(viewController: view)
        flowController.parent = parent
        
        let presenter = AddingServicePresenter(flowController: flowController)
        view.presenter = presenter
        presenter.view = view
        
        viewController.present(view, animated: true)
    }
}

extension AddingServiceFlowController: AddingServiceManuallyFlowControllerParent {
    func addingServiceManuallyToClose(_ serviceData: ServiceData) {
        parent?.addingServiceClose(serviceData)
    }
}

extension AddingServiceFlowController {
    var viewController: AddingServiceViewController { _viewController as! AddingServiceViewController }
}

extension AddingServiceFlowController: AddingServiceFlowControlling {
    func toMain() {
        AddingServiceMainFlowController.embed(in: viewController, parent: self)
    }
}

extension AddingServiceFlowController: AddingServiceMainFlowControllerParent {
    func mainDismiss() {
        parent?.addingServiceDismiss()
    }
    
    func mainToGallery() {
        parent?.addingServiceToGallery()
    }
    
    func mainToGoogleAuthSummary(importable: Int, total: Int, codes: [Code]) {
        parent?.addingServiceToGoogleAuthSummary(importable: importable, total: total, codes: codes)
    }
    
    func mainToLastPassSummary(importable: Int, total: Int, codes: [Code]) {
        parent?.addingServiceToLastPassSummary(importable: importable, total: total, codes: codes)
    }
    
    func mainToSendLogs(auditID: UUID) {
        parent?.addingServiceToSendLogs(auditID: auditID)
    }
    
    func mainToPushPermissions(for extensionID: ExtensionID) {
        parent?.addingServiceToPushPermissions(for: extensionID)
    }
    
    func mainToTwoFASWebExtensionPairing(for extensionID: ExtensionID) {
        parent?.addingServiceToTwoFASWebExtensionPairing(for: extensionID)
    }
    
    func mainToToken(serviceData: ServiceData) {
        parent?.addingServiceClose(serviceData)
    }
        
    func mainToAddManually() {
        AddingServiceManuallyFlowController.embed(in: viewController, parent: self)
    }
    
    func mainToGuides() {
        parent?.addingServiceToGuides()
    }
}
