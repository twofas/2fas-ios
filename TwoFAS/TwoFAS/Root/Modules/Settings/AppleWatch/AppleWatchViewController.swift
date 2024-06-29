//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
//  Contributed by Grzegorz Machnio. All rights reserved.
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

protocol AppleWatchFlowControllerParent: AnyObject {}

protocol AppleWatchFlowControlling: AnyObject {
    func toSystemWatchApp()
    func toBackupSettings()
}

final class AppleWatchFlowController: FlowController {
    private weak var parent: AppleWatchFlowControllerParent?
    private weak var navigationController: UINavigationController?

    static func push(
        in navigationController: UINavigationController,
        parent: AppleWatchFlowControllerParent
    ) {
        let viewController = AppleWatchViewController()
        let flowController = AppleWatchFlowController(viewController: viewController)
        flowController.parent = parent
        flowController.navigationController = navigationController
        let presenter = AppleWatchPresenter(flowController: flowController)
        viewController.presenter = presenter

        navigationController.pushRootViewController(viewController, animated: true)
    }
}

extension AppleWatchFlowController: AppleWatchFlowControlling {
    func toSystemWatchApp() {
        if let url = URL(string: "itms-watchs://") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Handle the case where the URL can't be opened
            print("Unable to open Watch app.")
        }
    }
    
    func toBackupSettings() {
        //TODO:
    }
}

final class AppleWatchPresenter {
    private let flowController: AppleWatchFlowControlling

    init(flowController: AppleWatchFlowControlling) {
        self.flowController = flowController
    }
}

extension AppleWatchPresenter {
    func handleInstallationStep(number: Int) {
        if number == 1 {
            flowController.toSystemWatchApp()
        } else if number == 2 {
            flowController.toBackupSettings()
        }
    }
}


final class AppleWatchViewController: UIViewController {
    var presenter: AppleWatchPresenter!

    override func viewDidLoad() {
        title = "Apple watch"

        let installationStepAction: (_ stepNumber: Int) -> Void = { [weak self] stepNumber in
            self?.presenter.handleInstallationStep(number: stepNumber)
        }
        let appleWatchView = AppleWatchView(
            appleWatchInstallationSteps: [
                .init(descirption: "Install 2FAS Auth via Watch app",
                      actionTitle: "Open Watch app"),
                .init(descirption: "Ensure your 2FAS Backup iCloud sync is enabled.",
                      actionTitle: "Go to 2FAS Backup settings")
            ],
            installationStepActionCallback: installationStepAction
        )
        let hostingController = UIHostingController(rootView: appleWatchView)
        hostingController.willMove(toParent: self)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.pinToParent()
        hostingController.didMove(toParent: self)
    }

}
