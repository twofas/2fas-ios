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
import Storage
import Protection
import CodeSupport
import Common
import CommonUIKit
import Token
import Sync
import TimeVerification
import PushNotifications

public final class MainRepositoryInitialization {
    private let service: ServiceHandler
    private let initialStateDataController = PermissionsStateDataController()
    private let pushNotifications: PushNotifications
    public let security: SecurityProtocol
    private let protection: Protection
    private let storage: Storage
    private let timerHandler: TimerHandler
    private let timeVerificationController: TimeVerificationController
    private let sync: CloudHandlerType
    private let categoryHandler: CategoryHandler
    private let sectionHandler: SectionHandler
    
    private var pushNotificationRegistrationInteractor: PushNotificationRegistrationInteracting?
    private var fileInteractor: FileInteracting?
    private var registerDeviceInteractor: RegisterDeviceInteracting?
    private var linkInteractor: LinkInteracting?
    private var cameraPermissionInteractor: CameraPermissionInteracting?
    
    public var storageError: ((String) -> Void)?
    public var presentLogin: ((Bool) -> Void)?
    
    public var introductionWasShown: Bool {
        MainRepositoryImpl.shared.introductionWasShown()
    }
    
    public init(serviceNameTranslation: String) {
        ServiceIcon.log = { AppEventLog(.missingIcon($0)) }
        protection = Protection()
        
        EncryptionHolder.initialize(with: protection.localKeyEncryption)
        
        storage = Storage(readOnly: false) { error in
            DebugLog(error)
        }
        
        LogStorage.setStorage(storage.log)
                
        pushNotifications = PushNotifications(app: UIApplication.shared)
        
        let serviceMigration = ServiceMigrationController(storageRepository: storage.storageRepository)
        
        SyncInstance.initialize(commonSectionHandler: storage.section, commonServiceHandler: storage.service) {
            DebugLog("Sync: \($0)")
        }
        SyncInstance.migrateStoreIfNeeded()
        serviceMigration.migrateIfNeeded()
                        
        service = storage.service
        categoryHandler = storage.category
        sectionHandler = storage.section
        
        security = Security(biometric: protection.biometricAuth, codeStorage: protection.codeStorage)
                        
        timeVerificationController = TimeVerificationController()
                
        timerHandler = TokenHandler.timer
        
        sync = SyncInstance.getCloudHandler()
                
        _ = MainRepositoryImpl(
            service: service,
            pushNotifications: pushNotifications,
            cameraPermissions: CameraPermissions(),
            security: security,
            protectionModule: protection,
            storage: storage,
            timerHandler: timerHandler,
            counterHandler: TokenHandler.counter,
            timeVerificationController: timeVerificationController,
            sync: sync,
            categoryHandler: categoryHandler,
            sectionHandler: sectionHandler,
            cloudHandler: sync,
            logDataChange: SyncInstance.logDataChange,
            serviceNameTranslation: serviceNameTranslation
        )
        
        timeVerificationController.offsetUpdated = { [weak self] in
            self?.timerHandler.setOffset(offset: $0)
            self?.sync.setTimeOffset($0)
            MainRepositoryImpl.shared.reloadWidgets()
        }
        
        fileInteractor = InteractorFactory.shared.fileInteractor()
        
        let pushInteractor = InteractorFactory.shared.pushNotificationRegistrationInteractor()
        pushNotificationRegistrationInteractor = pushInteractor

        let camera = CameraPermissionInteractor(mainRepository: MainRepositoryImpl.shared)
        cameraPermissionInteractor = camera
        
        initialStateDataController.set(children: [pushInteractor, camera])
        initialStateDataController.initialize()
        
        registerDeviceInteractor = InteractorFactory.shared.registerDeviceInteractor()
        registerDeviceInteractor?.initialize()
        
        linkInteractor = InteractorFactory.shared.linkInteractor()
        
        storage.addUserPresentableError { [weak self] error in
            self?.storageError?(error)
        }
    }
    
    public func lockApplicationIfNeeded() {
        security.lockApplication()
        
        if security.isAuthenticationRequired {
            presentLogin?(true)
        }
    }
    
    public func applicationWillResignActive() {
        storage.save()
        guard !security.isAuthenticatingUsingBiometric else { return }
    }
    
    public func applicationWillEnterForeground() {
        security.applicationWillEnterForeground()
        initialStateDataController.initialize()
    }
    
    public func applicationDidBecomeActive() {
        sync.synchronize()
        timeVerificationController.startVerification()
        security.applicationDidBecomeActive()
    }
    
    public func applicationWillTerminate() {
        storage.save()
    }
    
    public func shouldHandleURL(url: URL) -> Bool {
        (linkInteractor?.shouldHandleURL(url: url) == true) || (fileInteractor?.shouldHandleURL(url: url) == true)
    }
    
    public func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        pushNotifications.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    public func didFailToRegisterForRemoteNotifications(with error: Error) {
        pushNotifications.didFailToRegisterForRemoteNotifications(with: error)
    }
    
    public func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        SyncInstance.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    public func markAsShown() {
        MainRepositoryImpl.shared.setIntroductionAsShown()
        MainRepositoryImpl.shared.enableCloudBackup()
    }
}
