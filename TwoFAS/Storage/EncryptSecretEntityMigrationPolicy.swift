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
import CoreData
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

@objc(EncryptSecretEntityMigrationPolicy)
final class EncryptSecretEntityMigrationPolicy: NSEntityMigrationPolicy {
    private var secrets = [String]()
    private let entityName = "ServiceEntity"
    private enum Keys: String {
        case additionalInfo
        case creationDate
        case mobileSecret
        case mobileSecretID
        case modificationDate
        case name
        case order
        case rawIssuer
        case secret
        case serviceType
    }
    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        guard sInstance.entity.name == entityName else { return }
        
        Log("Migration - createDestinationInstances", module: .storage)
        
        guard let name = sInstance.primitiveValue(forKey: Keys.name.rawValue) as? String,
              let order = sInstance.primitiveValue(forKey: Keys.order.rawValue) as? Int32,
              let secret = sInstance.primitiveValue(forKey: Keys.secret.rawValue) as? String,
              let serviceType = sInstance.primitiveValue(forKey: Keys.serviceType.rawValue) as? String,
              !secret.isEmpty else {
            Log("Migration of entity wasn't successful becase of missing data", module: .storage)
            return
        }
        
        let additionalInfo = sInstance.primitiveValue(forKey: Keys.additionalInfo.rawValue) as? String?
        let mobileSecret = sInstance.primitiveValue(forKey: Keys.mobileSecret.rawValue) as? String?
        let mobileSecretId = sInstance.primitiveValue(forKey: Keys.mobileSecretID.rawValue) as? String?
        let rawIssuer = sInstance.primitiveValue(forKey: Keys.rawIssuer.rawValue) as? String?
        
        Log("Migrating EncryptSecretEntityMigrationPolicy -> \(name)", module: .storage)
        let secretEncrypted = secret.uppercased().encrypt()
        
        guard !secrets.contains(secretEncrypted) else {
            Log("Migrating EncryptSecretEntityMigrationPolicy -> Skipping duplicated secret!", module: .storage)
            return
        }
        
        Log("Migrating EncryptSecretEntityMigrationPolicy -> creating encrypted secret", module: .storage)
        Log("-> \(secretEncrypted) from \(secret)", module: .storage, save: false)
        
        secrets.append(secretEncrypted)
        
        // swiftlint:disable redundant_nil_coalescing
        let newEntity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: manager.destinationContext)
        newEntity.setValue(additionalInfo ?? nil, forKey: Keys.additionalInfo.rawValue)
        newEntity.setValue(nil, forKey: Keys.creationDate.rawValue)
        newEntity.setValue(mobileSecret ?? nil, forKey: Keys.mobileSecret.rawValue)
        newEntity.setValue(mobileSecretId ?? nil, forKey: Keys.mobileSecretID.rawValue)
        newEntity.setValue(nil, forKey: Keys.modificationDate.rawValue)
        newEntity.setValue(name, forKey: Keys.name.rawValue)
        newEntity.setValue(order, forKey: Keys.order.rawValue)
        newEntity.setValue(rawIssuer ?? nil, forKey: Keys.rawIssuer.rawValue)
        newEntity.setValue(secretEncrypted, forKey: Keys.secret.rawValue)
        newEntity.setValue(serviceType, forKey: Keys.serviceType.rawValue)
        // swiftlint:enable redundant_nil_coalescing
    }
}
