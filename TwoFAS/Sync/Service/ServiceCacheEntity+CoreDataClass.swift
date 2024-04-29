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

@objc(ServiceCacheEntity)
final class ServiceCacheEntity: NSManagedObject {
    @nonobjc private static let entityName = "ServiceCacheEntity"
    
    @nonobjc static func create(
        on context: NSManagedObjectContext,
        metadata: Data,
        name: String,
        secret: String,
        serviceTypeID: ServiceTypeID?,
        additionalInfo: String?,
        rawIssuer: String?,
        otpAuth: String?,
        creationDate: Date,
        modificationDate: Date,
        tokenPeriod: Int?,
        tokenLength: Int,
        badgeColor: String?,
        iconType: String,
        iconTypeID: IconTypeID,
        labelColor: String,
        labelTitle: String,
        sectionID: UUID?,
        sectionOrder: Int,
        algorithm: String,
        counter: Int?,
        tokenType: String,
        source: String
    ) {
        let service = NSEntityDescription.insertNewObject(
            forEntityName: entityName,
            into: context
        ) as! ServiceCacheEntity
        
        service.metadata = metadata
        service.name = name
        service.secret = secret
        service.serviceTypeID = serviceTypeID
        service.additionalInfo = additionalInfo
        service.rawIssuer = rawIssuer
        service.otpAuth = otpAuth
        service.creationDate = creationDate
        service.modificationDate = modificationDate
        if let tokenPeriod {
            service.tokenPeriod = NSNumber(value: tokenPeriod)
        }
        service.tokenLength = NSNumber(value: tokenLength)
        service.badgeColor = badgeColor
        service.iconTypeID = iconTypeID
        service.labelColor = labelColor
        service.labelTitle = labelTitle
        service.iconType = iconType
        service.sectionID = sectionID
        service.sectionOrder = sectionOrder
        service.algorithm = algorithm
        if let counter {
            service.counter = NSNumber(value: counter)
        }
        service.tokenType = tokenType
        service.source = source
    }
        
    @nonobjc static func listAll(on context: NSManagedObjectContext) -> [ServiceCacheEntity] {
        listItems(on: context)
    }

    @nonobjc static func delete(on context: NSManagedObjectContext, identifiedBy secret: String) {
        guard let service = findService(on: context, secret: secret) else { return }
        delete(on: context, serviceEntity: service)
    }
        
    @nonobjc static func findService(on context: NSManagedObjectContext, secret: String) -> ServiceCacheEntity? {
        let fetchRequest = ServiceCacheEntity.request()
        fetchRequest.predicate = NSPredicate(format: "secret == %@", secret)
        
        var list: [ServiceCacheEntity] = []
        do {
            list = try context.fetch(fetchRequest)
        } catch {
            let err = error as NSError
            Log(err.localizedDescription, module: .storage)
            return nil
        }
        
        // if something went wrong (wrong migration, some bugs) -> remove duplicated entries instead of:
        if list.count > 1 {
            let itemsForDeletition = list[1...]
            for item in itemsForDeletition {
                delete(on: context, serviceEntity: item)
            }
        }
        
        let item = list.first
        
        return item
    }
    
    // MARK: - Private
    
    @nonobjc private static func listItems(on context: NSManagedObjectContext) -> [ServiceCacheEntity] {
        let fetchRequest = ServiceCacheEntity.request()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(ServiceCacheEntity.sectionID), ascending: true),
            NSSortDescriptor(key: #keyPath(ServiceCacheEntity.sectionOrder), ascending: true)
        ]
        
        var list: [ServiceCacheEntity] = []
        
        do {
            list = try context.fetch(fetchRequest)
        } catch {
            let err = error as NSError
            Log(err.localizedDescription, module: .storage)
            return []
        }
        
        return list
    }
    
    @nonobjc private static func delete(on context: NSManagedObjectContext, serviceEntity: ServiceCacheEntity) {
        context.delete(serviceEntity)
    }
}
