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

protocol ColorPickerFlowControllerParent: AnyObject {
    func colorPickerDidSelectColor(_ tintColor: TintColor)
    func colorPickerDidClose()
}

protocol ColorPickerFlowControlling: AnyObject {
    func toSelectColor(_ tintColor: TintColor)
    func toClose()
}

final class ColorPickerFlowController: FlowController {
    private weak var parent: ColorPickerFlowControllerParent?
    private weak var parentViewController: UIViewController?
    
    static func present(
        currentColor: TintColor,
        on viewController: UIViewController,
        parent: ColorPickerFlowControllerParent
    ) {
        let view = ColorPickerViewController()
        let flowController = ColorPickerFlowController(viewController: view)
        flowController.parent = parent
        flowController.parentViewController = viewController
        
        let interactor = InteractorFactory.shared.colorPickerModuleInteractor()
        let presenter = ColorPickerPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.currentColor = currentColor
        
        flowController.presentInModal(on: viewController)
    }
}

extension ColorPickerFlowController: ColorPickerFlowControlling {
    func toSelectColor(_ tintColor: TintColor) {
        parent?.colorPickerDidSelectColor(tintColor)
    }
    
    @objc
    func toClose() {
        parent?.colorPickerDidClose()
    }
}

private extension ColorPickerFlowController {
    func presentInModal(on parentViewController: UIViewController) {
        guard let view = _viewController else { return }
        let navi = CommonNavigationController(rootViewController: view)
        navi.modalPresentationStyle = .pageSheet
        if let sheet = navi.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.preferredCornerRadius = 2 * Theme.Metrics.cornerRadius
        }
        view.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: T.Commons.cancel,
            style: .done,
            target: self,
            action: #selector(toClose)
        )
        view.title = T.Tokens.badgeColor
        parentViewController.present(navi, animated: true, completion: nil)
    }
}
