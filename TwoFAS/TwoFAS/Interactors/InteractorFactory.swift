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
import Common
import Storage
import Token

final class InteractorFactory {
    static let shared = InteractorFactory()

    // TODO: Make all private when proper app structure is ready
    
    private func trashingServiceInteractor() -> TrashingServiceInteracting {
        TrashingServiceInteractor(
            mainRepository: MainRepositoryImpl.shared,
            webExtensionAuthInteractor: webExtensionAuthInteractor()
        )
    }
    
    func trashServiceInteractor() -> TrashServiceInteracting {
        TrashServiceInteractor(trashingServiceInteractor: trashingServiceInteractor())
    }
    
    func serviceModifyInteractor() -> ServiceModifyInteracting {
        ServiceModifyInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    func deleteServiceInteractor() -> DeleteServiceInteracting {
        DeleteServiceInteractor(trashingServiceInteractor: trashingServiceInteractor())
    }
    
    func newVersionInteractor() -> NewVersionInteracting {
        NewVersionInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func newCodeInteractor() -> NewCodeInteracting {
        NewCodeInteractor(
            interactorModify: serviceModifyInteractor(),
            interactorTrashed: trashingServiceInteractor(),
            serviceDefinition: serviceDefinitionInteractor()
        )
    }
    
    func sortInteractor() -> SortInteracting {
        SortInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func webExtensionEncryptionInteractor() -> WebExtensionEncryptionInteracting {
        WebExtensionEncryptionInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func webExtensionLocalDeviceNameInteractor() -> WebExtensionLocalDeviceNameInteracting {
        WebExtensionLocalDeviceNameInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func webExtensionRemoteDeviceNameInteractor() -> WebExtensionRemoteDeviceNameInteracting {
        WebExtensionRemoteDeviceNameInteractor(
            mainRepository: MainRepositoryImpl.shared,
            localName: webExtensionLocalDeviceNameInteractor()
        )
    }
    
    private func webExtensionDeviceNameInteractor() -> WebExtensionDeviceNameInteracting {
        WebExtensionDeviceNameInteractor(
            local: webExtensionLocalDeviceNameInteractor(), remote: webExtensionRemoteDeviceNameInteractor()
        )
    }
    
    func pushNotificationRegistrationInteractor() -> PushNotificationRegistrationInteracting {
        PushNotificationRegistrationInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    func registerDeviceInteractor() -> RegisterDeviceInteracting {
        RegisterDeviceInteractor(
            mainRepository: MainRepositoryImpl.shared,
            localName: webExtensionLocalDeviceNameInteractor()
        )
    }
    
    private func pairingWebExtensionInteractor() -> PairingWebExtensionInteracting {
        PairingWebExtensionInteractor(
            mainRepository: MainRepositoryImpl.shared,
            localName: webExtensionLocalDeviceNameInteractor(),
            encryption: webExtensionEncryptionInteractor()
        )
    }
    
    private func webExtensionAuthInteractor() -> WebExtensionAuthInteracting {
        WebExtensionAuthInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func serviceListingInteractor() -> ServiceListingInteracting {
        ServiceListingInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func tokenGeneratorInteractor() -> TokenGeneratorInteracting {
        TokenGeneratorInteractor(
            mainRepository: MainRepositoryImpl.shared,
            serviceInteractor: serviceModifyInteractor()
        )
    }
    
    private func listNewsNetworkInteractor() -> ListNewsNetworkInteracting {
        ListNewsNetworkInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func listNewsStorageInteractor() -> ListNewsStorageInteracting {
        ListNewsStorageInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func sectionInteractor() -> SectionInteracting {
        SectionInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    func notificationInteractor() -> NotificationInteracting {
        NotificationInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    func linkInteractor() -> LinkInteracting {
        LinkInteractor(mainRepository: MainRepositoryImpl.shared, interactorNew: newCodeInteractor())
    }
    
    private func protectionInteractor() -> ProtectionInteracting {
        ProtectionInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func timerInteractor() -> TimerInteracting {
        TimerInteractor()
    }
    
    private func appLockStateInteractor() -> AppLockStateInteracting {
        AppLockStateInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func serviceDefinitionInteractor() -> ServiceDefinitionInteracting {
        ServiceDefinitionInteractor(mainRepository: MainRepositoryImpl.shared)
    }

    func cameraPermissionInteractor() -> CameraPermissionInteracting {
        CameraPermissionInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func widgetsInteractor() -> WidgetsInteracting {
        WidgetsInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    func appearanceInteractor() -> AppearanceInteracting {
        AppearanceInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func cloudBackupStateInteractor(listenerID: String) -> CloudBackupStateInteracting {
        CloudBackupStateInteractor(
            mainRepository: MainRepositoryImpl.shared,
            listenerID: listenerID
        )
    }
    
    private func exportToFileInteractor() -> ExportToFileInteracting {
        ExportToFileInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func scanInteractor() -> ScanInteracting {
        ScanInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func iconInteractor() -> IconInteracting {
        IconInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func advancedAlertInteractor() -> AdvancedAlertInteracting {
        AdvancedAlertInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func pushNotificationInteractor() -> PushNotificationInteracting {
        PushNotificationInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func appInfoInteractor() -> AppInfoInteracting {
        AppInfoInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    func logUploadingInteractor() -> LogUploadingInteracting {
        LogUploadingInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    private func tokenInteractor() -> TokenInteracting {
        TokenInteractor(
            mainRepository: MainRepositoryImpl.shared,
            serviceInteractor: serviceModifyInteractor()
        )
    }
    
    private func viewPathInteractor() -> ViewPathIteracting {
        ViewPathInteractor(mainRepository: MainRepositoryImpl.shared)
	}

    private func networkStatusInteractor() -> NetworkStatusInteracting {
        NetworkStatusInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    func fileInteractor() -> FileInteracting {
        FileIteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    func newsInteractor() -> NewsInteracting {
        NewsInteractor(
            network: listNewsNetworkInteractor(),
            storage: listNewsStorageInteractor(),
            mainRepository: MainRepositoryImpl.shared
        )
    }
}

private extension InteractorFactory {
    func importFromFileInteractor() -> ImportFromFileInteracting {
        ImportFromFileInteractor(
            mainRepository: MainRepositoryImpl.shared,
            serviceDefinitionInteractor: serviceDefinitionInteractor()
        )
    }
}

extension InteractorFactory {
    func settingsModuleInteractor() -> SettingsModuleInteracting {
        SettingsModuleInteractor()
    }
    
    func settingsMenuModuleInteractor() -> SettingsMenuModuleInteracting {
        SettingsMenuModuleInteractor(
            widgetsInteractor: widgetsInteractor(),
            pushNotifications: pushNotificationRegistrationInteractor(),
            protectionInteractor: protectionInteractor(),
            networkStatusInteractor: networkStatusInteractor(),
            pairingDeviceInteractor: pairingWebExtensionInteractor()
        )
    }
    
    func backupMenuModuleInteractor() -> BackupMenuModuleInteracting {
        BackupMenuModuleInteractor(
            serviceListingInteractor: serviceListingInteractor(),
            cloudBackup: cloudBackupStateInteractor(listenerID: "BackupMenuModuleInteractor")
        )
    }
    
    func backupDeleteModuleInteractor() -> BackupDeleteModuleInteracting {
        BackupDeleteModuleInteractor(
            cloudBackupStateInteractor: cloudBackupStateInteractor(listenerID: "")
        )
    }
    
    func widgetWarningModuleInteractor() -> WidgetWarningModuleInteracting {
        WidgetWarningModuleInteractor(
            widgetInteractor: widgetsInteractor()
        )
    }
    
    func importerEnterPasswordModuleInteractor(data: ExchangeDataFormat) -> ImporterEnterPasswordModuleInteracting {
        ImporterEnterPasswordModuleInteractor(
            importInteractor: importFromFileInteractor(),
            data: data
        )
    }
    
    func importerOpenFileModuleInteractor(url: URL?) -> ImporterOpenFileModuleInteracting {
        ImporterOpenFileModuleInteractor(
            importInteractor: importFromFileInteractor(),
            url: url
        )
    }
    
    func importerPreimportSummaryModuleInteractor(
        countNew: Int,
        countTotal: Int,
        sections: [CommonSectionData],
        services: [ServiceData]
    ) -> ImporterPreimportSummaryModuleInteracting {
        ImporterPreimportSummaryModuleInteractor(
            importInteractor: importFromFileInteractor(),
            countNew: countNew,
            countTotal: countTotal,
            sections: sections,
            services: services
        )
    }
    
    func exporterMainScreenModuleInteractor() -> ExporterMainScreenModuleInteracting {
        ExporterMainScreenModuleInteractor(
            protectionInteractor: protectionInteractor(),
            exportToFileInteractor: exportToFileInteractor()
        )
    }
    
    func exporterPasswordProtectionModuleInteractor() -> ExporterPasswordProtectionModuleInteracting {
        ExporterPasswordProtectionModuleInteractor(
            protectionInteractor: protectionInteractor(),
            exportToFileInteractor: exportToFileInteractor()
        )
    }
    
    func exporterPINModuleInteractor() -> ExporterPINModuleInteracting {
        ExporterPINModuleInteractor(
            protectionInteractor: protectionInteractor(),
            exportToFileInteractor: exportToFileInteractor()
        )
    }
    
    func appSecurityModuleInteractor() -> AppSecurityModuleInteracting {
        AppSecurityModuleInteractor(
            protectionInteractor: protectionInteractor(),
            appLockStateInteractor: appLockStateInteractor()
        )
    }
    
    func appLockModuleInteractor() -> AppLockModuleInteracting {
        AppLockModuleInteractor(
            appLockInteractor: appLockStateInteractor()
        )
    }
    
    func verifyPINModuleInteractor() -> VerifyPINModuleInteracting {
        VerifyPINModuleInteractor(
            protectionInteractor: protectionInteractor(),
            timerInteractor: timerInteractor(),
            appLockStateInteractor: appLockStateInteractor()
        )
    }
    
    func newPINModuleInteractor() -> NewPINModuleInteracting {
        NewPINModuleInteractor()
    }
    
    func trashModuleInteractor() -> TrashModuleInteracting {
        TrashModuleInteractor(
            trashingServiceInteractor: trashingServiceInteractor()
        )
    }
    
    func cameraScannerModuleInteractor() -> CameraScannerModuleInteracting {
        CameraScannerModuleInteractor(
            newCodeInteractor: newCodeInteractor(),
            pushNotificationPermission: pushNotificationRegistrationInteractor()
        )
    }
    
    func selectFromGalleryModuleInteractor() -> SelectFromGalleryModuleInteracting {
        SelectFromGalleryModuleInteractor(
            scanInteractor: scanInteractor(),
            newCodeInteractor: newCodeInteractor()
        )
    }
    
    func colorPickerModuleInteractor() -> ColorPickerModuleInteracting {
        ColorPickerModuleInteractor()
    }
    
    func iconSelectorModuleInteractor(
        defaultIcon: IconTypeID?,
        selectedIcon: IconTypeID?
    ) -> IconSelectorModuleInteracting {
        IconSelectorModuleInteractor(
            iconInteractor: iconInteractor(),
            serviceDefinitionInteractor: serviceDefinitionInteractor(),
            defaultIcon: defaultIcon,
            selectedIcon: selectedIcon
        )
    }
    
    func composeServiceModuleInteractor(secret: Secret?) -> ComposeServiceModuleInteracting {
        ComposeServiceModuleInteractor(
            modifyInteractor: serviceModifyInteractor(),
            trashingServiceInteractor: trashingServiceInteractor(),
            protectionInteractor: protectionInteractor(),
            secret: secret,
            webExtensionAuthInteractor: webExtensionAuthInteractor(),
            sectionInteractor: sectionInteractor(),
            notificationsInteractor: notificationInteractor(),
            serviceDefinitionInteractor: serviceDefinitionInteractor(),
            advancedAlertInteractor: advancedAlertInteractor()
        )
    }
    
    func composeServiceAdvancedSummaryModuleInteractor(
        settings: ComposeServiceAdvancedSettings
    ) -> ComposeServiceAdvancedSummaryModuleInteracting {
        ComposeServiceAdvancedSummaryModuleInteractor(
            notificationInteractor: notificationInteractor(),
            settings: settings
        )
    }
    
    func composeServiceAdvancedEditModuleInteractor(
        settings: ComposeServiceAdvancedSettings
    ) -> ComposeServiceAdvancedEditModuleInteracting {
        ComposeServiceAdvancedEditModuleInteractor(
            settings: settings
        )
    }
    
    func browserExtensionIntroModuleInteractor() -> BrowserExtensionIntroModuleInteracting {
        BrowserExtensionIntroModuleInteractor(
            cameraPermissionInteractor: cameraPermissionInteractor(),
            pushNotificationRegistrationInteractor: pushNotificationRegistrationInteractor()
        )
    }
    
    func browserExtensionPairingModuleInteractor(extensionID: ExtensionID) -> BrowserExtensionPairingModuleInteracting {
        BrowserExtensionPairingModuleInteractor(
            webPairing: pairingWebExtensionInteractor(),
            extensionID: extensionID
        )
    }
    
    func browserExtensionMainModuleInteractor() -> BrowserExtensionMainModuleInteracting {
        BrowserExtensionMainModuleInteractor(
            pairingDeviceInteractor: pairingWebExtensionInteractor(),
            deviceNameInteractor: webExtensionDeviceNameInteractor(),
            cameraPermissionInteractor: cameraPermissionInteractor()
        )
    }
    
    func selectServiceModuleInteractor() -> SelectServiceModuleInteracting {
        SelectServiceModuleInteractor(
            listingInteractor: serviceListingInteractor(),
            serviceDefinitionInteractor: serviceDefinitionInteractor(),
            sortInteractor: sortInteractor(),
            pairedBrowsers: pairingWebExtensionInteractor()
        )
    }
    
    func authRequestsModuleInteractor() -> AuthRequestsModuleInteracting {
        AuthRequestsModuleInteractor(
            webExtensionAuthInteractor: webExtensionAuthInteractor(),
            serviceListingInteractor: serviceListingInteractor(),
            tokenGeneratorInteractor: tokenGeneratorInteractor(),
            pairingWebExtensionInteractor: pairingWebExtensionInteractor(),
            webExtensionEncryptionInteractor: webExtensionEncryptionInteractor(),
            pushNotificationInteractor: pushNotificationInteractor()
        )
    }
    
    func composeServiceWebExtensionModuleInteractor(secret: String) -> ComposeServiceWebExtensionModuleInteracting {
        ComposeServiceWebExtensionModuleInteractor(
            webExtensionAuthInteracting: webExtensionAuthInteractor(),
            pairingWebExtensionInteractor: pairingWebExtensionInteractor(),
            secret: secret
        )
    }
    
    func pushNotificationPermissionModuleInteractor() -> PushNotificationPermissionModuleInteracting {
        PushNotificationPermissionModuleInteractor(
            pushNotificationsRegistrationInteractor: pushNotificationRegistrationInteractor()
        )
    }
    
    func newsModuleInteractor() -> NewsModuleInteracting {
        NewsModuleInteractor(newsInteractor: newsInteractor())
    }
    
    func composeServiceCategorySelectionModuleInteractor(
        with selectedSection: SectionID?
    ) -> ComposeServiceCategorySelectionModuleInteracting {
        ComposeServiceCategorySelectionModuleInteractor(
            sectionInteractor: sectionInteractor(),
            selectedSection: selectedSection
        )
    }
    
    func aboutModuleInteractor() -> AboutModuleInteracting {
        AboutModuleInteractor(
            appInfoInteractor: appInfoInteractor(),
            registerDeviceInteractor: registerDeviceInteractor()
        )
    }
    
    func uploadLogsModuleInteractor(auditID: UUID?) -> UploadLogsModuleInteracting {
        UploadLogsModuleInteractor(logUploadingInteractor: logUploadingInteractor(), passedUUID: auditID)
    }
    
    func tokensModuleInteractor() -> TokensModuleInteracting {
        TokensModuleInteractor(
            appearanceInteractor: appearanceInteractor(),
            serviceDefinitionsInteractor: serviceDefinitionInteractor(),
            serviceInteractor: serviceListingInteractor(),
            serviceModifyInteractor: serviceModifyInteractor(),
            sortInteractor: sortInteractor(),
            tokenInteractor: tokenInteractor(),
            sectionInteractor: sectionInteractor(),
            notificationsInteractor: notificationInteractor(),
            cloudBackupInteractor: cloudBackupStateInteractor(listenerID: ""),
            cameraPermissionInteractor: cameraPermissionInteractor(),
            linkInteractor: linkInteractor(),
            widgetsInteractor: widgetsInteractor(),
            newCodeInteractor: newCodeInteractor()
        )
    }
    
    func mainModuleInteractor() -> MainModuleInteracting {
        MainModuleInteractor(
            logUploadingInteractor: logUploadingInteractor(),
            viewPathInteractor: viewPathInteractor(),
            cloudBackupStateInteractor: cloudBackupStateInteractor(listenerID: ""),
            fileInteractor: fileInteractor(),
            newVersionInteractor: newVersionInteractor(),
            networkStatusInteractor: networkStatusInteractor()
        )
    }
    
    func mainSplitModuleInteractor() -> MainSplitModuleInteracting {
        MainSplitModuleInteractor(
            viewPathInteractor: viewPathInteractor(),
            newsInteractor: newsInteractor(),
            linkInteractor: linkInteractor(),
            appearanceInteractor: appearanceInteractor()
        )
    }
    
    func mainMenuModuleInteractor() -> MainMenuModuleInteracting {
        MainMenuModuleInteractor(newsInteractor: newsInteractor())
    }
    
    func mainTabModuleInteractor() -> MainTabModuleInteracting {
        MainTabModuleInteractor(newsInteractor: newsInteractor())
    }
    
    func appearanceModuleInteractor() -> AppearanceModuleInteracting {
        AppearanceModuleInteractor(appearanceInteractor: appearanceInteractor())
    }
    
    func addingServiceMainModuleInteractor() -> AddingServiceMainModuleInteracting {
        AddingServiceMainModuleInteractor(
            cameraPermissionInteractor: cameraPermissionInteractor(),
            newCodeInteractor: newCodeInteractor(),
            pushNotificationPermission: pushNotificationRegistrationInteractor(),
            notificationInteractor: notificationInteractor()
        )
    }
    
    func addingServiceTokenModuleInteractor(serviceData: ServiceData) -> AddingServiceTokenModuleInteracting {
        AddingServiceTokenModuleInteractor(
            notificationsInteractor: notificationInteractor(),
            tokenInteractor: tokenInteractor(),
            serviceDefinitionInteractor: serviceDefinitionInteractor(),
            serviceData: serviceData
        )
    }
    
    func addingServiceManuallyModuleInteractor() -> AddingServiceManuallyModuleInteracting {
        AddingServiceManuallyModuleInteractor(
            serviceDatabase: serviceDefinitionInteractor()
        )
    }
}
