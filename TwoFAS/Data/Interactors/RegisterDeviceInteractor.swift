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
import PushNotifications
import Common

public enum RegisterDeviceError: Error {
    case noInternet
    case serverError
    case noToken
}

public enum UpdateDeviceError: Error {
    case noInternet
    case serverError
    case noToken
    case notRegistered
}

public protocol RegisterDeviceInteracting: AnyObject {
    var isDeviceRegistered: Bool { get }
    var isCrashlyticsDisabled: Bool { get }
    func initialize()
    func registerDevice(completion: @escaping (Result<Void, RegisterDeviceError>) -> Void)
    func updateDevice(completion: @escaping (Result<Void, UpdateDeviceError>) -> Void)
    func setCrashlyticsDisabled(_ disabled: Bool)
}

final class RegisterDeviceInteractor {
    private let fcmRegistrationAwaitingTime = 5
    
    private let mainRepository: MainRepository
    private let localName: WebExtensionLocalDeviceNameInteracting
    private let channelState: FCMHandlerProtocol
    private let logTokenLength: Int = 8
    
    private var isRegistering = false
    private var awaitingGCMToken: String?
    private var awaitingRegistrationCompletion: ((Result<Void, RegisterDeviceError>) -> Void)?
    
    init(mainRepository: MainRepository, localName: WebExtensionLocalDeviceNameInteracting) {
        self.mainRepository = mainRepository
        self.localName = localName
        channelState = mainRepository.channelStateController
        channelState.FCMTokenObtained = { [weak self] in self?.gcmTokenObtained($0) }
    }
}

// swiftlint:disable line_length
extension RegisterDeviceInteractor: RegisterDeviceInteracting {
    var isDeviceRegistered: Bool {
        mainRepository.isDeviceIDSet
    }
    
    var shouldRefresh: Bool {
        mainRepository.registrationDate?.isOlderThanTwoMonths ?? true
    }
    
    var isCrashlyticsDisabled: Bool {
        mainRepository.isCrashlyticsDisabled
    }
    
    func initialize() {
        Log("RegisterDeviceInteractor - Initializing", module: .interactor)
        channelState.initializeFCM()
        channelState.enableCrashlytics(!mainRepository.isCrashlyticsDisabled)
        if isDeviceRegistered {
            Log("RegisterDeviceInteractor - device is registered: \(mainRepository.deviceID?.suffix(logTokenLength) ?? "-")", module: .interactor)
            channelState.enableFCM()
            
            if shouldRefresh {
                Log("RegisterDeviceInteractor - refreshing token, GCM token: \(mainRepository.isGCMTokenSet)", module: .interactor)
                updateDevice { result in
                    Log("RegisterDeviceInteractor - result of refresh: \(result)", module: .interactor)
                }
            } else {
                Log("RegisterDeviceInteractor - no need for refresh", module: .interactor)
            }
        } else {
            Log("RegisterDeviceInteractor - device not registered yet", module: .interactor)
        }
    }
    
    func registerDevice(completion: @escaping (Result<Void, RegisterDeviceError>) -> Void) {
        Log("RegisterDeviceInteractor - Registering", module: .interactor)
        
        guard !isDeviceRegistered else {
            Log("RegisterDeviceInteractor - already registered", module: .interactor)
            completion(.success(Void()))
            return
        }
        
        channelState.enableFCM()
        
        Log("RegisterDeviceInteractor - awating GCM token", module: .interactor)
        
        let dispatchTime: DispatchTime = .now().advanced(by: .seconds(fcmRegistrationAwaitingTime))
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            let tokenExists = self.mainRepository.isGCMTokenSet
            let token = self.mainRepository.gcmToken?.suffix(self.logTokenLength) ?? "-"
            Log(
                "RegisterDeviceInteractor - awaiting for GCM token finished, tokenExists: \(tokenExists), partial-token: \(token)",
                module: .interactor
            )
            Log("RegisterDeviceInteractor - isDeviceRegistered: \(self.isDeviceRegistered)", module: .interactor)
            Log("RegisterDeviceInteractor - isDeviceRegistering: \(self.isRegistering)", module: .interactor)
            guard !self.isDeviceRegistered else {
                completion(.success(Void()))
                return
            }
            
            guard !self.isRegistering else {
                self.awaitingRegistrationCompletion = completion
                return
            }
            
            self.registerDeviceOnServer(completion: completion)
        }
    }
    
    func updateDevice(completion: @escaping (Result<Void, UpdateDeviceError>) -> Void) {
        Log("RegisterDeviceInteractor - Updating", module: .interactor)
        guard let gcmToken = mainRepository.gcmToken else {
            Log("RegisterDeviceInteractor - Updating failure! No FCM Token", module: .interactor)
            completion(.failure(.noToken))
            return
        }
        
        updateDevice(using: gcmToken, completion: completion)
    }
    
    func setCrashlyticsDisabled(_ disabled: Bool) {
        mainRepository.setCrashlyticsDisabled(disabled)
    }
}
// swiftlint:enable line_length

// swiftlint:disable line_length
private extension RegisterDeviceInteractor {
    func registerDeviceOnServer(completion: @escaping (Result<Void, RegisterDeviceError>) -> Void) {
        Log("RegisterDeviceInteractor - registerDeviceOnServer", module: .interactor)
        isRegistering = true
        let deviceName = localName.currentDeviceName
        let gcmToken = mainRepository.gcmToken
        
        Log("RegisterDeviceInteractor - Registering device named: \(deviceName)", module: .interactor)
        
        mainRepository.registerDevice(for: deviceName, gcmToken: gcmToken) { [weak self] result in
            self?.isRegistering = false
            switch result {
            case .success(let data):
                Log("RegisterDeviceInteractor - Register success!", module: .interactor)
                Log("RegisterDeviceInteractor - DeviceID: \(data.id)", module: .interactor, save: false)
                self?.mainRepository.saveDeviceID(data.id)
                self?.mainRepository.saveRegistrationDate()
                if let awaitingGCMToken = self?.awaitingGCMToken {
                    self?.updateWithAwaitingGCMToken(awaitingGCMToken, completion: completion)
                } else {
                    completion(.success(Void()))
                }
            case .failure(let error):
                Log("RegisterDeviceInteractor - Register failure! \(error)", module: .interactor)
                switch error {
                case .connection:
                    completion(.failure(.serverError))
                case .noInternet:
                    completion(.failure(.noInternet))
                }
            }
        }
    }
    
    func updateWithAwaitingGCMToken(
        _ awaitingGCMToken: String,
        completion: @escaping (Result<Void, RegisterDeviceError>) -> Void
    ) {
        Log("RegisterDeviceInteractor - have awating GCM token", module: .interactor)
        updateDevice(using: awaitingGCMToken) { [weak self] result in
            switch result {
            case .success:
                self?.mainRepository.saveGCMToken(awaitingGCMToken)
                self?.awaitingGCMToken = nil
                completion(.success(Void()))
            case .failure:
                completion(.failure(.noToken))
            }
        }
    }
    
    func updateDevice(using gcmToken: String, completion: @escaping (Result<Void, UpdateDeviceError>) -> Void) {
        guard let deviceID = mainRepository.deviceID else {
            Log("RegisterDeviceInteractor - Updating failure! Device is not registered!", module: .interactor)
            completion(.failure(.notRegistered))
            return
        }
        
        let deviceName = localName.currentDeviceName
        
        mainRepository.updateDeviceNameToken(deviceName, gcmToken: gcmToken, for: deviceID) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                Log(
                    "RegisterDeviceInteractor - Updating success! Partial-token: \(gcmToken.suffix(logTokenLength))",
                    module: .interactor
                )
                mainRepository.saveRegistrationDate()
                completion(.success(Void()))
            case .failure(let error):
                Log("RegisterDeviceInteractor - Updating failure! error: \(error)", module: .interactor)
                switch error {
                case .noInternet: completion(.failure(.noInternet))
                case .connection: completion(.failure(.serverError))
                }
            }
        }
    }
    
    func gcmTokenObtained(_ token: String) {
        if isRegistering {
            awaitingGCMToken = token
            return
        }
        func register() {
            mainRepository.saveGCMToken(token)
            registerDeviceOnServer { [weak self] result in
                guard let completion = self?.awaitingRegistrationCompletion else { return }
                switch result {
                case .success: completion(.success(Void()))
                case .failure(let error): completion(.failure(error))
                }
                self?.awaitingRegistrationCompletion = nil
            }
        }
        
        func update() {
            Log("RegisterDeviceInteractor - Updating with new FCM token")
            updateDevice(using: token) { [weak self] result in
                switch result {
                case .success: self?.mainRepository.saveGCMToken(token)
                case .failure(let error):
                    Log(
                        "RegisterDeviceInteractor - couldn't update FCM/FCM on server! Error: \(error)",
                        module: .interactor
                    )
                }
            }
        }
        
        Log("RegisterDeviceInteractor - FCM token obtained! Partial-token: \(token.suffix(self.logTokenLength))", module: .interactor)
        Log("FCM/FCM: \(token)", module: .interactor, save: false)
        
        if isDeviceRegistered {
            Log("RegisterDeviceInteractor - Token obtained, device registered", module: .interactor)
            if let storedToken = mainRepository.gcmToken {
                Log(
                    "RegisterDeviceInteractor - have stored FCM token. Partial-token: \(storedToken.suffix(self.logTokenLength))",
                    module: .interactor
                )
                if storedToken != token {
                    Log(
                        "RegisterDeviceInteractor - stored FCM token is diffrent then the new one - update",
                        module: .interactor
                    )
                    update()
                }
            } else {
                Log("RegisterDeviceInteractor - no stored FCM token - updating", module: .interactor)
                update()
            }
        } else {
            Log("RegisterDeviceInteractor - Token obtained, device not registered", module: .interactor)
            register()
        }
    }
}
// swiftlint:enable line_length
