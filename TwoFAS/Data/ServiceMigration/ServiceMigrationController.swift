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
#if os(iOS)
import Storage
import Common
import Content
#elseif os(watchOS)
import CommonWatch
import ContentWatch
#endif

// Migrate to interactor when main architecture will be refactored
public final class ServiceMigrationController {
    private let migrationKey = "ServiceMigrationController"
    private let storageRepository: StorageRepository
    private var serviceDatabase: ServiceDefinitionDatabase?
    
    #if os(watchOS)
    public var serviceNameTranslation: String?
    #endif
    
    public init(storageRepository: StorageRepository) {
        self.storageRepository = storageRepository
    }
    
    public func migrateIfNeeded() {
        guard
            let currentVersionString = Bundle.main.appVersion,
            let currentVersion = currentVersionString.splitVersion()
        else { return }
        
        let userDefaults = UserDefaults()
        let savedVersionString = userDefaults.string(forKey: migrationKey)?.splitVersion()
        
        if let sv = savedVersionString {
            if sv < currentVersion {
                #if os(iOS)
                AppEventLog(.appUpdate(currentVersionString))
                #endif
                userDefaults.set(currentVersionString, forKey: migrationKey)
                userDefaults.synchronize()
            } else {
                Log("Already migrated for this version")
                return
            }
        } else {
            userDefaults.set(currentVersionString, forKey: migrationKey)
            userDefaults.synchronize()
        }

        migrateServicesByIssuer()
    }
        
    private func migrateServicesByIssuer() {
        serviceDatabase = ServiceDefinitionDatabaseImpl()
        Log("Attempting to migrate to new services by issuer")
        
        let servicesForMigration = storageRepository.findAllUnknownServices()
        guard servicesForMigration.count > 0 else { Log("Nothing to migrate using issuer value"); return }
        
        Log("Count of services for migration: \(servicesForMigration.count)")
        Log("Services for migration:\n\n\(servicesForMigration)", save: false)
        
        for s in servicesForMigration {
            guard
                let rawIssuer = s.rawIssuer,
                let def = serviceDatabase?.findService(using: rawIssuer)
            else { continue }
            
            let name: String = {
                #if os(iOS)
                if s.name.contains(MainRepositoryImpl.shared.serviceNameTranslation) {
                    return def.name
                }
                #elseif os(watchOS)
                if let serviceNameTranslation, s.name.contains(serviceNameTranslation) {
                    return def.name
                }
                #endif
                
                return s.name
            }()
            
            let brandIcon: IconTypeID = {
                def.iconTypeID
            }()
            
            storageRepository.updateService(
                s,
                name: name,
                additionalInfo: s.additionalInfo,
                badgeColor: s.badgeColor,
                iconType: s.iconType,
                iconTypeID: brandIcon,
                labelColor: s.labelColor,
                labelTitle: s.labelTitle,
                counter: s.counter
            )
            Log("Service \(rawIssuer) successfuly updated to \(def)")
        }
    }
}

private extension Bundle {
    var appVersion: String? { object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String }
}
