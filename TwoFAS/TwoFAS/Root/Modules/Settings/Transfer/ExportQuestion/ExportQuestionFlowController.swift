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
//  but WITHOUT ANY WARRANTY; without even the the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>
//

import SwiftUI
import UIKit

protocol ExportQuestionFlowControllerParent: AnyObject {
    func closeExporter(export: Bool, exportType: ExportQuestionType)
}

protocol ExportQuestionFlowControlling: AnyObject {
    func toClose()
    func toPINKeyboard()
}

final class ExportQuestionFlowController: ObservableObject {
    private weak var parent: ExportQuestionFlowControllerParent?
    private weak var navigationController: UINavigationController?
    private var exportType: ExportQuestionType?
    
    static func present(
        on viewController: UIViewController,
        parent: ExportQuestionFlowControllerParent,
        exportType: ExportQuestionType
    ) {
        let flowController = ExportQuestionFlowController()
        let presenter = ExportQuestionPresenter(
            flowController: flowController
        )
        let hosting = NavigationBarHiddenHostingController(
            rootView: AnyView(ExportQuestionView(presenter: presenter, exportType: exportType))
        )
        hosting.title = T.Settings.exportTitleTokens

        let navController = CommonNavigationController(rootViewController: hosting)
        navController.isNavigationBarHidden = true

        flowController.parent = parent
        flowController.navigationController = navController
        flowController.exportType = exportType

        navController.configureAsPhoneFullscreenModal()

        viewController.present(navController, animated: true, completion: nil)
    }
}

extension ExportQuestionFlowController: ExportQuestionFlowControlling {
    func toClose() {
        guard let exportType else { return }
        parent?.closeExporter(export: false, exportType: exportType)
    }
    
    func toPINKeyboard() {
        guard let navigationController else { return }
        ExportQuestionPINVerificationFlowController.push(in: navigationController, parent: self)
    }
}

extension ExportQuestionFlowController: ExportQuestionPINVerificationFlowControllerParent {
    func closePIN() {
        guard let exportType else { return }
        parent?.closeExporter(export: false, exportType: exportType)
    }
    
    func PINSuccess() {
        guard let exportType else { return }
        parent?.closeExporter(export: true, exportType: exportType)
    }
}
