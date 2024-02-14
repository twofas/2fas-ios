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
    
    private var currentState = State.initial {
        didSet {
            Log("RootPresenter: new currentState: \(currentState)")
        }
    }

    private var isCoverActive = false
    
    private var viewWillAppearEvent: Callback?
    private var viewDidAppearEvent: Callback?
    
    private let flowController: RootFlowControlling
    private let interactor: RootModuleInteracting
    
    init(flowController: RootFlowControlling, interactor: RootModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
    
    func initialize() {
        interactor.initializeApp()
        interactor.storageError = { [weak self] error in
            self?.flowController.toStorageError(error: error)
        }
        handleViewFlow()
    }
    
    // MARK: - handling app delegates
    
    func applicationWillResignActive() {
        Log("App: applicationWillResignActive")
        view?.hideAllNotifications()
        interactor.applicationWillResignActive()
        
        interactor.lockScreenActive()
        installCover()
    }
    
    func applicationDidEnterBackground() {
        Log("App: applicationDidEnterBackground")
        
        interactor.lockApplicationIfNeeded { [weak self] in
            self?.removeCover()
            self?.presentLogin(immediately: true)
        }
        viewWillAppearEvent?()
    }
    
    func applicationWillEnterForeground() {
        Log("App: applicationWillEnterForeground")
        lockScreenIsInactive()
        interactor.applicationWillEnterForeground()
        removeCover()
        handleViewFlow()
    }
    
    func applicationDidBecomeActive() {
        Log("App: applicationDidBecomeActive")
        lockScreenIsInactive()
        interactor.applicationDidBecomeActive { [weak self] in
            Log("App: Token copied")
            self?.view?.tokenCopied()
        }
        removeCover(animated: true)
        viewDidAppearEvent?()
        view?.rateApp()
    }
    
    func applicationWillTerminate() {
        Log("App: applicationWillTerminate")
        interactor.applicationWillTerminate()
    }
    
    func shouldHandleURL(url: URL) -> Bool {
        Log("App: shouldHandleURL")
        return interactor.shouldHandleURL(url: url)
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        Log("App: didRegisterForRemoteNotifications")
        interactor.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func didFailToRegisterForRemoteNotifications(with error: Error) {
        Log("App: didFailToRegisterForRemoteNotifications")
        interactor.didFailToRegisterForRemoteNotifications(with: error)
    }
    
    func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Log("App: didReceiveRemoteNotification")
        interactor.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func handleIntroHasFinished() {
        handleViewFlow()
    }
    
    func handleUserWasLoggedIn() {
        viewWillAppearEvent = nil
        viewDidAppearEvent = nil
        interactor.lockScreenInactive()
        handleViewFlow()
    }
    
    // MARK: - RootCoordinatorDelegate methods
    
    func handleViewFlow() {
        let coldRun = (currentState == .initial)
        
        Log("RootPresenter: Changing state for: \(currentState)")
        
        if !interactor.introductionWasShown {
            presentIntroduction()
        } else if interactor.isAuthenticationRequired {
            presentLogin(immediately: coldRun)
        } else {
            presentMain(immediately: coldRun)
        }
    }
    
    // MARK: - Private methods
    
    private func lockScreenIsInactive() {
        if currentState == .main {
            interactor.lockScreenInactive()
        }
    }
    
    private func installCover() {
        guard currentState != .login else { return }
        flowController.toDismissKeyboard()
        isCoverActive = true
        flowController.toCover()
    }
    
    private func removeCover(animated: Bool = false) {
        guard isCoverActive else { return }
        isCoverActive = false
        guard  currentState != .login else { return }
        flowController.toRemoveCover(animated: animated)
    }
    
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
        
        interactor.lockScreenActive()
        Log("Presenting Login")
        flowController.toLogin { [weak self] viewWillAppearEvent, viewDidAppearEvent in
            self?.viewWillAppearEvent = viewWillAppearEvent
            self?.viewDidAppearEvent = viewDidAppearEvent
        }
    }
    
    private func changeState(_ newState: State) {
        currentState = newState
    }
}
