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

protocol BrowserExtensionServiceFlowControllerParent: AnyObject {
    func unpairService(with id: String)
}

protocol BrowserExtensionServiceFlowControlling: AnyObject {
    func toUnpairQuestion()
    func toUnpairingService(with id: String)
}

final class BrowserExtensionServiceFlowController: FlowController {
    private weak var parent: BrowserExtensionServiceFlowControllerParent?
    
    static func present(
        in navigationController: UINavigationController,
        parent: BrowserExtensionServiceFlowControllerParent,
        name: String,
        date: String,
        id: String
    ) {
        let view = BrowserExtensionServiceViewController()
        let flowController = BrowserExtensionServiceFlowController(viewController: view)
        flowController.parent = parent
        
        let presenter = BrowserExtensionServicePresenter(
            flowController: flowController,
            name: name,
            date: date,
            id: id
        )
        presenter.view = view
        
        view.presenter = presenter

        navigationController.pushViewController(view, animated: true)
    }
}

extension BrowserExtensionServiceFlowController {
    var viewController: BrowserExtensionServiceViewController {
        _viewController as! BrowserExtensionServiceViewController
    }
}

extension BrowserExtensionServiceFlowController: BrowserExtensionServiceFlowControlling {
    func toUnpairQuestion() {
        let alert = AlertControllerDismissFlow(
            title: T.Browser.deletingPairedDeviceTitle,
            message: T.Browser.deletingPairedDeviceContent,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: T.Commons.delete, style: .destructive) { [weak self] _ in
            self?.viewController.presenter.handleUnpair()
        })
        viewController.present(alert, animated: true)
    }
    
    func toUnpairingService(with id: String) {
        parent?.unpairService(with: id)
    }
}
