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

protocol NewsPlainFlowControllerParent: AnyObject {
    func newsClose()
    func newsToBackup()
}

protocol NewsPlainFlowControlling: AnyObject {
    func openWeb(with url: URL)
    func toClose()
    func toInternalLink(_ internalLink: ListNewsEntry.InternalLink)
}

final class NewsPlainFlowController: FlowController {
    private weak var parent: NewsPlainFlowControllerParent?
    private weak var navigationController: UINavigationController?
    
    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: NewsPlainFlowControllerParent
    ) {
        let view = NewsViewController()
        let flowController = NewsPlainFlowController(viewController: view)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.newsModuleInteractor()
        let presenter = NewsPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.setViewControllers([view], animated: false)
    }
}

extension NewsPlainFlowController {
    var viewController: NewsViewController { _viewController as! NewsViewController }
}

extension NewsPlainFlowController: NewsPlainFlowControlling {
    func openWeb(with url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func toClose() {
        parent?.newsClose()
    }
    
    func toInternalLink(_ internalLink: ListNewsEntry.InternalLink) {
        switch internalLink {
        case .backup:
            parent?.newsToBackup()
        }
    }
}
