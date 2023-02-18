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

protocol NewsFlowControllerParent: AnyObject {}

protocol NewsFlowControlling: AnyObject {
    func openWeb(with url: URL)
}

final class NewsFlowController: FlowController {
    private weak var parent: NewsFlowControllerParent?
    private weak var navigationController: UINavigationController?

    static func showAsATab(
        in tabBarController: UITabBarController,
        parent: NewsFlowControllerParent
    ) {
        let view = NewsViewController()
        let flowController = NewsFlowController(viewController: view)
        flowController.parent = parent
        let interactor = InteractorFactory.shared.newsModuleInteractor()
        let presenter = NewsPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        let naviController = CommonNavigationController(rootViewController: view)
        naviController.tabBarItem = {
            let barItem = UITabBarItem(
                title: T.Commons.notifications,
                image: Asset.tabBarIconNotificationsInactive.image
                    .withRenderingMode(.alwaysTemplate),
                selectedImage: Asset.tabBarIconNotificationsActive.image
                    .withRenderingMode(.alwaysTemplate)
            )
            return barItem
        }()
        
        flowController.navigationController = naviController
                
        tabBarController.addTab(naviController)
    }
    
    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: NewsFlowControllerParent
    ) -> NewsViewController {
        let view = NewsViewController()
        let flowController = NewsFlowController(viewController: view)
        flowController.parent = parent
        let interactor = InteractorFactory.shared.newsModuleInteractor()
        let presenter = NewsPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
                
        navigationController.setViewControllers([view], animated: false)
        navigationController.setNavigationBarHidden(false, animated: false)
        return view
    }
}

extension NewsFlowController {
    var viewController: NewsViewController { _viewController as! NewsViewController }
}

extension NewsFlowController: NewsFlowControlling {
    func openWeb(with url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
