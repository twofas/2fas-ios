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
import Common
#elseif os(watchOS)
import CommonWatch
#endif

extension ServiceData {
    /// `nil` when the entity's content can't be decrypted
    static func createFromManagedObject(entity: ServiceEntity) -> ServiceData? {
        guard let content = entity.content else { return nil }
        return ServiceData(
            name: content.name,
            secret: content.secret,
            serviceTypeID: content.serviceTypeID,
            additionalInfo: content.additionalInfo,
            rawIssuer: content.rawIssuer,
            modifiedAt: entity.modificationDate,
            createdAt: entity.creationDate,
            tokenPeriod: Period.create(entity.tokenPeriod?.intValue),
            tokenLength: Digits.create(entity.tokenLength.intValue),
            badgeColor: TintColor(optionalRawValue: entity.badgeColor),
            iconType: IconType(optionalWithDefaultRawValue: entity.iconType),
            iconTypeID: content.iconTypeID,
            labelColor: TintColor(optionalWithDefaultRawValue: entity.labelColor),
            labelTitle: content.labelTitle,
            algorithm: Algorithm.create(entity.algorithm),
            isTrashed: entity.isTrashed.boolValue,
            trashingDate: entity.trashingDate,
            counter: entity.counter?.intValue,
            tokenType: TokenType.create(entity.tokenType),
            source: ServiceSource(optionalWithDefaultRawValue: entity.source),
            otpAuth: content.otpAuth,
            order: entity.sectionOrder,
            sectionID: entity.sectionID
        )
    }
    
    public var summarizeDescription: String {
        let serviceName = self.name
        let serviceAdditionalInfo = self.additionalInfo
                
        let value = (serviceAdditionalInfo != nil && !serviceAdditionalInfo!.isEmpty)
        ? "\(serviceName), \(serviceAdditionalInfo!)"
        : serviceName
        
        return value
    }
}
