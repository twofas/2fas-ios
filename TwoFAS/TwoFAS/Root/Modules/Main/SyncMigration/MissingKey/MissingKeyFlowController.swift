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

import UIKit
import SwiftUI
import Common
import Data

protocol MissingKeyFlowControllerParent: AnyObject {
    func missingKeyClose()
    func missingKeyResolved()
}

protocol MissingKeyFlowControlling: AnyObject {
    func toImportKeys()
    func toClearBackupConfirmation(confirm: @escaping () -> Void)
    func resolve()
    func close()
}

final class MissingKeyFlowController: FlowController {
    private weak var parent: MissingKeyFlowControllerParent?
    private var importKeysFlow: ImportKeysFlowController?

    static func present(
        on viewController: UIViewController,
        parent: MissingKeyFlowControllerParent,
        encryptionError: CloudState.NotAvailableReason.EncryptionError
    ) {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        hosting.view.backgroundColor = AppColor.backgroundsPrimary.uiColor
        let flowController = MissingKeyFlowController(viewController: hosting)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.missingKeyModuleInteractor()
        let presenter = MissingKeyPresenter(
            flowController: flowController,
            interactor: interactor,
            encryptionError: encryptionError
        )
        hosting.rootView = AnyView(MissingKeyView(presenter: presenter))

        hosting.configureAsModal()
        viewController.present(hosting, animated: true)
    }
}

extension MissingKeyFlowController: MissingKeyFlowControlling {
    func toImportKeys() {
        guard let vc = _viewController else { return }
        let flow = ImportKeysFlowController.make(presentingOn: vc, parent: self, showWarning: false)
        importKeysFlow = flow
        flow.start()
    }

    func toClearBackupConfirmation(confirm: @escaping () -> Void) {
        guard let vc = _viewController else { return }
        let alert = UIAlertController(
            title: "Are you sure?",
            message: "This will delete the iCloud backup.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear backup", style: .destructive) { _ in confirm() })
        vc.present(alert, animated: true)
    }

    func resolve() {
        parent?.missingKeyResolved()
    }

    func close() {
        parent?.missingKeyClose()
    }
}

extension MissingKeyFlowController: ImportKeysFlowControllerParent {
    func importKeysDidFinish(success: Bool) {
        importKeysFlow = nil
        if success {
            parent?.missingKeyResolved()
        }
    }

    func importKeysDidCancel() {
        importKeysFlow = nil
    }
}
