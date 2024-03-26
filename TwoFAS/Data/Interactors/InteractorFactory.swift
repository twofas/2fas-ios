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

public final class InteractorFactory {
    public static let shared = InteractorFactory()
    
    public func rootInteractor() -> RootInteracting {
        RootInteractor(
            mainRepository: MainRepositoryImpl.shared,
            camera: cameraPermissionInteractor(),
            push: pushNotificationRegistrationInteractor()
        )
    }
    
    public func trashingServiceInteractor() -> TrashingServiceInteracting {
        TrashingServiceInteractor(
            mainRepository: MainRepositoryImpl.shared,
            webExtensionAuthInteractor: webExtensionAuthInteractor()
        )
    }
    
    public func serviceModifyInteractor() -> ServiceModifyInteracting {
        ServiceModifyInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func newVersionInteractor() -> NewVersionInteracting {
        NewVersionInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func newCodeInteractor() -> NewCodeInteracting {
        NewCodeInteractor(
            interactorModify: serviceModifyInteractor(),
            interactorTrashed: trashingServiceInteractor(),
            serviceDefinition: serviceDefinitionInteractor()
        )
    }
    
    public func sortInteractor() -> SortInteracting {
        SortInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func webExtensionEncryptionInteractor() -> WebExtensionEncryptionInteracting {
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
    
    public func webExtensionDeviceNameInteractor() -> WebExtensionDeviceNameInteracting {
        WebExtensionDeviceNameInteractor(
            local: webExtensionLocalDeviceNameInteractor(), remote: webExtensionRemoteDeviceNameInteractor()
        )
    }
    
    public func pushNotificationRegistrationInteractor() -> PushNotificationRegistrationInteracting {
        PushNotificationRegistrationInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func registerDeviceInteractor() -> RegisterDeviceInteracting {
        RegisterDeviceInteractor(
            mainRepository: MainRepositoryImpl.shared,
            localName: webExtensionLocalDeviceNameInteractor()
        )
    }
    
    public func pairingWebExtensionInteractor() -> PairingWebExtensionInteracting {
        PairingWebExtensionInteractor(
            mainRepository: MainRepositoryImpl.shared,
            localName: webExtensionLocalDeviceNameInteractor(),
            encryption: webExtensionEncryptionInteractor()
        )
    }
    
    public func webExtensionAuthInteractor() -> WebExtensionAuthInteracting {
        WebExtensionAuthInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func serviceListingInteractor() -> ServiceListingInteracting {
        ServiceListingInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func tokenGeneratorInteractor() -> TokenGeneratorInteracting {
        TokenGeneratorInteractor(
            mainRepository: MainRepositoryImpl.shared,
            serviceInteractor: serviceModifyInteractor()
        )
    }
    
    private func listNewsNetworkInteractor() -> ListNewsNetworkInteracting {
        ListNewsNetworkInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func listNewsStorageInteractor() -> ListNewsStorageInteracting {
        ListNewsStorageInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func sectionInteractor() -> SectionInteracting {
        SectionInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func notificationInteractor() -> NotificationInteracting {
        NotificationInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func linkInteractor() -> LinkInteracting {
        LinkInteractor(mainRepository: MainRepositoryImpl.shared, interactorNew: newCodeInteractor())
    }
    
    public func protectionInteractor() -> ProtectionInteracting {
        ProtectionInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func timerInteractor() -> TimerInteracting {
        TimerInteractor()
    }
    
    public func appLockStateInteractor() -> AppLockStateInteracting {
        AppLockStateInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func serviceDefinitionInteractor() -> ServiceDefinitionInteracting {
        ServiceDefinitionInteractor(mainRepository: MainRepositoryImpl.shared)
    }

    public func cameraPermissionInteractor() -> CameraPermissionInteracting {
        CameraPermissionInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func widgetsInteractor() -> WidgetsInteracting {
        WidgetsInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func appearanceInteractor() -> AppearanceInteracting {
        AppearanceInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func cloudBackupStateInteractor(listenerID: String) -> CloudBackupStateInteracting {
        CloudBackupStateInteractor(
            mainRepository: MainRepositoryImpl.shared,
            listenerID: listenerID
        )
    }
    
    public func exportToFileInteractor() -> ExportToFileInteracting {
        ExportToFileInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func scanInteractor() -> ScanInteracting {
        ScanInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func iconInteractor() -> IconInteracting {
        IconInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func advancedAlertInteractor() -> AdvancedAlertInteracting {
        AdvancedAlertInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func pushNotificationInteractor() -> PushNotificationInteracting {
        PushNotificationInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func appInfoInteractor() -> AppInfoInteracting {
        AppInfoInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func logUploadingInteractor() -> LogUploadingInteracting {
        LogUploadingInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func tokenInteractor() -> TokenInteracting {
        TokenInteractor(
            mainRepository: MainRepositoryImpl.shared,
            serviceInteractor: serviceModifyInteractor()
        )
    }
    
    public func viewPathInteractor() -> ViewPathIteracting {
        ViewPathInteractor(mainRepository: MainRepositoryImpl.shared)
	}

    public func networkStatusInteractor() -> NetworkStatusInteracting {
        NetworkStatusInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func fileInteractor() -> FileInteracting {
        FileIteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func newsInteractor() -> NewsInteracting {
        NewsInteractor(
            network: listNewsNetworkInteractor(),
            storage: listNewsStorageInteractor(),
            mainRepository: MainRepositoryImpl.shared
        )
    }
    
    public func guideInteractor() -> GuideInteracting {
        GuideInteractor(
            mainRepository: MainRepositoryImpl.shared,
            serviceDefinitionInteractor: serviceDefinitionInteractor()
        )
    }
    
    public func importFromFileInteractor() -> ImportFromFileInteracting {
        ImportFromFileInteractor(
            mainRepository: MainRepositoryImpl.shared,
            serviceDefinitionInteractor: serviceDefinitionInteractor(),
            modifyInteractor: serviceModifyInteractor()
        )
    }
    
    public func loginInteractor() -> LoginInteracting {
        LoginInteractor(security: MainRepositoryImpl.shared.security)
    }
    
    public func appStateInteractor() -> AppStateInteracting {
        AppStateInteractor(mainRepository: MainRepositoryImpl.shared)
    }
    
    public func mdmInteractor() -> MDMInteracting {
        MDMInteractor(
            mainRepository: MainRepositoryImpl.shared,
            pairingInteractor: pairingWebExtensionInteractor(),
            cloudBackupStateInteractor: cloudBackupStateInteractor(listenerID: "MDMInteractor")
        )
    }
    
    public func localNotificationStateInteractor() -> LocalNotificationStateInteracting {
        LocalNotificationStateInteractor(
            mainRepository: MainRepositoryImpl.shared,
            serviceListingInteractor: serviceListingInteractor(),
            cloudBackup: cloudBackupStateInteractor(listenerID: "localNotificationStateInteractor"),
            pairingDeviceInteractor: pairingWebExtensionInteractor(),
            mdmInteractor: mdmInteractor()
        )
    }
    
    public func localNotificationFetchInteractor() -> LocalNotificationFetchInteracting {
        LocalNotificationFetchInteractor(
            mainRepository: MainRepositoryImpl.shared
        )
    }
}
