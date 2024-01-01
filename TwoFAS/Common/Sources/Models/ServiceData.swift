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

public struct ServiceData: Hashable {
    public let name: String
    public let secret: String
    public let serviceTypeID: ServiceTypeID?
    public let additionalInfo: String?
    public let rawIssuer: String?
    public let modifiedAt: Date
    public let createdAt: Date
    public let tokenPeriod: Period?
    public let tokenLength: Digits
    public let badgeColor: TintColor?
    public let iconType: IconType
    public let iconTypeID: IconTypeID
    public let labelColor: TintColor
    public let labelTitle: String
    public let algorithm: Algorithm
    public let isTrashed: Bool
    public let trashingDate: Date?
    public private(set) var counter: Int?
    public let tokenType: TokenType
    public let source: ServiceSource
    public let otpAuth: String?
    
    public private(set) var order: Int?
    public let sectionID: SectionID?
    
    public init(
        name: String,
        secret: String,
        serviceTypeID: ServiceTypeID?,
        additionalInfo: String?,
        rawIssuer: String?,
        modifiedAt: Date,
        createdAt: Date,
        tokenPeriod: Period?,
        tokenLength: Digits,
        badgeColor: TintColor?,
        iconType: IconType,
        iconTypeID: IconTypeID,
        labelColor: TintColor,
        labelTitle: String,
        algorithm: Algorithm,
        isTrashed: Bool,
        trashingDate: Date?,
        counter: Int?,
        tokenType: TokenType,
        source: ServiceSource,
        otpAuth: String?,
        order: Int?,
        sectionID: UUID?
    ) {
        self.name = name
        self.secret = secret
        self.serviceTypeID = serviceTypeID
        self.additionalInfo = additionalInfo
        self.modifiedAt = modifiedAt
        self.createdAt = createdAt
        self.rawIssuer = rawIssuer
        self.tokenPeriod = tokenPeriod
        self.tokenLength = tokenLength
        self.badgeColor = badgeColor
        self.iconType = iconType
        self.iconTypeID = iconTypeID
        self.labelColor = labelColor
        self.labelTitle = labelTitle
        self.algorithm = algorithm
        self.isTrashed = isTrashed
        self.trashingDate = trashingDate
        self.counter = counter
        self.tokenType = tokenType
        self.source = source
        self.order = order
        self.otpAuth = otpAuth
        
        self.sectionID = sectionID
    }
    
    public mutating func updateOrder(_ order: Int) {
        self.order = order
    }
    
    public mutating func updateCounter(_ counter: Int) {
        self.counter = counter
    }
    
    public static func == (l: Self, r: Self) -> Bool {
        l.name == r.name &&
        l.secret == r.secret &&
        l.serviceTypeID == r.serviceTypeID &&
        l.additionalInfo == r.additionalInfo &&
        l.rawIssuer == r.rawIssuer &&
        l.tokenPeriod == r.tokenPeriod &&
        l.tokenLength == r.tokenLength &&
        l.badgeColor == r.badgeColor &&
        l.iconType == r.iconType &&
        l.iconTypeID == r.iconTypeID &&
        l.labelColor == r.labelColor &&
        l.labelTitle == r.labelTitle &&
        l.algorithm == r.algorithm &&
        l.isTrashed == r.isTrashed &&
        l.counter == r.counter &&
        l.tokenType == r.tokenType &&
        l.source == r.source &&
        l.order == r.order &&
        l.otpAuth == r.otpAuth &&
        l.sectionID == r.sectionID
    }
}

public extension ServiceData {
    var debugServiceType: String {
        if source == .manual {
            return "manual"
        } else {
            if let serviceTypeID {
                return serviceTypeID.uuidString
            }
            return "unknown service ID"
        }
    }
}

public extension Array where Element == ServiceData {
    var sortedBySection: [SectionID?: [ServiceData]] {
        var dict = [SectionID?: [ServiceData]]()
        forEach { osd in
            if dict[osd.sectionID] == nil {
                dict[osd.sectionID] = [osd]
            } else {
                var list = dict[osd.sectionID]
                list?.append(osd)
                dict[osd.sectionID] = list
            }
        }
        return dict.mapValues { list in
            list.sorted { $0.order ?? 0 <= $1.order ?? 0 }
        }
    }
}
