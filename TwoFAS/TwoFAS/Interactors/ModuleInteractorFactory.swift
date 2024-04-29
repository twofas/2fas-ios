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
import Data
import Common

final class ModuleInteractorFactory {
    static let shared = ModuleInteractorFactory()
    
    private init() {}
    
    func rootModuleInteractor() -> RootModuleInteracting {
        RootModuleInteractor(
            rootInteractor: InteractorFactory.shared.rootInteractor(),
            linkInteractor: InteractorFactory.shared.linkInteractor(),
            fileInteractor: InteractorFactory.shared.fileInteractor(),
            registerDeviceInteractor: InteractorFactory.shared.registerDeviceInteractor(),
            appStateInteractor: InteractorFactory.shared.appStateInteractor(),
            notificationInteractor: InteractorFactory.shared.notificationInteractor(),
            widgetsInteractor: InteractorFactory.shared.widgetsInteractor(),
            localNotificationStateInteractor: InteractorFactory.shared.localNotificationStateInteractor()
        )
    }
    
    func settingsModuleInteractor() -> SettingsModuleInteracting {
        SettingsModuleInteractor()
    }
    
    func settingsMenuModuleInteractor() -> SettingsMenuModuleInteracting {
        SettingsMenuModuleInteractor(
            widgetsInteractor: InteractorFactory.shared.widgetsInteractor(),
            pushNotifications: InteractorFactory.shared.pushNotificationRegistrationInteractor(),
            protectionInteractor: InteractorFactory.shared.protectionInteractor(),
            networkStatusInteractor: InteractorFactory.shared.networkStatusInteractor(),
            pairingDeviceInteractor: InteractorFactory.shared.pairingWebExtensionInteractor(),
            mdmInteractor: InteractorFactory.shared.mdmInteractor()
        )
    }
    
    func backupMenuModuleInteractor() -> BackupMenuModuleInteracting {
        BackupMenuModuleInteractor(
            serviceListingInteractor: InteractorFactory.shared.serviceListingInteractor(),
            cloudBackup: InteractorFactory.shared.cloudBackupStateInteractor(listenerID: "BackupMenuModuleInteractor"),
            mdmInteractor: InteractorFactory.shared.mdmInteractor()
        )
    }
    
    func backupDeleteModuleInteractor() -> BackupDeleteModuleInteracting {
        BackupDeleteModuleInteractor(
            cloudBackupStateInteractor: InteractorFactory.shared.cloudBackupStateInteractor(listenerID: "")
        )
    }
    
    func widgetWarningModuleInteractor() -> WidgetWarningModuleInteracting {
        WidgetWarningModuleInteractor(
            widgetInteractor: InteractorFactory.shared.widgetsInteractor()
        )
    }
    
    func importerEnterPasswordModuleInteractor(data: ExchangeDataFormat) -> ImporterEnterPasswordModuleInteracting {
        ImporterEnterPasswordModuleInteractor(
            importInteractor: InteractorFactory.shared.importFromFileInteractor(),
            data: data
        )
    }
    
    func importerOpenFileModuleInteractor(url: URL?) -> ImporterOpenFileModuleInteracting {
        ImporterOpenFileModuleInteractor(
            importInteractor: InteractorFactory.shared.importFromFileInteractor(),
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
            importInteractor: InteractorFactory.shared.importFromFileInteractor(),
            countNew: countNew,
            countTotal: countTotal,
            sections: sections,
            services: services
        )
    }
    
    func exporterMainScreenModuleInteractor() -> ExporterMainScreenModuleInteracting {
        ExporterMainScreenModuleInteractor(
            protectionInteractor: InteractorFactory.shared.protectionInteractor(),
            exportToFileInteractor: InteractorFactory.shared.exportToFileInteractor()
        )
    }
    
    func exporterPasswordProtectionModuleInteractor() -> ExporterPasswordProtectionModuleInteracting {
        ExporterPasswordProtectionModuleInteractor(
            protectionInteractor: InteractorFactory.shared.protectionInteractor(),
            exportToFileInteractor: InteractorFactory.shared.exportToFileInteractor()
        )
    }
    
    func exporterPINModuleInteractor() -> ExporterPINModuleInteracting {
        ExporterPINModuleInteractor(
            protectionInteractor: InteractorFactory.shared.protectionInteractor(),
            exportToFileInteractor: InteractorFactory.shared.exportToFileInteractor()
        )
    }
    
    func appSecurityModuleInteractor() -> AppSecurityModuleInteracting {
        AppSecurityModuleInteractor(
            protectionInteractor: InteractorFactory.shared.protectionInteractor(),
            appLockStateInteractor: InteractorFactory.shared.appLockStateInteractor(),
            mdmInteractor: InteractorFactory.shared.mdmInteractor()
        )
    }
    
    func appLockModuleInteractor() -> AppLockModuleInteracting {
        AppLockModuleInteractor(
            appLockInteractor: InteractorFactory.shared.appLockStateInteractor(),
            mdmInteractor: InteractorFactory.shared.mdmInteractor()
        )
    }
    
    func verifyPINModuleInteractor() -> VerifyPINModuleInteracting {
        VerifyPINModuleInteractor(
            protectionInteractor: InteractorFactory.shared.protectionInteractor(),
            timerInteractor: InteractorFactory.shared.timerInteractor(),
            appLockStateInteractor: InteractorFactory.shared.appLockStateInteractor()
        )
    }
    
    func newPINModuleInteractor(lockNavigation: Bool) -> NewPINModuleInteracting {
        NewPINModuleInteractor(lockNavigation: lockNavigation)
    }
    
    func trashModuleInteractor() -> TrashModuleInteracting {
        TrashModuleInteractor(
            trashingServiceInteractor: InteractorFactory.shared.trashingServiceInteractor()
        )
    }
    
    func deleteServiceInteractor() -> DeleteServiceInteracting {
        DeleteServiceInteractor(trashingServiceInteractor: InteractorFactory.shared.trashingServiceInteractor())
    }
    
    func trashServiceInteractor() -> TrashServiceInteracting {
        TrashServiceInteractor(trashingServiceInteractor: InteractorFactory.shared.trashingServiceInteractor())
    }
    
    func cameraScannerModuleInteractor() -> CameraScannerModuleInteracting {
        CameraScannerModuleInteractor(
            newCodeInteractor: InteractorFactory.shared.newCodeInteractor(),
            pushNotificationPermission: InteractorFactory.shared.pushNotificationRegistrationInteractor(),
            cameraPermissionInteractor: InteractorFactory.shared.cameraPermissionInteractor()
        )
    }
    
    func selectFromGalleryModuleInteractor() -> SelectFromGalleryModuleInteracting {
        SelectFromGalleryModuleInteractor(
            scanInteractor: InteractorFactory.shared.scanInteractor(),
            newCodeInteractor: InteractorFactory.shared.newCodeInteractor()
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
            iconInteractor: InteractorFactory.shared.iconInteractor(),
            serviceDefinitionInteractor: InteractorFactory.shared.serviceDefinitionInteractor(),
            defaultIcon: defaultIcon,
            selectedIcon: selectedIcon
        )
    }
    
    func composeServiceModuleInteractor(secret: Secret?) -> ComposeServiceModuleInteracting {
        ComposeServiceModuleInteractor(
            modifyInteractor: InteractorFactory.shared.serviceModifyInteractor(),
            trashingServiceInteractor: InteractorFactory.shared.trashingServiceInteractor(),
            protectionInteractor: InteractorFactory.shared.protectionInteractor(),
            secret: secret,
            webExtensionAuthInteractor: InteractorFactory.shared.webExtensionAuthInteractor(),
            sectionInteractor: InteractorFactory.shared.sectionInteractor(),
            notificationsInteractor: InteractorFactory.shared.notificationInteractor(),
            serviceDefinitionInteractor: InteractorFactory.shared.serviceDefinitionInteractor(),
            advancedAlertInteractor: InteractorFactory.shared.advancedAlertInteractor(),
            mdmInteractor: InteractorFactory.shared.mdmInteractor()
        )
    }
    
    func composeServiceAdvancedSummaryModuleInteractor(
        settings: ComposeServiceAdvancedSettings
    ) -> ComposeServiceAdvancedSummaryModuleInteracting {
        ComposeServiceAdvancedSummaryModuleInteractor(
            notificationInteractor: InteractorFactory.shared.notificationInteractor(),
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
            cameraPermissionInteractor: InteractorFactory.shared.cameraPermissionInteractor(),
            pushNotificationRegistrationInteractor: InteractorFactory.shared.pushNotificationRegistrationInteractor()
        )
    }
    
    func browserExtensionPairingModuleInteractor(extensionID: ExtensionID) -> BrowserExtensionPairingModuleInteracting {
        BrowserExtensionPairingModuleInteractor(
            webPairing: InteractorFactory.shared.pairingWebExtensionInteractor(),
            registerDeviceInteractor: InteractorFactory.shared.registerDeviceInteractor(),
            extensionID: extensionID
        )
    }
    
    func browserExtensionMainModuleInteractor() -> BrowserExtensionMainModuleInteracting {
        BrowserExtensionMainModuleInteractor(
            pairingDeviceInteractor: InteractorFactory.shared.pairingWebExtensionInteractor(),
            deviceNameInteractor: InteractorFactory.shared.webExtensionDeviceNameInteractor(),
            cameraPermissionInteractor: InteractorFactory.shared.cameraPermissionInteractor()
        )
    }
    
    func selectServiceModuleInteractor() -> SelectServiceModuleInteracting {
        SelectServiceModuleInteractor(
            listingInteractor: InteractorFactory.shared.serviceListingInteractor(),
            serviceDefinitionInteractor: InteractorFactory.shared.serviceDefinitionInteractor(),
            sortInteractor: InteractorFactory.shared.sortInteractor(),
            pairedBrowsers: InteractorFactory.shared.pairingWebExtensionInteractor()
        )
    }
    
    func authRequestsModuleInteractor() -> AuthRequestsModuleInteracting {
        AuthRequestsModuleInteractor(
            webExtensionAuthInteractor: InteractorFactory.shared.webExtensionAuthInteractor(),
            tokenGeneratorInteractor: InteractorFactory.shared.tokenGeneratorInteractor(),
            pairingWebExtensionInteractor: InteractorFactory.shared.pairingWebExtensionInteractor(),
            webExtensionEncryptionInteractor: InteractorFactory.shared.webExtensionEncryptionInteractor(),
            pushNotificationInteractor: InteractorFactory.shared.pushNotificationInteractor()
        )
    }
    
    func composeServiceWebExtensionModuleInteractor(secret: String) -> ComposeServiceWebExtensionModuleInteracting {
        ComposeServiceWebExtensionModuleInteractor(
            webExtensionAuthInteracting: InteractorFactory.shared.webExtensionAuthInteractor(),
            pairingWebExtensionInteractor: InteractorFactory.shared.pairingWebExtensionInteractor(),
            secret: secret
        )
    }
    
    func pushNotificationPermissionModuleInteractor() -> PushNotificationPermissionModuleInteracting {
        PushNotificationPermissionModuleInteractor(
            pushNotificationsRegistrationInteractor: InteractorFactory.shared.pushNotificationRegistrationInteractor()
        )
    }
    
    func newsModuleInteractor() -> NewsModuleInteracting {
        NewsModuleInteractor(
            newsInteractor: InteractorFactory.shared.newsInteractor(),
            localNotificationFetchInteractor: InteractorFactory.shared.localNotificationFetchInteractor()
        )
    }
    
    func composeServiceCategorySelectionModuleInteractor(
        with selectedSection: SectionID?
    ) -> ComposeServiceCategorySelectionModuleInteracting {
        ComposeServiceCategorySelectionModuleInteractor(
            sectionInteractor: InteractorFactory.shared.sectionInteractor(),
            selectedSection: selectedSection
        )
    }
    
    func aboutModuleInteractor() -> AboutModuleInteracting {
        AboutModuleInteractor(
            appInfoInteractor: InteractorFactory.shared.appInfoInteractor(),
            registerDeviceInteractor: InteractorFactory.shared.registerDeviceInteractor()
        )
    }
    
    func uploadLogsModuleInteractor(auditID: UUID?) -> UploadLogsModuleInteracting {
        UploadLogsModuleInteractor(
            logUploadingInteractor: InteractorFactory.shared.logUploadingInteractor(),
            passedUUID: auditID
        )
    }
    
    func tokensModuleInteractor() -> TokensModuleInteracting {
        TokensModuleInteractor(
            appearanceInteractor: InteractorFactory.shared.appearanceInteractor(),
            serviceDefinitionsInteractor: InteractorFactory.shared.serviceDefinitionInteractor(),
            serviceInteractor: InteractorFactory.shared.serviceListingInteractor(),
            serviceModifyInteractor: InteractorFactory.shared.serviceModifyInteractor(),
            sortInteractor: InteractorFactory.shared.sortInteractor(),
            tokenInteractor: InteractorFactory.shared.tokenInteractor(),
            sectionInteractor: InteractorFactory.shared.sectionInteractor(),
            notificationsInteractor: InteractorFactory.shared.notificationInteractor(),
            cloudBackupInteractor: InteractorFactory.shared.cloudBackupStateInteractor(listenerID: ""),
            cameraPermissionInteractor: InteractorFactory.shared.cameraPermissionInteractor(),
            linkInteractor: InteractorFactory.shared.linkInteractor(),
            widgetsInteractor: InteractorFactory.shared.widgetsInteractor(),
            newCodeInteractor: InteractorFactory.shared.newCodeInteractor(),
            newsInteractor: InteractorFactory.shared.newsInteractor(),
            rootInteractor: InteractorFactory.shared.rootInteractor(),
            localNotificationFetchInteractor: InteractorFactory.shared.localNotificationFetchInteractor()
        )
    }
    
    func mainModuleInteractor() -> MainModuleInteracting {
        MainModuleInteractor(
            logUploadingInteractor: InteractorFactory.shared.logUploadingInteractor(),
            viewPathInteractor: InteractorFactory.shared.viewPathInteractor(),
            cloudBackupStateInteractor: InteractorFactory.shared.cloudBackupStateInteractor(listenerID: ""),
            fileInteractor: InteractorFactory.shared.fileInteractor(),
            newVersionInteractor: InteractorFactory.shared.newVersionInteractor(),
            networkStatusInteractor: InteractorFactory.shared.networkStatusInteractor(),
            appInfoInteractor: InteractorFactory.shared.appInfoInteractor(),
            rootInteractor: InteractorFactory.shared.rootInteractor(),
            mdmInteractor: InteractorFactory.shared.mdmInteractor(),
            protectionInteractor: InteractorFactory.shared.protectionInteractor()
        )
    }
    
    func mainSplitModuleInteractor() -> MainSplitModuleInteracting {
        MainSplitModuleInteractor(
            viewPathInteractor: InteractorFactory.shared.viewPathInteractor(),
            linkInteractor: InteractorFactory.shared.linkInteractor(),
            appearanceInteractor: InteractorFactory.shared.appearanceInteractor(),
            appStateInteractor: InteractorFactory.shared.appStateInteractor()
        )
    }
    
    func appearanceModuleInteractor() -> AppearanceModuleInteracting {
        AppearanceModuleInteractor(appearanceInteractor: InteractorFactory.shared.appearanceInteractor())
    }
    
    func addingServiceMainModuleInteractor() -> AddingServiceMainModuleInteracting {
        AddingServiceMainModuleInteractor(
            cameraPermissionInteractor: InteractorFactory.shared.cameraPermissionInteractor(),
            newCodeInteractor: InteractorFactory.shared.newCodeInteractor(),
            pushNotificationPermission: InteractorFactory.shared.pushNotificationRegistrationInteractor(),
            notificationInteractor: InteractorFactory.shared.notificationInteractor()
        )
    }
    
    func addingServiceTokenModuleInteractor(serviceData: ServiceData) -> AddingServiceTokenModuleInteracting {
        AddingServiceTokenModuleInteractor(
            notificationsInteractor: InteractorFactory.shared.notificationInteractor(),
            tokenInteractor: InteractorFactory.shared.tokenInteractor(),
            serviceDefinitionInteractor: InteractorFactory.shared.serviceDefinitionInteractor(),
            serviceData: serviceData
        )
    }
    
    func addingServiceManuallyModuleInteractor() -> AddingServiceManuallyModuleInteracting {
        AddingServiceManuallyModuleInteractor(
            serviceDatabase: InteractorFactory.shared.serviceDefinitionInteractor(),
            serviceListingInteractor: InteractorFactory.shared.serviceListingInteractor(),
            serviceModifyInteractor: InteractorFactory.shared.serviceModifyInteractor()
        )
    }
    
    func guideSelectorModuleInteractor() -> GuideSelectorModuleInteracting {
        GuideSelectorModuleInteractor(
            guideInteractor: InteractorFactory.shared.guideInteractor()
        )
    }
    
    func loginModuleInteractor() -> LoginModuleInteracting {
        LoginModuleInteractor(
            loginInteractor: InteractorFactory.shared.loginInteractor(),
            appLockStateInteractor: InteractorFactory.shared.appLockStateInteractor()
        )
    }
    
    func introductionModuleInteractor() -> IntroductionModuleInteracting {
        IntroductionModuleInteractor(rootInteractor: InteractorFactory.shared.rootInteractor())
    }
}
