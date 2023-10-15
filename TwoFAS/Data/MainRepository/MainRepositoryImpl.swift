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
import PushNotifications
import CodeSupport
import Common
import Token
import Sync
import NetworkStack
import TimeVerification

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
    let sync: CloudHandlerType
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
    
    let serviceNameTranslation: String
    
    private static var _shared: MainRepositoryImpl!
    
    lazy var notificationStateController: NotificationStateProtocol = { pushNotifications.notificationState }()
    lazy var channelStateController: FCMHandlerProtocol = { pushNotifications.fcmHandler }()
    
    let feedbackGenerator = UINotificationFeedbackGenerator()
    
    var currentDate: Date {
        timeVerificationController.currentDate
    }
    
    var ignoredTokenRequestIDsList: [String] = []
    
    static var shared: MainRepository { _shared }
    
    var storedURL: URL?
    var fileURL: URL?
    var sslNetworkError = false
    var lastFetchedNewsTimestamp: Date?
    var isFetchingNewsFlag = false
    var newsCompletions: [() -> Void] = []
    
    // Cached values for higher pefrormance
    var cachedSortType: SortType?
    var cachedSortTypeInitialized = false
    var _notificationState: PushNotificationState = .unknown
    
    init(
        service: ServiceHandler,
        pushNotifications: PushNotifications,
        cameraPermissions: CameraPermissions,
        security: SecurityProtocol,
        protectionModule: Protection,
        storage: Storage,
        timerHandler: TimerHandler,
        counterHandler: CounterHandler,
        timeVerificationController: TimeVerificationController,
        sync: CloudHandlerType,
        categoryHandler: CategoryHandler,
        sectionHandler: SectionHandler,
        cloudHandler: CloudHandlerType,
        logDataChange: LogDataChange,
        serviceNameTranslation: String
    ) {
        self.service = service
        self.pushNotifications = pushNotifications
        self.cameraPermissions = cameraPermissions
        self.security = security
        self.protectionModule = protectionModule
        self.storage = storage
        self.timerHandler = timerHandler
        self.counterHandler = counterHandler
        self.timeVerificationController = timeVerificationController
        self.sync = sync
        self.categoryHandler = categoryHandler
        self.sectionHandler = sectionHandler
        self.cloudHandler = cloudHandler
        self.extensionsStorage = protectionModule.extensionsStorage
        self.userDefaultsRepository = UserDefaultsRepositoryImpl()
        self.logDataChange = logDataChange
        self.serviceNameTranslation = serviceNameTranslation
        
        storageRepository = storage.storageRepository
        timeVerificationController.log = { value in Log(value, module: .counter) }
        
        security.interactor = AppLockStateInteractor(mainRepository: self)
        MainRepositoryImpl._shared = self
    }
}
