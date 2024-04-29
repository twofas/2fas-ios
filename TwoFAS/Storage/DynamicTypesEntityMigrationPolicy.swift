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
import Content
#elseif os(watchOS)
import CommonWatch
import ContentWatch
#endif

@objc(DynamicTypesEntityMigrationPolicy)
final class DynamicTypesEntityMigrationPolicy: NSEntityMigrationPolicy {
    private var secrets = [String]()
    private let entityName = "ServiceEntity"
    
    private enum Keys: String {
        case additionalInfo
        case algorithm
        case badgeColor
        case counter
        case creationDate
        case iconType
        case isTrashed
        case labelColor
        case labelTitle
        case modificationDate
        case name
        case otpAuth
        case rawIssuer
        case secret
        case tokenLength
        case tokenPeriod
        case sectionID
        case sectionOrder
        case serviceTypeID
        case source
        case tokenType
        case trashingDate
        case iconTypeID
        // migrated
        case serviceType
        case secretLength
        case secretPeriod
        case brandIcon
    }
    
    private let serviceDefinitionDatabase: ServiceDefinitionDatabase = ServiceDefinitionDatabaseImpl()
    
    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        guard sInstance.entity.name == entityName else { return }

        Log("Migration - createDestinationInstances", module: .storage, save: false)

        guard let name = sInstance.primitiveValue(forKey: Keys.name.rawValue) as? String,
              let secret = sInstance.primitiveValue(forKey: Keys.secret.rawValue) as? String,
              let serviceType = sInstance.primitiveValue(forKey: Keys.serviceType.rawValue) as? String,
              !secret.isEmpty else {
            Log("Migration of entity wasn't successful becase of missing data", module: .storage, save: false)
            return
        }

        let additionalInfo = sInstance.primitiveValue(forKey: Keys.additionalInfo.rawValue) as? String
        let algorithm = sInstance.primitiveValue(forKey: Keys.algorithm.rawValue) as? String
        let badgeColor = sInstance.primitiveValue(forKey: Keys.badgeColor.rawValue) as? String
        let brandIcon = sInstance.primitiveValue(forKey: Keys.brandIcon.rawValue) as? String
        let counter = sInstance.primitiveValue(forKey: Keys.counter.rawValue) as? Int
        let creationDate = sInstance.primitiveValue(forKey: Keys.creationDate.rawValue) as? Date
        let iconType = sInstance.primitiveValue(forKey: Keys.iconType.rawValue) as? String
        let isTrashed = sInstance.primitiveValue(forKey: Keys.isTrashed.rawValue) as? NSNumber
        let labelColor = sInstance.primitiveValue(forKey: Keys.labelColor.rawValue) as? String
        let labelTitle = sInstance.primitiveValue(forKey: Keys.labelTitle.rawValue) as? String
        let modificationDate = sInstance.primitiveValue(forKey: Keys.modificationDate.rawValue) as? Date
        let secretLength = sInstance.primitiveValue(forKey: Keys.secretLength.rawValue) as? Int
        let secretPeriod = sInstance.primitiveValue(forKey: Keys.secretPeriod.rawValue) as? Int
        let rawIssuer = sInstance.primitiveValue(forKey: Keys.rawIssuer.rawValue) as? String
        let sectionID = sInstance.primitiveValue(forKey: Keys.sectionID.rawValue) as? UUID
        let sectionOrder = sInstance.primitiveValue(forKey: Keys.sectionOrder.rawValue) as? Int
        let tokenType = sInstance.primitiveValue(forKey: Keys.tokenType.rawValue) as? String
        let trashingDate = sInstance.primitiveValue(forKey: Keys.trashingDate.rawValue) as? Date

        Log("Migrating EncryptSecretEntityMigrationPolicy -> \(name)", module: .storage, save: false)

        guard !secrets.contains(secret) else {
            // swiftlint:disable line_length
            Log("Migrating EncryptSecretEntityMigrationPolicy -> Skipping duplicated secret!", module: .storage, save: false)
            // swiftlint:enable line_length
            return
        }

        Log("Migrating EncryptSecretEntityMigrationPolicy -> creating encrypted secret", module: .storage, save: false)

        secrets.append(secret)
        
        let date = Date()
        
        let serviceTypeID: ServiceTypeID? = { () -> ServiceTypeID? in
            guard
                let serviceTypeID = serviceDefinitionDatabase.findLegacyService(using: serviceType)
            else { return nil }
            return serviceTypeID
        }()
        
        let brandIconTypeID: IconTypeID = {
            let icon = serviceDefinitionDatabase.findLegacyIcon(using: serviceType)
            if let brandIcon, let iconType, let iconTypeValue = IconType(rawValue: iconType),
               let iconTypeID = serviceDefinitionDatabase.findLegacyIcon(using: brandIcon), iconTypeValue == .brand {
                return iconTypeID
            }
            return icon ?? .default
        }()
        
        let serviceSource: ServiceSource = {
            if serviceType == "manual" {
                return .manual
            }
            return .link
        }()
        
        let iconTypeValue: IconType = {
            if let iconType, let iconTypeValue = IconType(rawValue: iconType) {
                return iconTypeValue
            }
            return .brand
        }()
        
        let labelColorValue: TintColor = {
            guard let labelColor, let color = TintColor(rawValue: labelColor)
            else { return .lightBlue }
            return color
        }()
        
        let labelTitleValue: String = {
            if let labelTitle {
                return labelTitle
            }
            if let serviceTypeID,
               let serviceDef = serviceDefinitionDatabase.service(using: serviceTypeID) {
                return serviceDef.name.twoLetters
            }
            return ServiceDefinition.defaultLabelTitleTwoLetters
        }()
        
        let newEntity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: manager.destinationContext)
        newEntity.setValue(additionalInfo, forKey: Keys.additionalInfo.rawValue)
        newEntity.setValue(algorithm ?? Algorithm.SHA1.rawValue, forKey: Keys.algorithm.rawValue)
        newEntity.setValue(badgeColor, forKey: Keys.badgeColor.rawValue)
        newEntity.setValue(brandIconTypeID, forKey: Keys.iconTypeID.rawValue)
        newEntity.setValue(counter, forKey: Keys.counter.rawValue)
        newEntity.setValue(creationDate ?? date, forKey: Keys.creationDate.rawValue)
        newEntity.setValue(iconTypeValue.rawValue, forKey: Keys.iconType.rawValue)
        newEntity.setValue(isTrashed ?? NSNumber(value: false), forKey: Keys.isTrashed.rawValue)
        newEntity.setValue(labelColorValue.rawValue, forKey: Keys.labelColor.rawValue)
        newEntity.setValue(labelTitleValue, forKey: Keys.labelTitle.rawValue)
        newEntity.setValue(modificationDate ?? date, forKey: Keys.modificationDate.rawValue)
        newEntity.setValue(name, forKey: Keys.name.rawValue)
        newEntity.setValue(nil, forKey: Keys.otpAuth.rawValue)
        newEntity.setValue(rawIssuer, forKey: Keys.rawIssuer.rawValue)
        newEntity.setValue(secret, forKey: Keys.secret.rawValue)
        newEntity.setValue(secretLength ?? Digits.digits6.rawValue, forKey: Keys.tokenLength.rawValue)
        newEntity.setValue(secretPeriod, forKey: Keys.tokenPeriod.rawValue)
        newEntity.setValue(sectionID, forKey: Keys.sectionID.rawValue)
        newEntity.setValue(sectionOrder, forKey: Keys.sectionOrder.rawValue)
        newEntity.setValue(serviceTypeID, forKey: Keys.serviceTypeID.rawValue)
        newEntity.setValue(serviceSource.rawValue, forKey: Keys.source.rawValue)
        newEntity.setValue(tokenType ?? TokenType.totp.rawValue, forKey: Keys.tokenType.rawValue)
        newEntity.setValue(trashingDate, forKey: Keys.trashingDate.rawValue)
    }
}
