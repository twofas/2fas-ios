//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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
import SyncWatch
import ProtectionWatch
import CommonWatch
import StorageWatch
import ContentWatch


// register for background push!
//optional func didReceiveRemoteNotification(_ userInfo: [AnyHashable : Any]) async -> WKBackgroundFetchResult
// save Storage on going to background!


final class MainRepositoryImpl {
    var storageError: ((String) -> Void)?

    let service: ServiceHandler
    let protection: Protection
    let storage: Storage
    let categoryHandler: CategoryHandler
    let sectionHandler: SectionHandler
    let cloudHandler: CloudHandlerType
//    let userDefaultsRepository: UserDefaultsRepository
    let iconDatabase: IconDescriptionDatabase
    let serviceDefinitionDatabase: ServiceDefinitionDatabase
    let iconDescriptionDatabase: IconDescriptionDatabase
    let logDataChange: LogDataChange
    let storageRepository: StorageRepository
    
    let notificationCenter = NotificationCenter.default
    
    private static var _shared: MainRepositoryImpl!
    
    static var shared: MainRepositoryImpl {
        if _shared == nil {
            MainRepositoryImpl.create()
        }
        return _shared
    }
    
    var _isLockScreenActive = false

    //
    //    let handler = SyncInstanceWatch.getCloudHandler()
    //    handler.registerForStateChange({ state in
    //        print(">>> \(state)")
    //        if state == .disabledAvailable {
    //            handler.enable()
    //            handler.synchronize()
    //        }
    //        syncStstus = "\(state)"
    //        if state == .enabled(sync: .synced) {
    //            print(">>>! \(storage.storageRepository.countServicesNotTrashed())")
    //        }
    //    }, with: "listener!")
    //    handler.enable()
    //    handler.synchronize()
    //}

    static func create() {
        let protection = Protection()
        
        EncryptionHolder.initialize(with: protection.localKeyEncryption)
        
        let storage = Storage(readOnly: false) { Log($0, module: .storage) }
                
        let serviceMigration = ServiceMigrationController(storageRepository: storage.storageRepository)
        serviceMigration.serviceNameTranslation = "Service"//T.Commons.service
        
        SyncInstanceWatch.initialize(commonSectionHandler: storage.section, commonServiceHandler: storage.service) {
            Log("Sync: \($0)")
        }
        SyncInstanceWatch.migrateStoreIfNeeded()
        serviceMigration.migrateIfNeeded()
                                                                        
        _ = MainRepositoryImpl(
            protection: protection,
            storage: storage,
            cloudHandler: SyncInstanceWatch.getCloudHandler(),
            logDataChange: SyncInstanceWatch.logDataChange
        )
    }
    
    init(
        protection: Protection,
        storage: Storage,
        cloudHandler: CloudHandlerType,
        logDataChange: LogDataChange
    ) {
        self.service = storage.service
        self.protection = protection
        self.storage = storage
        self.categoryHandler = storage.category
        self.sectionHandler = storage.section
        self.cloudHandler = cloudHandler
        self.logDataChange = logDataChange
        
        iconDatabase = IconDescriptionDatabaseImpl()
        serviceDefinitionDatabase = ServiceDefinitionDatabaseImpl()
        iconDescriptionDatabase = IconDescriptionDatabaseImpl()
        
        storageRepository = storage.storageRepository
        MainRepositoryImpl._shared = self

        storage.addUserPresentableError { [weak self] error in
            self?.storageError?(error)
        }
    }
}

extension MainRepositoryImpl {
    func saveStorage() {
        storage.save()
    }
    
    func service(for secret: String) -> ServiceData? {
        storageRepository.findService(for: secret)
    }
    
    func listAllServicesWithingCategories(
        for phrase: String?,
        sorting: SortType,
        ids: [ServiceTypeID]
    ) -> [CategoryData] {
        storageRepository.listAllWithingCategories(for: phrase, sorting: sorting, ids: ids)
    }
    
    func countServices() -> Int {
        storageRepository.countServicesNotTrashed()
    }
    
    var hasServices: Bool { storageRepository.hasServices }
    
    func token(
        secret: Secret,
        time: Date?,
        digits: Digits,
        period: Period,
        algorithm: CommonWatch.Algorithm,
        counter: Int,
        tokenType: TokenType
    ) -> TokenValue {
        TokenHandler.generateToken(
            secret: secret,
            time: time,
            digits: digits,
            period: period,
            algorithm: algorithm,
            counter: counter,
            tokenType: tokenType
        )
    }
    
//    func setIntroductionAsShown() {
//        userDefaultsRepository.setIntroductionAsShown()
//    }
//    
//    func introductionWasShown() -> Bool {
//        userDefaultsRepository.introductionWasShown()
//    }
//    
    func registerForCloudStateChanges(_ listener: @escaping CloudStateListener, id: CloudStateListenerID) {
        cloudHandler.registerForStateChange({ listener($0.toCloudState) }, with: id)
        cloudHandler.checkState()
    }
    
    func unregisterForCloudStageChanges(with id: CloudStateListenerID) {
        cloudHandler.unregisterForStateChange(id: id)
    }
    
    func enableCloudBackup() {
        cloudHandler.enable()
    }
    
    func synchronizeBackup() {
        cloudHandler.synchronize()
    }
    
    func syncDidReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (BackgroundFetchResult) -> Void
    ) {
        SyncInstanceWatch.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func serviceDefinition(using serviceTypeID: ServiceTypeID) -> ServiceDefinition? {
        serviceDefinitionDatabase.service(using: serviceTypeID)
    }
    
    func iconTypeID(for serviceTypeID: ServiceTypeID?) -> UIImage {
        guard let serviceTypeID, let serviceDef = serviceDefinitionDatabase.service(using: serviceTypeID) else {
            return ServiceIcon.for(iconTypeID: IconTypeID.default)
        }
        return ServiceIcon.for(iconTypeID: serviceDef.iconTypeID)
    }
    
//    var sortType: SortType? {
//        userDefaultsRepository.sortType
//    }
//    
//    func setSortType(_ sortType: SortType) {
//        userDefaultsRepository.setSortType(sortType)
//    }
}
