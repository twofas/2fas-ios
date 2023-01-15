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

final class LoginCoordinator: Coordinator, LoginCoordinatorDelegate {
    weak var loginCoordinatorDelegate: LoginCoordinatorDelegate?
    
    private let security: SecurityProtocol
    private let leftButtonDescription: String?
    private let rootViewController: ContainerViewController
    private let showImmediately: Bool
    
    init(
        security: SecurityProtocol,
        leftButtonDescription: String? = nil,
        rootViewController: ContainerViewController,
        showImmediately: Bool
    ) {
        self.security = security
        self.leftButtonDescription = leftButtonDescription
        self.rootViewController = rootViewController
        self.showImmediately = showImmediately
    }
    
    override func start() {
        let appLockStateInteractor = AppLockStateInteractor(mainRepository: MainRepositoryImpl.shared)
        let viewModel = LoginViewModel(
            security: security,
            resetApp: { [weak self] in self?.presentResetAppViewController() },
            leftButtonDescription: leftButtonDescription,
            appLockStateInteractor: appLockStateInteractor
        )
        viewModel.coordinatorDelegate = self
        
        let login = LoginViewController()
        login.viewModel = viewModel
        
        rootViewController.present(login, immediately: showImmediately, animationType: .alpha)        
    }
    
    func authorized() {
        parentCoordinatorDelegate?.didFinish()
        loginCoordinatorDelegate?.authorized()
    }
    
    func cancelled() {
        parentCoordinatorDelegate?.didFinish()
        loginCoordinatorDelegate?.cancelled()
    }
    
    private func presentResetAppViewController() {
        let contentMiddle = MainContainerMiddleContentGenerator(placement: .centerHorizontallyLimitWidth, elements: [
            .image(name: "ResetShield", size: CGSize(width: 100, height: 100)),
            .extraSpacing,
            .text(text: T.Restore.applicationRestoration, style: MainContainerTextStyling.title),
            .text(text: T.Restore.resetPinTitle, style: MainContainerTextStyling.content),
            .extraSpacing,
            .image(name: "WarningIconLarge", size: CGSize(width: 100, height: 100)),
            .extraSpacing,
            .text(text: T.Restore.backupAdvice, style: MainContainerTextStyling.content),
            .text(text: T.Restore.backupTitle, style: MainContainerTextStyling.content)
        ])
        
        let contentBottom = MainContainerBottomContentGenerator(elements: [
            .extraSpacing(),
            .filledButton(text: T.Commons.dismiss, callback: { [weak self] in
                self?.dismissResetScreen()
            })
        ])
        
        let config = MainContainerViewController.Configuration(
            barConfiguration: MainContainerBarConfiguration.empty,
            contentTop: nil,
            contentMiddle: contentMiddle,
            contentBottom: contentBottom,
            generalConfiguration: nil
        )
        
        let vc = MainContainerViewController()
        vc.configure(with: config)
        vc.isModalInPresentation = true
        rootViewController.present(vc, animated: true, completion: nil)
    }
    
    private func dismissResetScreen() {
        rootViewController.dismiss(animated: true, completion: nil)
    }
}
