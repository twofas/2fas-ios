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
import CloudKit

enum RecordType: String {
    case service1 = "ServiceRecord"
    case service2 = "ServiceRecord2"
    case service3 = "ServiceRecord3"
    case info = "CloudInfo"
    case section = "SectionRecord"
    case service4 = "ServiceRecord4"
    case section2 = "SectionRecord2"
    case deletedService = "DeletedServiceRecord"
    case deletedSection = "DeletedSectionRecord"
}

extension RecordType {
    var recordIDGenerator: RecordIDGenerator.Type {
        switch self {
        case .service1: ServiceRecord.self
        case .service2: ServiceRecord2.self
        case .service3: ServiceRecord3.self
        case .info: InfoRecord.self
        case .section: SectionRecord.self
        case .service4, .section2, .deletedService, .deletedSection: SealedRecordIDGenerator.self
        }
    }
}

extension RecordType {
    /// A record whose content is one sealed field and whose name is a derived identifier
    var isSealed: Bool {
        switch self {
        case .service4, .section2, .deletedService, .deletedSection: true
        case .service1, .service2, .service3, .info, .section: false
        }
    }
}

/// The name of a sealed record is an identifier that was already derived (`SyncIdentifierKey`)
final class SealedRecordIDGenerator: RecordIDGenerator {
    static func recordID(with identifier: String, zoneID: CKRecordZone.ID) -> CKRecord.ID {
        CKRecord.ID(recordName: identifier, zoneID: zoneID)
    }
}
