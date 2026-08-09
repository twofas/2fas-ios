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
import Data
import Common

protocol RootModuleInteracting: AnyObject {
    var introductionWasShown: Bool { get }
    var isAuthenticationRequired: Bool { get }
    var storageError: ((String) -> Void)? { get set }
    
    func initializeApp()
    func applicationWillResignActive()
    func applicationWillEnterForeground()
    func applicationDidEnterBackground()
    func applicationDidBecomeActive(didCopyToken: @escaping Callback)
    func applicationWillTerminate()
    
    func lockApplicationIfNeeded(presentLoginImmediately: @escaping () -> Void)
    
    func shouldHandleURL(url: URL) -> Bool

    func lockScreenActive()
    func lockScreenInactive()

    var isBiometryAuthenticating: Bool { get }
}

final class RootModuleInteractor {
    var storageError: ((String) -> Void)?
    
    private let rootInteractor: RootInteracting
    private let linkInteractor: LinkInteracting
    private let fileInteractor: FileInteracting
    private let registerDeviceInteractor: RegisterDeviceInteracting
    private let appStateInteractor: AppStateInteracting
    private let notificationInteractor: NotificationInteracting
    private let widgetsInteractor: WidgetsInteracting
    private let localNotificationStateInteractor: LocalNotificationStateInteracting
    
    init(
        rootInteractor: RootInteracting,
        linkInteractor: LinkInteracting,
        fileInteractor: FileInteracting,
        registerDeviceInteractor: RegisterDeviceInteracting,
        appStateInteractor: AppStateInteracting,
        notificationInteractor: NotificationInteracting,
        widgetsInteractor: WidgetsInteracting,
        localNotificationStateInteractor: LocalNotificationStateInteracting
    ) {
        self.rootInteractor = rootInteractor
        self.linkInteractor = linkInteractor
        self.fileInteractor = fileInteractor
        self.registerDeviceInteractor = registerDeviceInteractor
        self.appStateInteractor = appStateInteractor
        self.notificationInteractor = notificationInteractor
        self.widgetsInteractor = widgetsInteractor
        self.localNotificationStateInteractor = localNotificationStateInteractor
        
        rootInteractor.storageError = { [weak self] error in
            self?.storageError?(error)
        }
    }
}

extension RootModuleInteractor: RootModuleInteracting {
    var introductionWasShown: Bool {
        rootInteractor.introductionWasShown
    }
    
    var isAuthenticationRequired: Bool {
        rootInteractor.isAuthenticationRequired
    }
    
    func initializeApp() {
        rootInteractor.initializeApp()
        registerDeviceInteractor.initialize()
    }

    func lockApplicationIfNeeded(presentLoginImmediately: @escaping () -> Void) {
        rootInteractor.lockApplicationIfNeeded(
            presentLoginImmediately: presentLoginImmediately
        )
    }
    
    func applicationWillResignActive() {
        appStateInteractor.saveAppState(.resiging)
        rootInteractor.applicationWillResignActive()
    }
    
    func applicationWillEnterForeground() {
        appStateInteractor.saveAppState(.foreground)
        rootInteractor.applicationWillEnterForeground()
    }
    
    func applicationDidEnterBackground() {
        appStateInteractor.saveAppState(.background)
    }
    
    func applicationWillTerminate() {
        rootInteractor.applicationWillTerminate()
    }
    
    func applicationDidBecomeActive(didCopyToken: @escaping Callback) {
        appStateInteractor.saveAppState(.active)
        if let token = widgetsInteractor.exchangeToken {
            notificationInteractor.copy(value: token.removeWhitespaces())
            widgetsInteractor.clearExchangeToken()
            didCopyToken()
        }
        rootInteractor.applicationDidBecomeActive()
        localNotificationStateInteractor.activate()
    }
    
    func shouldHandleURL(url: URL) -> Bool {
        let shouldHandleURL = linkInteractor.shouldHandleURL(url: url)
        let shouldHandleFileURL = fileInteractor.shouldHandleURL(url: url)
        let value = shouldHandleURL || shouldHandleFileURL
        
        if value {
            appStateInteractor.markURLWillBeHandled()
        }
        
        return value
    }
    
    func lockScreenActive() {
        appStateInteractor.lockScreenActive()
    }

    func lockScreenInactive() {
        appStateInteractor.lockScreenInactive()
    }

    var isBiometryAuthenticating: Bool {
        appStateInteractor.isBiometryAuthenticating
    }
}
