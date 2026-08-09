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
import Common

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
    
    static func push(
        in navigationController: UINavigationController,
        parent: ExportQuestionFlowControllerParent,
        exportType: ExportQuestionType
    ) {
        let flowController = ExportQuestionFlowController()
        let presenter = ExportQuestionPresenter(
            flowController: flowController
        )
        let hosting = UIHostingController(
            rootView: AnyView(ExportQuestionView(presenter: presenter, exportType: exportType))
        )
        hosting.title = T.Settings.exportTitleTokens
        hosting.view.backgroundColor = AppColor.backgroundsPrimary.uiColor

        flowController.parent = parent
        flowController.navigationController = navigationController
        flowController.exportType = exportType

        navigationController.pushViewController(hosting, animated: true)
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
