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

protocol AboutFlowControllerParent: AnyObject {}

protocol AboutFlowControlling: AnyObject {
    func toShare()
    func toWriteReview()
    func toPrivacyPolicy()
    func toTOS()
    func toSendReport(with vc: UIViewController)
    func toSendLogs()
    func toAcknowledgements()
}

final class AboutFlowController: FlowController {
    private weak var parent: AboutFlowControllerParent?
    
    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: AboutFlowControllerParent
    ) {
        let view = AboutViewController()
        let flowController = AboutFlowController(viewController: view)
        let interactor = InteractorFactory.shared.aboutModuleInteractor()
        flowController.parent = parent
        let presenter = AboutPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.view = view
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    static func push(
        in navigationController: UINavigationController,
        parent: AboutFlowControllerParent
    ) {
        let view = AboutViewController()
        let flowController = AboutFlowController(viewController: view)
        let interactor = InteractorFactory.shared.aboutModuleInteractor()
        flowController.parent = parent
        let presenter = AboutPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.view = view
        
        navigationController.pushRootViewController(view, animated: true)
    }
}

extension AboutFlowController {
    var viewController: AboutViewController { _viewController as! AboutViewController }
}

extension AboutFlowController: AboutFlowControlling {
    func toShare() {
        let vc = ShareActivityController.create(T.Settings.recommendation, title: T.Settings.supportAndShare)        
        viewController.present(vc, animated: true, completion: nil)
    }

    func toWriteReview() {
        UIApplication.shared.open(
            URL(
                string: "https://itunes.apple.com/us/app/2fa-authenticator-2fas/id1217793794?mt=8&action=write-review"
            )!,
            options: [:],
            completionHandler: nil
        )
    }

    func toPrivacyPolicy() {
        UIApplication.shared.open(
            URL(string: "https://2fas.com/privacy-policy/")!,
            options: [:],
            completionHandler: nil
        )
    }

    func toTOS() {
        UIApplication.shared.open(
            URL(string: "https://2fas.com/terms-of-service/")!,
            options: [:],
            completionHandler: nil
        )
    }

    func toSendReport(with vc: UIViewController) {
        viewController.present(vc, animated: true, completion: nil)
    }
    
    func toSendLogs() {
        UploadLogsNavigationFlowController.present(on: viewController, auditID: nil, parent: self)
    }
    
    func toAcknowledgements() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
}

extension AboutFlowController: UploadLogsNavigationFlowControllerParent {
    func uploadLogsClose() {
        viewController.dismiss(animated: true)
    }
}
