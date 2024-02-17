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

import Foundation
@_implementationOnly import PushNotifications
import Common

public protocol PushNotificationRegistrationInteracting: PermissionsStateChildDataControllerProtocol {
    var stateIsKnown: Callback? { get set }
    var state: PushNotificationState { get }
    var wasUserAsked: Bool { get }
    func checkState()
    func register(continueCallback: @escaping Callback)
    func markAsDenied()
}

final class PushNotificationRegistrationInteractor {
    private let mainRepository: MainRepository
    private let notificationState: NotificationStateProtocol
    
    private(set) var isInProcess = false
    
    var stateIsKnown: Callback?
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
        notificationState = mainRepository.notificationStateController
    }
}

extension PushNotificationRegistrationInteractor: PushNotificationRegistrationInteracting {
    var state: PushNotificationState {
        mainRepository.notificationState
    }
    
    var wasUserAsked: Bool {
        mainRepository.notificationState == .allowed || mainRepository.notificationState == .denied
    }
    
    // MARK: - App startup
    
    func checkState() {
        Log("PushNotificationRegistrationInteractor - checkState()", module: .interactor)
        notificationState.checkStatus { [weak self] state in
            self?.isInProcess = false
            switch state {
            case .authorized:
                Log("Push Notification state - allowed", module: .interactor)
                self?.mainRepository.setNotificationState(.allowed)
            case .denied:
                Log("Push Notification state: denided", module: .interactor)
                self?.mainRepository.setNotificationState(.denied)
            case .notDetermined:
                Log("Push Notification state - notDetermined", module: .interactor)
                self?.mainRepository.setNotificationState(.notDetermined)
            }
            self?.stateIsKnown?()
        }
    }
    
    // MARK: - Registration
    
    func register(continueCallback: @escaping Callback) {
        guard (state == .notDetermined || state == .allowed) && !isInProcess else {
            Log("""
                PushNotificationRegistrationInteractor - no need to register again
                state: \(state)
                isInProcess: \(isInProcess)
                """,
                module: .interactor
            )
            continueCallback()
            return
        }
        isInProcess = true
        
        Log("PushNotificationRegistrationInteractor - registering device if needed", module: .interactor)
        
        notificationState.registerForPushNotifications { [weak self] state in
            switch state {
            case .succesful(let deviceToken):
                Log("PushNotificationRegistrationInteractor - deviceToken obtained!", module: .interactor)
                Log(
                    "PushNotificationRegistrationInteractor - The Device Token: \(deviceToken)",
                    module: .interactor,
                    save: false
                )
                self?.mainRepository.setNotificationState(.allowed)
            case .failed(let error):
                Log("""
                        PushNotificationRegistrationInteractor - Error while registering Push Notifications
                        Error: \(String(describing: error))
                    """,
                    module: .interactor
                )
                self?.mainRepository.setNotificationState(.error)
            case .denied:
                Log(
                    "PushNotificationRegistrationInteractor - Error while performing registration. Was denied!",
                    module: .interactor
                )
                self?.mainRepository.setNotificationState(.denied)
            }
            self?.isInProcess = false
            continueCallback()
        }
    }
    
    func markAsDenied() {
        mainRepository.setNotificationState(.denied)
    }
}
