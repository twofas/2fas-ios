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
import Protection
#elseif os(watchOS)
import CommonWatch
import ProtectionWatch
#endif

final class ServiceHandler {
    private let coreDataStack: CoreDataStack
    
    var encryption: ExchangeFileEncryption?
    var embedded: String?
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func delete(identifiedBy identifier: String) {
        let identifier = identifier.decrypt()
        switch iCloudIdentifier.parse(identifier) {
        case .v2(let secret):
            ServiceCacheEntity.delete(on: coreDataStack.context, identifiedBy: secret.encrypt())
        case .long(let hash, let beginsWith):
            let list = ServiceCacheEntity.listAll(on: coreDataStack.context)
                .filter({ $0.secret.decrypt().hasPrefix(beginsWith) && $0.secret.count > Config.maxIdentifierLength })
                .filter({ iCloudIdentifier.hash(from: $0.secret.decrypt()).uppercased() == hash })
            guard let first = list.first, list.count == 1 else {
                Log("ServiceHandler - Can't find long identifier", severity: .error)
                return
            }
            ServiceCacheEntity.delete(on: coreDataStack.context, identifiedBy: first.secret)
        case .deprecated:
            Log("ServiceHandler - Can't find range in identifier", severity: .error)
            return
        }

        coreDataStack.save()
    }
    
    func delete(identifiedBy secrets: [String]) {
        secrets.forEach { sec in
            ServiceCacheEntity.delete(on: coreDataStack.context, identifiedBy: sec.encrypt())
        }
        coreDataStack.save()
    }
    
    func purge() {
        let list = listAll()
        delete(identifiedBy: list.map { $0.secret })
    }
    
    func listAll() -> [ServiceData] {
        ServiceCacheEntity.listAll(on: coreDataStack.context).map({ $0.serviceData })
    }
    
    func count() -> Int {
        ServiceCacheEntity.listAll(on: coreDataStack.context).count
    }

    func findService(by secret: String) -> ServiceCacheEntity? {
        ServiceCacheEntity
            .findService(on: coreDataStack.context, secret: secret.encrypt())
    }
    
    func findServices(by secrets: [String]) -> [ServiceData] {
        let services = secrets.compactMap {
            ServiceCacheEntity.findService(on: coreDataStack.context, secret: $0.encrypt())
        }
        return services.map({ $0.serviceData })
    }
    
    func updateOrCreate(with records: [ServiceRecord2]) {
        records.forEach { record in
            updateOrCreate(with: record, save: false)
        }
        coreDataStack.save()
    }
    
    func updateOrCreate(with record: ServiceRecord2, save: Bool) {
        guard
            let encryption,
            let embedded,
            let secretData = encryption.decrypt(
                password: embedded,
                encodedData: record.secret,
                encodedReference: record.reference
            ),
            let secret = String(data: secretData, encoding: .utf8)
        else { return }
        if let service = findService(by: secret) {
            service.name = record.name
            service.serviceTypeID = {
                if let serviceTypeID = record.serviceTypeID {
                    return ServiceTypeID(uuidString: serviceTypeID)
                }
                return nil
            }()
            service.additionalInfo = record.additionalInfo
            service.rawIssuer = record.rawIssuer
            service.otpAuth = record.otpAuth
            service.metadata = record.encodeSystemFields()
            service.creationDate = record.creationDate
            service.modificationDate = record.modificationDate
            service.tokenLength = NSNumber(value: record.tokenLength)
            service.tokenPeriod = intToNumber(record.tokenPeriod)
            service.iconType = record.iconType
            service.iconTypeID = IconTypeID(uuidString: record.iconTypeID) ?? IconTypeID.default
            service.badgeColor = record.badgeColor
            service.labelColor = record.labelColor
            service.labelTitle = record.labelTitle
            service.sectionID = {
                if let sectionID = record.sectionID {
                    return SectionID(uuidString: sectionID)
                }
                return nil
            }()
            service.sectionOrder = record.sectionOrder
            service.algorithm = record.algorithm
            service.counter = intToNumber(record.counter)
            service.tokenType = record.tokenType
            service.source = record.source
        } else {
            ServiceCacheEntity.create(
                on: coreDataStack.context,
                metadata: record.encodeSystemFields(),
                name: record.name,
                secret: secret.encrypt(),
                serviceTypeID: {
                    if let serviceTypeID = record.serviceTypeID {
                        return ServiceTypeID(uuidString: serviceTypeID)
                    }
                    return nil
                }(),
                additionalInfo: record.additionalInfo,
                rawIssuer: record.rawIssuer,
                otpAuth: record.otpAuth,
                creationDate: record.creationDate,
                modificationDate: record.modificationDate,
                tokenPeriod: record.tokenPeriod,
                tokenLength: record.tokenLength,
                badgeColor: record.badgeColor,
                iconType: record.iconType,
                iconTypeID: IconTypeID(uuidString: record.iconTypeID) ?? IconTypeID.default,
                labelColor: record.labelColor,
                labelTitle: record.labelTitle,
                sectionID: {
                    if let sectionID = record.sectionID {
                        return SectionID(uuidString: sectionID)
                    }
                    return nil
                }(),
                sectionOrder: record.sectionOrder,
                algorithm: record.algorithm,
                counter: record.counter,
                tokenType: record.tokenType,
                source: record.source
            )
        }
        if save {
            coreDataStack.save()
        }
    }
    
    func saveAfterBatch() {
        coreDataStack.save()
    }
}

extension ServiceHandler {
    func intToNumber(_ int: Int?) -> NSNumber? {
        guard let int else { return nil }
        return NSNumber(value: int)
    }
}
