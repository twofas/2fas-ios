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
import Common
import NetworkStack
@_implementationOnly import PushNotifications

protocol MainRepository: AnyObject {
    // MARK: - Security
    var isPINSet: Bool { get }
    var currentCodeLength: Int { get }
    func isPINCorrect(_ code: [Int]) -> Bool
    var biometryType: BiometryType { get }
    var isBiometryEnabled: Bool { get }
    var isBiometryAvailable: Bool { get }
    func enableBiometry()
    func disableBiometry()
    func clearAllUserDefaults()
        
    var pinType: PINType? { get }
    func setPINOff()
    func validatePIN(_ PIN: String) -> Bool
    func savePIN(_ PIN: String, typeOfPIN: PINType)
    
    func securityApplicationWillEnterForeground()
    func securityApplicationDidBecomeActive()
    func securityLockApplication()
    var securityIsAuthenticationRequired: Bool { get }
    
    // MARK: App lock
    var appLockAttempts: AppLockAttempts? { get }
    func setAppLockAttempts(_ value: AppLockAttempts)

    var appLockBlockTime: AppLockBlockTime? { get }
    func setAppLockBlockTime(_ value: AppLockBlockTime)
  
    var lockAppUntil: Date? { get }
    func setLockAppUntil(date: Date)
    func clearLockAppUntil()
    
    // MARK: - Extensions
    var areWidgetsEnabled: Bool { get }
    var shouldShowWidgetEnablingWarning: Bool { get }
    func enableWidgets()
    func disableWidgets()
    func markWidgetEnablingWarningAsShown()
    func reloadWidgets()
    // MARK: Exchange Token
    var exchangeToken: String? { get }
    func setExchangeToken(_ key: String)
    func clearExchangeToken()
    
    // MARK: - Appearance
    
    // MARK: Next Token
    var isNextTokenEnabled: Bool { get }
    func enableNextToken()
    func disableNextToken()
    // MARK: Active Search
    var isActiveSearchEnabled: Bool { get }
    func enableActiveSearch()
    func disableActiveSearch()
    // MARK: List style
    var selectedListStyle: ListStyle { get }
    func setSelectListStyle(_ listStyle: ListStyle)
    // MARK: Hide tokens
    var areTokensHidden: Bool { get }
    func setTokensHidden(_ hidden: Bool)
    // MARK: Animation
    var shouldAnimate: Bool { get }
    // MARK: Main menu
    var isMainMenuPortraitCollapsed: Bool { get }
    func setIsMainMenuPortraitCollapsed(_ isCollapsed: Bool)
    var isMainMenuLandscapeCollapsed: Bool { get }
    func setIsMainMenuLandscapeCollapsed(_ isCollapsed: Bool)
    
    // MARK: - Tokens
    func token(
        secret: Secret,
        time: Date?,
        digits: Digits,
        period: Period,
        algorithm: Common.Algorithm,
        counter: Int,
        tokenType: TokenType
    ) -> TokenValue
    
    // MARK: - General
    var currentAppVersion: String { get }
    func setIntroductionAsShown()
    func introductionWasShown() -> Bool
    func setCrashlyticsDisabled(_ disabled: Bool)
    var isCrashlyticsDisabled: Bool { get }
    
    func initialPermissionStateSetChildren(_ children: [PermissionsStateChildDataControllerProtocol])
    func initialPermissionStateInitialize()
    
    // MARK: - Services
    var hasServices: Bool { get }
    
    // MARK: - Cloud
    var secretSyncError: ((String) -> Void)? { get set }
    var isCloudBackupConnected: Bool { get }
    var successSyncDate: Date? { get }
    var cloudCurrentState: CloudState { get }
    func registerForCloudStateChanges(_ listener: @escaping CloudStateListener, id: CloudStateListenerID)
    func unregisterForCloudStageChanges(with id: CloudStateListenerID)
    func enableCloudBackup()
    func disableCloudBackup()
    func clearBackup()
    func synchronizeBackup()
    func syncDidReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    )
    func saveSuccessSyncDate(_ date: Date?)
    
    // MARK: - Import
    var fileURL: URL? { get set }
    func countNewServices(from services: [ServiceData]) -> Int
    func importServices(_ services: [ServiceData], sections: [CommonSectionData]) -> Int
    func openFile(url: URL, completion: @escaping (Result<Data, OpenError>) -> Void)
    
    // MARK: - Export
    func export(with password: String?, finished: @escaping (URL?) -> Void)
    
    // MARK: - Storage
    var storageError: ((String) -> Void)? { get set }
    
    func saveStorage()
    func trashService(_ serviceData: ServiceData)
    func untrashService(_ serviceData: ServiceData)
    func listTrashedServices() -> [ServiceData]
    func listAllExistingServices() -> [ServiceData]
    func listAllNotTrashed() -> [ServiceData]
    func serviceExists(for secret: String) -> ServiceExistenceStatus
    func trashedService(for secret: String) -> ServiceData?
    func addService(
        name: String,
        secret: String,
        serviceTypeID: ServiceTypeID?,
        additionalInfo: String?,
        rawIssuer: String?,
        otpAuth: String?,
        tokenPeriod: Period?,
        tokenLength: Digits,
        badgeColor: TintColor?,
        iconType: IconType,
        iconTypeID: IconTypeID,
        labelColor: TintColor,
        labelTitle: String,
        algorithm: Algorithm,
        counter: Int?,
        tokenType: TokenType,
        source: ServiceSource
    )
    func addService(
        name: String,
        secret: String,
        serviceTypeID: ServiceTypeID?,
        additionalInfo: String?,
        rawIssuer: String?,
        otpAuth: String?,
        tokenPeriod: Period?,
        tokenLength: Digits,
        badgeColor: TintColor?,
        iconType: IconType,
        iconTypeID: IconTypeID,
        labelColor: TintColor,
        labelTitle: String,
        algorithm: Algorithm,
        counter: Int?,
        tokenType: TokenType,
        source: ServiceSource,
        sectionID: SectionID?
    )
    func updateService(
        _ serviceData: ServiceData,
        name: String,
        serviceTypeID: ServiceTypeID?,
        additionalInfo: String?,
        badgeColor: TintColor?,
        iconType: IconType,
        iconTypeID: IconTypeID,
        labelColor: TintColor,
        labelTitle: String,
        counter: Int?
    )
    func deleteService(_ serviceData: ServiceData)
    func service(for secret: String) -> ServiceData?
    func incrementCounter(for: Secret)
    func listAllServicesWithingCategories(
        for phrase: String?,
        sorting: SortType,
        ids: [ServiceTypeID]
    ) -> [CategoryData]
    func countServices() -> Int
    func obtainNextUnknownCodeCounter() -> Int
    func moveSectionDown(_ sectionData: SectionData)
    func moveSectionUp(_ sectionData: SectionData)
    func deleteSection(_ sectionData: SectionData)
    func renameSection(_ sectionData: SectionData, newTitle: String)
    func moveService(_ service: ServiceData, from oldIndex: Int, to newIndex: Int, newSection: SectionData?)
    func setSectionZeroIsCollapsed(_ isCollapsed: Bool)
    func collapseSection(_ sectionData: SectionData, isCollapsed: Bool)
    var isSectionZeroCollapsed: Bool { get }
    
    // MARK: - App info
    var appVersion: String? { get }
    var appBundleIdentifier: String? { get }
    var dateOfFirstRun: Date? { get }
    func saveDateOfFirstRun(_ date: Date)
    
    // MARK: - Lock Screen
    var isLockScreenActive: Bool { get }
    func lockScreenActive()
    func lockScreenInactive()
    
    // MARK: - New Version
    var newVersionCounter: Int { get }
    func setNewVersionCounter(_ counter: Int)
    var newVersionCheckDisabled: Bool { get }
    func setNewVersionCheckDisabled(_ disabled: Bool)
    var newVersionTracked: String? { get }
    func setNewVersionTracked(_ version: String)
    var newVersionIgnored: String? { get }
    func setNewVersionIgnored(_ version: String)
    func fetchNewVersion(completion: @escaping (Result<FetchNewVersionAppInfo, Error>) -> Void)
    
    // MARK: - Code
    var storedURL: URL? { get }
    func shouldHandleURL(_ code: URL) -> Bool
    func storeURL(_ code: URL)
    func hasStoredURL() -> Bool
    func clearStoredURL()
    func codeFromStoredURL() -> Code?
    func codeTypeFromStoredURL() -> CodeType?
    var hasIncorrectCode: Bool { get }
    func clearHasIncorrectCode()
    func saveHasIncorrectCode()
    
    // MARK: - Old controllers
    var security: SecurityProtocol { get }
    var timerHandler: TimerHandler { get }
    var counterHandler: CounterHandler { get }
    var notificationStateController: NotificationStateProtocol { get }
    var channelStateController: FCMHandlerProtocol { get }
    
    // MARK: - Vision
    func scan(image: UIImage, completion: @escaping (Result<[String], ScanImageError>) -> Void)
    
    // MARK: - Sort
    var sortType: SortType? { get }
    func setSortType(_ sortType: SortType)
    
    // MARK: - Advanced Alert State
    var advancedAlertShown: Bool { get }
    func markAdvancedAlertAsShown()
    
    // MARK: - RSA Encryption
    var privateRSAKey: Data? { get }
    var publicRSAKey: Data? { get }
    var areRSAExtensionKeysGenerated: Bool { get }
    
    func generateRSAPair() -> (privateKey: Data, publicKey: Data)?
    func decryptRSA(data dataToDecryptInBase64String: String, using privateKey: Data) -> Data?
    func encryptRSA(data: Data, using publicKeyInBase64String: String) -> Data?
    func saveRSAKeys(privateKey: Data, publicKey: Data)
    func markRSAExtensionKeysAsGenerated()
    func clearRSAExtensionKeys()
    
    // MARK: - Device name
    var getProposedDeviceName: String { get }
    var savedDeviceName: String? { get }
    func saveNewDeviceName(_ newDeviceName: String)
    
    // MARK: - DeviceID
    var isDeviceIDSet: Bool { get }
    var deviceID: String? { get }
    func saveDeviceID(_ deviceID: String)
    func clearDeviceID()
    
    // MARK: - FCM Token
    var isGCMTokenSet: Bool { get }
    var gcmToken: String? { get }
    func saveGCMToken(_ gcmToken: String)
    func clearGCMToken()
    
    // MARK: - Network
    var hasSSLNetworkError: Bool { get }
    func markSSLNetworkError()
    func clearSSLNetworkError()
    
    func registerDevice(
        for name: String,
        gcmToken: GCMToken?,
        completion: @escaping (Result<RegisterDevice.ResultData, NetworkError>) -> Void
    )
    func pairWithWebExtension(
        for deviceID: DeviceID,
        extensionID: ExtensionID,
        deviceName: String,
        devicePublicKey: String,
        completion: @escaping (Result<PairWithWebExtension.ResultData, NetworkError>) -> Void
    )
    func listAllPairings(
        for deviceID: DeviceID,
        completion: @escaping (Result<ListAllPairings.ResultData, NetworkError>) -> Void
    )
    func getPairing(
        for deviceID: DeviceID,
        extensionID: ExtensionID,
        completion: @escaping (Result<GetPairing.ResultData, NetworkError>) -> Void
    )
    func deletePairing(
        for deviceID: DeviceID,
        extensionID: ExtensionID,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
    func deleteAllPairings(
        for deviceID: DeviceID,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
    func updateDeviceNameToken(
        _ deviceName: String,
        gcmToken: String,
        for deviceID: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
    func listAll2FARequests(
        for deviceID: DeviceID,
        completion: @escaping (Result<ListAll2FARequests.ResultData, NetworkError>) -> Void
    )
    func send2FAToken(
        for deviceID: DeviceID,
        extensionID: ExtensionID,
        tokenRequestID: String,
        token: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
    func listAllNews(
        publishedAfter: String,
        completion: @escaping (Result<[ListNews.NewsEntry], NetworkError>) -> Void
    )
    func uploadLogs(
        _ logs: String,
        auditID: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
    
    // MARK: - Notifications state
    var notificationState: PushNotificationState { get }
    func setNotificationState(_ state: PushNotificationState)
    
    // MARK: - Pairing web extension
    func savePairedExtension(with extensionID: ExtensionID, name: String, publicKey: String)
    func listAllPairedExtensions() -> [PairedWebExtension]
    func deletePairedExtension(with extensionID: ExtensionID)
    func updateName(for extensionID: ExtensionID, newName: String)
    
    // MARK: - Auth Request for web extension
    func removeAuthRequest(for extensionID: ExtensionID)
    func removeAuthRequest(_ authRequest: PairedAuthRequest)
    func removeAuthRequests(_ authRequests: [PairedAuthRequest])
    func createAuthRequest(for secret: String, extensionID: ExtensionID, domain: String)
    func listAllAuthRequests(for secret: String) -> [PairedAuthRequest]
    func listAllAuthRequests(for domain: String, extensionID: ExtensionID) -> [PairedAuthRequest]
    func updateAuthRequestUsage(for authRequest: PairedAuthRequest)
    func removeAllAuthRequests()
    func addIgnoredTokenRequestIDs(_ id: String)
    func ignoredTokenRequestIDs() -> [String]
    
    // MARK: Time Offset
    var currentDate: Date { get }
    
    // MARK: - News
    func setIsFetchingNews(_ isFetching: Bool)
    func isFetchingNews() -> Bool
    func saveLastNewsFetch(_ lastFetch: Date)
    func lastNewsFetch() -> Date?
    func createNewsEntry(from newsEntry: ListNewsEntry)
    func deleteNewsEntry(with newsEntry: ListNewsEntry)
    func updateNewsEntry(with newsEntry: ListNewsEntry)
    func markNewsEntryAsRead(with newsEntry: ListNewsEntry)
    func listAllNews() -> [ListNewsEntry]
    func listAllFreshlyAddedNews() -> [ListNewsEntry]
    func hasNewsEntriesUnreadItems() -> Bool
    func markAllNewsEntriesAsRead()
    func storeNewsCompletions(_ completion: @escaping () -> Void)
    func callAndClearNewsCompletions()
        
    // MARK: - Push Notifications
    func lastSavedNotification() -> LastSavedNotification?
    func clearLastSavedNotification()
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data)
    func didFailToRegisterForRemoteNotifications(with error: Error)
    
    // MARK: - Categories/Sections
    func listAllSections() -> [SectionData]
    func moveServiceToSection(secret: String, sectionID: SectionID?)
    func section(for secret: String) -> SectionData?
    @discardableResult
    func createSection(with title: String) -> SectionID
    
    // MARK: - Notifications
    func copy(_ str: String)
    func wobbleWarning()
    func wobbleError()
    func wobbleSuccess()
    
    // MARK: - Service Definition
    func serviceDefinition(using serviceTypeID: ServiceTypeID) -> ServiceDefinition?
    func serviceName(for serviceTypeID: ServiceTypeID?) -> String?
    func allServiceDefinitions() -> [ServiceDefinition]
    func findService(using issuer: String) -> ServiceDefinition?
    func findLegacyService(using string: String) -> ServiceTypeID?
    func findLegacyIcon(using string: String) -> IconTypeID?
    func findServices(byTag searchText: String) -> [ServiceDefinition]
    func findServicesByTagOrIssuer(_ searchText: String, exactMatch: Bool, useTags: Bool) -> [ServiceDefinition]
    func findServices(domain searchText: String) -> [ServiceDefinition]
    
    // MARK: - Icons
    func iconTypeID(for serviceTypeID: ServiceTypeID?) -> UIImage
    func grouppedList() -> [IconDescriptionGroup]
    func iconName(for iconTypeID: IconTypeID) -> String?

    // MARK: - Camera
    var permission: CameraPermissionState { get }
    var isCameraPresent: Bool { get }
    func checkForPermission() -> CameraPermissionState
    func requestPermission(result: @escaping (CameraPermissionState) -> Void)
    
    // MARK: - Logs
    func generateLogs() -> String
    var totalDiskSpace: String { get }
    var freeDiskSpace: String { get }
    var usedDiskSpace: String { get }
    var currentDevice: String { get }
    var systemVersion: String { get }
    
    // MARK: - View Path
    func clearViewPath()
    func saveViewPath(_ path: ViewPath)
    func viewPath() -> (viewPath: ViewPath, savedAt: Date)?
    
    // MARK: - Guides
    func listAllGuides() -> [ServiceGuide]
    func loadGuideData(for serviceGuide: ServiceGuide) -> ServiceGuideDescription?
    
    // MARK: - Data injections
    var serviceNameTranslation: String { get }
    
    // MARK: - Time Verification
    func timeVerificationStart()
    
    // MARK: - MDM options
    var mdmIsBackupBlocked: Bool { get }
    var mdmIsBiometryBlocked: Bool { get }
    var mdmIsBrowserExtensionBlocked: Bool { get }
    var mdmLockoutAttempts: AppLockAttempts? { get }
    var mdmLockoutBlockTime: AppLockBlockTime? { get }
    var mdmIsPasscodeRequried: Bool { get }
    
    // MARK: - Local Notifications
    var localNotificationPublicationDate: Date? { get }
    func saveLocalNotificationPublicationDate(_ date: Date?)
    
    var localNotificationPublicationID: String? { get }
    func saveLocalNotificationPublicationID(_ ID: String?)
    
    var localNotificationWasRead: Bool { get }
    func saveLocalNotificationWasRead(_ wasRead: Bool)
    
    var localNotificationCycle: Int { get }
    func saveLocalNotificationCycle(_ cycle: Int)
    
    var runCount: Int { get }
    func saveRunCount(_ count: Int)
    
    var localNotificationsHandled: Bool { get }
    func markLocalNotificationsAsHandled()
}
