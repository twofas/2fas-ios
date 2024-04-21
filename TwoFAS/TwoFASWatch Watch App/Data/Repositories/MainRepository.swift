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

protocol MainRepository: AnyObject {
    func saveStorage()
    func service(for secret: String) -> ServiceData?
    func listAllServicesWithingCategories(
        for phrase: String?,
        sorting: SortType,
        ids: [ServiceTypeID]
    ) -> [CategoryData]
    func countServices() -> Int
    var hasServices: Bool { get }
    func token(
        secret: Secret,
        time: Date?,
        digits: Digits,
        period: Period,
        algorithm: CommonWatch.Algorithm,
        counter: Int,
        tokenType: TokenType
    ) -> TokenValue

    func markIntroductionAsShown()
    func wasIntroductionShown() -> Bool
    var sortType: SortType? { get }
    func setSortType(_ sortType: SortType)
    var pin: AppPIN? { get }
    func setPIN(_ pin: AppPIN?)
    
    func lockApp()
    func unlockApp()
    var isAppLocked: Bool { get }
    
    var currentCloudState: CloudState { get }
    func registerForCloudStateChanges(_ listener: @escaping CloudStateListener, id: CloudStateListenerID)
    func unregisterForCloudStageChanges(with id: CloudStateListenerID)
    func enableCloudBackup()
    func synchronizeCloudBackup()
    func syncDidReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (BackgroundFetchResult) -> Void
    )

    func serviceDefinition(using serviceTypeID: ServiceTypeID) -> ServiceDefinition?
    func iconTypeID(for serviceTypeID: ServiceTypeID?) -> UIImage

    func listFavoriteServices() -> [ServiceData]
    func addFavoriteService(_ secret: Secret)
    func removeFavoriteService(_ secret: Secret)
}

final class MainRepositoryImpl: MainRepository {
    var storageError: ((String) -> Void)?
    
    let service: ServiceHandler
    let protection: Protection
    let storage: Storage
    let categoryHandler: CategoryHandler
    let sectionHandler: SectionHandler
    let cloudHandler: CloudHandlerType
    let userDefaultsRepository: UserDefaultsRepository
    let iconDatabase: IconDescriptionDatabase
    let serviceDefinitionDatabase: ServiceDefinitionDatabase
    let iconDescriptionDatabase: IconDescriptionDatabase
    let logDataChange: LogDataChange
    let storageRepository: StorageRepository
    
    let notificationCenter = NotificationCenter.default
    
    private(set) var isAppLocked: Bool
    
    private static var _shared: MainRepositoryImpl!
    
    static var shared: MainRepositoryImpl {
        if _shared == nil {
            MainRepositoryImpl.create()
        }
        return _shared
    }
    
    private var favoriteServicesCache: [Secret]?
    
    static func create() {
        let protection = Protection()
        
        EncryptionHolder.initialize(with: protection.localKeyEncryption)
        
        let storage = Storage(readOnly: false) { Log($0, module: .storage) }
        
        let serviceMigration = ServiceMigrationController(storageRepository: storage.storageRepository)
        serviceMigration.serviceNameTranslation = T.Commons.service
        
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
    
    private init(
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
        
        userDefaultsRepository = UserDefaultsRepositoryImpl()
        
        storageRepository = storage.storageRepository
        isAppLocked = userDefaultsRepository.pin != nil
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
}

extension MainRepositoryImpl {
    func markIntroductionAsShown() {
        userDefaultsRepository.markIntroductionAsShown()
    }
    
    func wasIntroductionShown() -> Bool {
        userDefaultsRepository.wasIntroductionShown
    }
    
    var sortType: SortType? {
        userDefaultsRepository.sortType
    }
    
    func setSortType(_ sortType: SortType) {
        userDefaultsRepository.setSortType(sortType)
    }
    
    var pin: AppPIN? {
        userDefaultsRepository.pin
    }
    
    func setPIN(_ pin: AppPIN?) {
        userDefaultsRepository.setPIN(pin)
    }
}

extension MainRepositoryImpl {
    func lockApp() {
        isAppLocked = true
        notificationCenter.post(name: .appLockUpdate, object: nil)
    }
    func unlockApp() {
        isAppLocked = false
        notificationCenter.post(name: .appLockUpdate, object: nil)
    }
}

extension MainRepositoryImpl {
    var currentCloudState: CloudState {
        cloudHandler.currentState.toCloudState
    }
    
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
    
    func synchronizeCloudBackup() {
        cloudHandler.synchronize()
    }
    
    func syncDidReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (BackgroundFetchResult) -> Void
    ) {
        SyncInstanceWatch.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
}

extension MainRepositoryImpl {
    func serviceDefinition(using serviceTypeID: ServiceTypeID) -> ServiceDefinition? {
        serviceDefinitionDatabase.service(using: serviceTypeID)
    }
    
    func iconTypeID(for serviceTypeID: ServiceTypeID?) -> UIImage {
        guard let serviceTypeID, let serviceDef = serviceDefinitionDatabase.service(using: serviceTypeID) else {
            return ServiceIcon.for(iconTypeID: IconTypeID.default)
        }
        return ServiceIcon.for(iconTypeID: serviceDef.iconTypeID)
    }
}

extension MainRepositoryImpl {
    func listFavoriteServices() -> [ServiceData] {
        initializeFavoriteServicesCache()
        guard let favoriteServicesCache else { return [] }
        return favoriteServicesCache.compactMap({ storageRepository.findService(for: $0) })
            .sorted(by: { $0.name < $1.name })
    }
    
    func addFavoriteService(_ secret: Secret) {
        initializeFavoriteServicesCache()
        guard favoriteServicesCache?.first(where: { $0 == secret }) == nil else { return }
        favoriteServicesCache?.append(secret)
        saveFavoriteServicesCache()
    }
    
    func removeFavoriteService(_ secret: Secret) {
        initializeFavoriteServicesCache()
        favoriteServicesCache?.removeAll(where: { $0 == secret })
        saveFavoriteServicesCache()
    }
    
    private func initializeFavoriteServicesCache() {
        if favoriteServicesCache != nil {
            return
        }
        let value = userDefaultsRepository.favoriteServices() ?? []
        favoriteServicesCache = Array(Set(value))
    }
    
    private func saveFavoriteServicesCache() {
        guard let favoriteServicesCache else {
            Log("Can't get Favorite Services for saving")
            return
        }
        userDefaultsRepository.setFavoriteServices(favoriteServicesCache)
    }
}

public extension Notification.Name {
    static let appLockUpdate = Notification.Name("appLockUpdate")
}
