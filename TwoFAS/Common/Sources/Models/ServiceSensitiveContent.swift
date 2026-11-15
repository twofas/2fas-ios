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

import Foundation

public struct ServiceSensitiveContent: Codable, Equatable {
    public var secret: String
    public var name: String
    public var additionalInfo: String?
    public var rawIssuer: String?
    public var otpAuth: String?
    public var labelTitle: String
    public var serviceTypeID: ServiceTypeID?
    public var iconTypeID: IconTypeID

    public init(
        secret: String,
        name: String,
        additionalInfo: String?,
        rawIssuer: String?,
        otpAuth: String?,
        labelTitle: String,
        serviceTypeID: ServiceTypeID?,
        iconTypeID: IconTypeID
    ) {
        self.secret = secret
        self.name = name
        self.additionalInfo = additionalInfo
        self.rawIssuer = rawIssuer
        self.otpAuth = otpAuth
        self.labelTitle = labelTitle
        self.serviceTypeID = serviceTypeID
        self.iconTypeID = iconTypeID
    }
}

/// The sealed content of a section (category)
public struct SectionSensitiveContent: Codable, Equatable {
    public var title: String

    public init(title: String) {
        self.title = title
    }
}

/// The sealed content of the record of a deleted service. The secret is what identifies the service on other
/// devices – it's kept only until the deletion gets its sync identifier.
public struct DeletedServiceSensitiveContent: Codable, Equatable {
    public var secret: String

    public init(secret: String) {
        self.secret = secret
    }
}
