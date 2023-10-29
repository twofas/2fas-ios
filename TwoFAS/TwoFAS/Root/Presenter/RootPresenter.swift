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
import Data

final class RootPresenter {
    var view: RootViewControlling?
    
    private enum State {
        case initial
        case login
        case intro
        case main
    }
    let rootViewController: RootViewController
    let mainRepository: MainRepositoryInitialization
    private let flowController: RootFlowControlling
    
    private let interactor: RootModuleInteracting
    
    private var currentState = State.initial {
        didSet {
            Log("RootCoordinator: new currentState: \(currentState)")
        }
    }
    
    override init() {
        rootViewController = RootViewController()
        mainRepository = MainRepositoryInitialization(serviceNameTranslation: T.Commons.service)
        
        super.init()
        
        mainRepository.storageError = { [weak self] error in
            self?.flowController.toStorageError(error: error)
        }
        mainRepository.presentLogin = { [weak self] immediately in
            self?.presentLogin(immediately: immediately)
        }

        
    }
    
    // MARK: - handling app delegates
    
    func applicationWillResignActive() {
        Log("App: applicationWillResignActive")
        view?.hideAllNotifications()
        mainRepository.applicationWillResignActive()
    }
    
    func applicationWillEnterForeground() {
        Log("App: applicationWillEnterForeground")
        mainRepository.applicationWillEnterForeground()
        handleViewFlow()
    }
    
    func applicationDidEnterBackground() {
        Log("App: applicationDidEnterBackground")
        lockApplicationIfNeeded()
    }
    
    func applicationDidBecomeActive() {
        Log("App: applicationDidBecomeActive")
        mainRepository.applicationDidBecomeActive()
        view?.rateApp()
    }
    
    func applicationWillTerminate() {
        Log("App: applicationWillTerminate")
        mainRepository.applicationWillTerminate()
    }
    
    func shouldHandleURL(url: URL) -> Bool {
        Log("App: shouldHandleURL")
        return mainRepository.shouldHandleURL(url: url)
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        Log("App: didRegisterForRemoteNotifications")
        mainRepository.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func didFailToRegisterForRemoteNotifications(with error: Error) {
        Log("App: didFailToRegisterForRemoteNotifications")
        mainRepository.didFailToRegisterForRemoteNotifications(with: error)
    }
    
    func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Log("App: didReceiveRemoteNotification")
        mainRepository.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func start() {
        handleViewFlow()
    }
    
    func handleIntroMarkAsShown() {
        interactor.markIntroAsShown()
    }
    
    func handleIntroHasFinished() {
        
    }
    
    // MARK: - RootCoordinatorDelegate methods
    
    func handleViewFlow() {
        let coldRun = (currentState == .initial)
        
        Log("RootCoordinator: Changing state for: \(currentState)")
        
        if !mainRepository.introductionWasShown {
            presentIntroduction()
        } else if mainRepository.security.isAuthenticationRequired {
            presentLogin(immediately: coldRun)
        } else {
            presentMain(immediately: coldRun)
        }
    }
    
    // MARK: - Private methods
    
    private func presentIntroduction() {
        guard currentState != .intro else { return }
        changeState(.intro)
        Log("Presenting Introduction")
        flowController.toIntro()
    }
    
    private func presentMain(immediately: Bool) {
        guard currentState != .main else { return }
        let immediately = !(currentState == .login || currentState == .intro)
        changeState(.main)
        Log("Presenting Main")
        flowController.toMain(immediately: immediately)
    }
    
    private func presentLogin(immediately: Bool) {
        guard currentState != .login else { return }
        changeState(.login)
        
        view?.dismissAllViewControllers()

        Log("Presenting Login")
        flowController.toLogin()
    }
    
    private func lockApplicationIfNeeded() {
        interactor.lockApplicationIfNeeded()
    }
    
    private func changeState(_ newState: State) {
        currentState = newState
    }
}


