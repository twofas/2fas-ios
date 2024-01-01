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
import Data

protocol BackupMenuModuleInteracting: AnyObject {
    func startMonitoring()
    func stopMonitoring()
    
    var isBackupOn: Bool { get }
    var exportEnabled: Bool { get }
    var isBackupAvailable: Bool { get }
    var isCloudBackupConnected: Bool { get }
    var reload: Callback? { get set }
    var error: CloudState.NotAvailableReason? { get }
    
    func toggleBackup()
    func clearBackup()
}

final class BackupMenuModuleInteractor {
    private let serviceListingInteractor: ServiceListingInteracting
    private let cloudBackup: CloudBackupStateInteracting
    
    init(serviceListingInteractor: ServiceListingInteracting, cloudBackup: CloudBackupStateInteracting) {
        self.serviceListingInteractor = serviceListingInteractor
        self.cloudBackup = cloudBackup
    }
}

extension BackupMenuModuleInteractor: BackupMenuModuleInteracting {
    var reload: Callback? {
        get {
            cloudBackup.stateChanged
        }
        set {
            cloudBackup.stateChanged = newValue
        }
    }
    
    var error: CloudState.NotAvailableReason? {
        cloudBackup.error
    }
    
    var isBackupOn: Bool {
        cloudBackup.isBackupEnabled
    }
    
    var exportEnabled: Bool {
        serviceListingInteractor.hasServices
    }
    
    var isCloudBackupConnected: Bool {
        cloudBackup.isBackupEnabled
    }
    
    var isBackupAvailable: Bool {
        cloudBackup.isBackupAvailable
    }
    
    func startMonitoring() {
        cloudBackup.startMonitoring()
    }
    
    func stopMonitoring() {
        cloudBackup.stopMonitoring()
    }
    
    func toggleBackup() {
        cloudBackup.toggleBackup()
    }
    
    func clearBackup() {
        cloudBackup.clearBackup()
    }
}

private extension BackupMenuModuleInteractor {
    func enableCloudBackup() {
        cloudBackup.enableBackup()
    }
    
    func disableCloudBackup() {
        cloudBackup.disableBackup()
    }
}
