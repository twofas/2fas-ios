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

protocol IconSelectorFlowControllerParent: AnyObject {
    func iconSelectorDidSelect(iconTypeID: IconTypeID)
}

protocol IconSelectorFlowControlling: AnyObject {
    func toSelection(iconTypeID: IconTypeID)
    func toOrderIcon(sourceView: UIView)
    func toUserIconInfo()
}

final class IconSelectorFlowController: FlowController {
    private weak var parent: IconSelectorFlowControllerParent?
    private weak var navigationController: UINavigationController?

    static func present(
        defaultIcon: IconTypeID?,
        selectedIcon: IconTypeID?,
        on navigationController: UINavigationController,
        parent: IconSelectorFlowControllerParent,
        animated: Bool
    ) {
        let view = IconSelectorViewController()
        let flowController = IconSelectorFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = InteractorFactory.shared.iconSelectorModuleInteractor(
            defaultIcon: defaultIcon,
            selectedIcon: selectedIcon
        )
        let presenter = IconSelectorPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.view = view
        
        flowController.navigationController = navigationController
        
        navigationController.pushViewController(view, animated: animated)
    }
}

extension IconSelectorFlowController: IconSelectorFlowControlling {
    func toSelection(iconTypeID: IconTypeID) {
        parent?.iconSelectorDidSelect(iconTypeID: iconTypeID)
    }
    
    func toOrderIcon(sourceView: UIView) {
        AnalyticsLog(.orderIconClick)
        
        let actionSheet = UIAlertController(title: T.Tokens.orderMenuTitle, message: nil, preferredStyle: .actionSheet)
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = sourceView
        }
        let cancelActionButton = UIAlertAction(title: T.Commons.cancel, style: .cancel, handler: nil)
        actionSheet.addAction(cancelActionButton)

        let user = UIAlertAction(title: T.Tokens.orderMenuOptionUser, style: .default) { [weak self] _ in
            AnalyticsLog(.orderIconAsUser)
            self?.toUserIconInfo()
        }
        user.setValue(Asset.iconRequestUser.image, forKey: "image")
        user.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        actionSheet.addAction(user)
        
        let company = UIAlertAction(title: T.Tokens.orderMenuOptionCompany, style: .default) { _ in
 			AnalyticsLog(.orderIconAsCompany)
            UIApplication.shared.open(
                URL(string: "https://2fas.com/your-branding/")!,
                options: [:],
                completionHandler: nil
            )
        }
        company.setValue(Asset.iconRequestCompany.image, forKey: "image")
        company.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        actionSheet.addAction(company)

        actionSheet.view.tintColor = Theme.Colors.Icon.theme
        _viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    func toUserIconInfo() {
        guard let navigationController else { return }
        UserIconInfoFlowController.push(on: navigationController, parent: self)
    }
}

extension IconSelectorFlowController: UserIconInfoFlowControllerParent {}
