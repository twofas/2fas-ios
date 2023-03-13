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
import Dynamic
import Common

protocol ServiceAddedFlowControllerParent: AnyObject {
    func serviceAddedEditService(_ serviceData: ServiceData)
    func serviceAddedEditIcon(_ serviceData: ServiceData)
    func serviceAddedClose()
}

protocol ServiceAddedFlowControlling: AnyObject {
    func toEditService(_ serviceData: ServiceData)
    func toEditIcon(_ serviceData: ServiceData)
    func toClose()
}

final class ServiceAddedFlowController: FlowController {
    private weak var parent: ServiceAddedFlowControllerParent?
    
    static func present(
        serviceData: ServiceData,
        on viewController: UIViewController,
        parent: ServiceAddedFlowControllerParent
    ) {
        let view = ServiceAddedViewController()
        let flowController = ServiceAddedFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = InteractorFactory.shared.serviceAddedModuleInteractor(serviceData: serviceData)
        let presenter = ServiceAddedPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.view = view
        
        switch serviceData.tokenType {
        case .totp:
            let subview = ServiceAddedServiceContainerViewTOTP()
            view.serviceContainer = subview
            interactor.tokenConsumer = subview
        case .hotp:
            let subview = ServiceAddedServiceContainerViewHOTP()
            view.serviceContainer = subview
            interactor.counterConsumer = subview
        }
        
        flowController.presentInModal(on: viewController)
    }
}

extension ServiceAddedFlowController: ServiceAddedFlowControlling {
    func toEditService(_ serviceData: ServiceData) {
        parent?.serviceAddedEditService(serviceData)
    }
    
    func toEditIcon(_ serviceData: ServiceData) {
        parent?.serviceAddedEditIcon(serviceData)
    }
    
    func toClose() {
        parent?.serviceAddedClose()
    }
}

private extension ServiceAddedFlowController {
    func presentInModal(on parentViewController: UIViewController) {
        guard let view = _viewController else { return }
        view.modalPresentationStyle = .pageSheet
        if let sheet = view.sheetPresentationController {
            view.view.layoutIfNeeded()
            let height: CGFloat = view.view
                .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                .height
            let smallText = "small"
            let smallID = UISheetPresentationController.Detent.Identifier(smallText)
            let smallDetent: UISheetPresentationController.Detent
            if #available(iOS 16.0, *) {
                smallDetent = .custom(identifier: smallID) { _ in
                    height
                }
                sheet.detents = [smallDetent, .medium()]
            } else {
                if let detent = Dynamic.UISheetPresentationControllerDetent
                    ._detent(withIdentifier: smallText, constant: height)
                    .asAnyObject as? UISheetPresentationController.Detent {
                    smallDetent = detent
                    sheet.detents = [smallDetent, .medium()]
                }
            }
            sheet.selectedDetentIdentifier = smallID
            sheet.prefersGrabberVisible = !UIDevice.isiPad
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.preferredCornerRadius = 2 * Theme.Metrics.cornerRadius
        }
        parentViewController.present(view, animated: true, completion: nil)
    }
}
