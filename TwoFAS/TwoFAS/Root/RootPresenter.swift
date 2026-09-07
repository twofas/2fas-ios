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
    }

    func applicationDidEnterBackground() {
        Log("App: applicationDidEnterBackground")

        interactor.lockScreenActive()
        installCover()

        interactor.applicationDidEnterBackground()
        interactor.lockApplicationIfNeeded { [weak self] in
            self?.removeCover()
            self?.presentLogin(fromColdStart: false)
        }
    }
    
    func applicationWillEnterForeground() {
        Log("App: applicationWillEnterForeground")
        lockScreenIsInactive()
        interactor.applicationWillEnterForeground()
        // The cover stays up until the app is active, when it flies away over the app
        // coming in, see `applicationDidBecomeActive`.
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

    func handleIntroHasFinished() {
        handleViewFlow()
    }
    
    func handleUserWasLoggedIn() {
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
            presentLogin(fromColdStart: coldRun)
        } else {
            presentMain(fromColdStart: coldRun)
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
        guard !interactor.isBiometryAuthenticating else { return }
        flowController.toDismissKeyboard()
        isCoverActive = true
        flowController.toCover()
    }
    
    private func removeCover(animated: Bool = false) {
        guard isCoverActive else { return }
        isCoverActive = false
        flowController.toRemoveCover(animated: animated)
    }
    
    private func presentIntroduction() {
        guard currentState != .intro else { return }
        changeState(.intro)
        Log("Presenting Introduction")
        flowController.toIntro()
    }
    
    /// `fromColdStart` is `true` when the app is the first thing after the system launch
    /// screen, with no lock screen in between; it then comes in the way it does from under
    /// the lock screen, see `UnlockTransition`.
    private func presentMain(fromColdStart: Bool) {
        guard currentState != .main else { return }
        // Coming from the lock screen the app animates in under it, see `UnlockTransition`.
        let fromLogin = currentState == .login
        changeState(.main)
        Log("Presenting Main")
        // With no lock screen, a cold start comes in the same way: from under a copy of the
        // launch screen, put up before the app exists so the first frame is still the launch
        // screen, then sent off the way every cover is.
        if fromColdStart {
            installCover()
        }
        flowController.toMain(animated: fromLogin)
        if fromColdStart {
            removeCover(animated: true)
        }
    }
    
    /// `fromColdStart` is `true` when the login screen is the first thing after the system
    /// launch screen, so it can take over from it seamlessly.
    private func presentLogin(fromColdStart: Bool) {
        guard currentState != .login else { return }
        changeState(.login)
        
        interactor.lockScreenActive()
        Log("Presenting Login")
        flowController.toLogin(fromColdStart: fromColdStart)
    }
    
    private func changeState(_ newState: State) {
        currentState = newState
    }
}
