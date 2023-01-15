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

protocol AdvancedAlertFlowControllerParent: AnyObject {
    func advancedAlertContinue()
    func advancedAlertCancel()
}

final class AdvancedAlertFlowController {
    private weak var parent: AdvancedAlertFlowControllerParent?
    private weak var parentViewController: UIViewController?
    
    static func present(
        on viewController: UIViewController,
        parent: AdvancedAlertFlowControllerParent
    ) {
        let flowController = AdvancedAlertFlowController()
        flowController.parent = parent
        flowController.parentViewController = viewController
        
        let view = AdvancedAlert { [weak parent] in
            parent?.advancedAlertContinue()
        } cancel: { [weak parent] in
            parent?.advancedAlertCancel()
        }
        
        let vc = AdvancedAlertViewController(rootView: view)
        vc.flowController = flowController
        vc.view.backgroundColor = Theme.Colors.decoratedContainer
        
        if UIDevice.isSmallScreen {
            flowController.presentInModal(on: viewController, view: vc)
        } else {
            flowController.presentInPartModal(on: viewController, view: vc)
        }
    }
}

private extension AdvancedAlertFlowController {
    func presentInPartModal(on parentViewController: UIViewController, view: UIViewController) {
        view.modalPresentationStyle = .pageSheet
        if let sheet = view.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = false
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.preferredCornerRadius = 2 * Theme.Metrics.cornerRadius
        }
        parentViewController.present(view, animated: true, completion: nil)
    }
    
    func presentInModal(on parentViewController: UIViewController, view: UIViewController) {
        view.configureAsModal()
        parentViewController.present(view, animated: true, completion: nil)
    }
}
