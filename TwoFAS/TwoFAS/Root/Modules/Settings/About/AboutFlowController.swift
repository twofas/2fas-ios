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
import SwiftUI
import Data

protocol AboutFlowControllerParent: AnyObject {}

protocol AboutFlowControlling: AnyObject {
    func toShare()
    func toWriteReview()
    func toPrivacyPolicy()
    func toTOS()
    func toSendLogs()
    func toAcknowledgements()
    func toSocial(_ channel: SocialChannel)
    func close()
}

final class AboutFlowController: FlowController {
    private weak var parent: AboutFlowControllerParent?

    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: AboutFlowControllerParent
    ) {
        let hosting = create(parent: parent, showsBackButton: false)
        navigationController.setViewControllers([hosting], animated: false)
    }

    static func push(
        in navigationController: UINavigationController,
        parent: AboutFlowControllerParent
    ) {
        let hosting = create(parent: parent, showsBackButton: true)
        navigationController.pushRootViewController(hosting, animated: true)
    }

    private static func create(
        parent: AboutFlowControllerParent,
        showsBackButton: Bool
    ) -> UIViewController {
        let hosting = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        hosting.hidesBottomBarWhenPushed = false
        let flowController = AboutFlowController(viewController: hosting)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.aboutModuleInteractor()
        let presenter = AboutPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.showsBackButton = showsBackButton
        hosting.rootView = AnyView(AboutView(presenter: presenter))
        return hosting
    }
}

extension AboutFlowController: AboutFlowControlling {
    func toShare() {
        guard let vc = _viewController else { return }
        let activity = ShareActivityController.create(T.Settings.recommendation, title: T.Settings.supportAndShare)
        vc.present(activity, animated: true, completion: nil)
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

    func toSendLogs() {
        guard let vc = _viewController else { return }
        UploadLogsNavigationFlowController.present(on: vc, auditID: nil, parent: self)
    }

    func toAcknowledgements() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }

    func toSocial(_ channel: SocialChannel) {
        UIApplication.shared.open(
            channel.url,
            options: [:],
            completionHandler: nil
        )
    }

    func close() {
        _viewController?.navigationController?.popViewController(animated: true)
    }
}

extension AboutFlowController: UploadLogsNavigationFlowControllerParent {
    func uploadLogsClose() {
        _viewController?.dismiss(animated: true)
    }
}
