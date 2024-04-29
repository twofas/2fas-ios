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

extension ServiceCacheEntity {
    var serviceData: ServiceData {
        ServiceData(
            name: name,
            secret: secret.decrypt(),
            serviceTypeID: serviceTypeID,
            additionalInfo: additionalInfo,
            rawIssuer: rawIssuer,
            modifiedAt: modificationDate,
            createdAt: creationDate,
            tokenPeriod: {
                if let period = tokenPeriod?.intValue {
                    return Period(rawValue: period)
                }
                return nil
            }(),
            tokenLength: Digits(rawValue: tokenLength.intValue) ?? .defaultValue,
            badgeColor: TintColor(optionalRawValue: badgeColor),
            iconType: IconType(optionalWithDefaultRawValue: iconType),
            iconTypeID: iconTypeID,
            labelColor: TintColor(optionalWithDefaultRawValue: labelColor),
            labelTitle: labelTitle,
            algorithm: Algorithm(rawValue: algorithm) ?? .SHA1,
            isTrashed: false,
            trashingDate: nil,
            counter: counter?.intValue ?? 0,
            tokenType: TokenType(rawValue: tokenType) ?? .totp,
            source: ServiceSource(optionalWithDefaultRawValue: source),
            otpAuth: otpAuth,
            order: sectionOrder,
            sectionID: sectionID
        )
    }
}
