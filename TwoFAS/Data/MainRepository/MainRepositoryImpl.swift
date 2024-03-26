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
@_implementationOnly import PushNotifications
import Common
import Sync
import NetworkStack
import TimeVerification
import Content
import CommonUIKit

final class MainRepositoryImpl: MainRepository {
    let service: ServiceHandler
    let pushNotifications: PushNotifications
    let cameraPermissions: CameraPermissions
    let security: SecurityProtocol
    let protectionModule: Protection
    let storage: Storage
    let timerHandler: TimerHandler
    let counterHandler: CounterHandler
    let timeVerificationController: TimeVerificationController
    let categoryHandler: CategoryHandler
    let sectionHandler: SectionHandler
    let cloudHandler: CloudHandlerType
    let extensionsStorage: ExtensionsStorage
    let userDefaultsRepository: UserDefaultsRepository
    let storageRepository: StorageRepository
    let logDataChange: LogDataChange
    let networkStack = NetworkStack(baseURL: Config.API.baseURL)
    let iconDatabase: IconDescriptionDatabase = IconDescriptionDatabaseImpl()
    let serviceDefinitionDatabase: ServiceDefinitionDatabase = ServiceDefinitionDatabaseImpl()
    let iconDescriptionDatabase: IconDescriptionDatabase = IconDescriptionDatabaseImpl()
    let initialPermissionStateDataController = PermissionsStateDataController()
    let mdmRepository: MDMRepository = MDMRepositoryImpl()
    
    let serviceNameTranslation: String
    let notificationCenter = NotificationCenter.default
    
    private static var _shared: MainRepositoryImpl!
    
    lazy var notificationStateController: NotificationStateProtocol = { pushNotifications.notificationState }()
    lazy var channelStateController: FCMHandlerProtocol = { pushNotifications.fcmHandler }()
    
    let feedbackGenerator = UINotificationFeedbackGenerator()
    
    var currentDate: Date {
        timeVerificationController.currentDate
    }
    
    var ignoredTokenRequestIDsList: [String] = []
    
    static var shared: MainRepository {
        if _shared == nil {
            MainRepositoryImpl.create(
                serviceNameTranslation: DataExternalTranslations.serviceNameTranslation
            )
        }
        return _shared
    }
    
    var storedURL: URL?
    var hasIncorrectCode: Bool
    var fileURL: URL?
    var sslNetworkError = false
    var lastFetchedNewsTimestamp: Date?
    var isFetchingNewsFlag = false
    var newsCompletions: [() -> Void] = []
    var storageError: ((String) -> Void)?
    
    var _isLockScreenActive = false
    var _areLocalNotificationsHandled = false
    
    // Cached values for higher pefrormance
    var cachedSortType: SortType?
    var cachedSortTypeInitialized = false
    var _notificationState: PushNotificationState = .unknown
    
    static func create(serviceNameTranslation: String) {
        ServiceIcon.log = { AppEventLog(.missingIcon($0)) }
        let protection = Protection()
        
        EncryptionHolder.initialize(with: protection.localKeyEncryption)
        
        let storage = Storage(readOnly: false) { error in
            DebugLog(error)
        }
        
        LogStorage.setStorage(storage.log)
        
        let serviceMigration = ServiceMigrationController(storageRepository: storage.storageRepository)
        
        SyncInstance.initialize(commonSectionHandler: storage.section, commonServiceHandler: storage.service) {
            DebugLog("Sync: \($0)")
        }
        SyncInstance.migrateStoreIfNeeded()
        serviceMigration.migrateIfNeeded()
        
        let security = Security(biometric: protection.biometricAuth, codeStorage: protection.codeStorage)
                                                                
        _ = MainRepositoryImpl(
            pushNotifications: PushNotifications(app: UIApplication.shared),
            cameraPermissions: CameraPermissions(),
            security: security,
            protectionModule: protection,
            storage: storage,
            timerHandler: TokenHandler.timer,
            counterHandler: TokenHandler.counter,
            timeVerificationController: TimeVerificationController(),
            cloudHandler: SyncInstance.getCloudHandler(),
            logDataChange: SyncInstance.logDataChange,
            serviceNameTranslation: serviceNameTranslation
        )
    }
    
    init(
        pushNotifications: PushNotifications,
        cameraPermissions: CameraPermissions,
        security: SecurityProtocol,
        protectionModule: Protection,
        storage: Storage,
        timerHandler: TimerHandler,
        counterHandler: CounterHandler,
        timeVerificationController: TimeVerificationController,
        cloudHandler: CloudHandlerType,
        logDataChange: LogDataChange,
        serviceNameTranslation: String
    ) {
        self.service = storage.service
        self.pushNotifications = pushNotifications
        self.cameraPermissions = cameraPermissions
        self.security = security
        self.protectionModule = protectionModule
        self.storage = storage
        self.timerHandler = timerHandler
        self.counterHandler = counterHandler
        self.timeVerificationController = timeVerificationController
        self.categoryHandler = storage.category
        self.sectionHandler = storage.section
        self.cloudHandler = cloudHandler
        self.extensionsStorage = protectionModule.extensionsStorage
        self.userDefaultsRepository = UserDefaultsRepositoryImpl()
        self.logDataChange = logDataChange
        self.serviceNameTranslation = serviceNameTranslation
        
        storageRepository = storage.storageRepository
        timeVerificationController.log = { value in Log(value, module: .counter) }
        hasIncorrectCode = false
        security.interactor = AppLockStateInteractor(mainRepository: self)
        MainRepositoryImpl._shared = self
        
        timeVerificationController.offsetUpdated = { [weak self] in
            self?.timerHandler.setOffset(offset: $0)
            self?.cloudHandler.setTimeOffset($0)
            self?.reloadWidgets()
        }

        storage.addUserPresentableError { [weak self] error in
            self?.storageError?(error)
        }
    }
}
