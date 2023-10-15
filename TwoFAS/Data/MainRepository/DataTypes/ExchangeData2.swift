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
import CodeSupport

public struct ExchangeData2: Codable {
    public struct Service: Codable {
        public struct Otp: Codable {
            public let account: String? // additionalInfo
            public let issuer: String? // if we have it in database
            public let digits: Int?
            public let period: Int?
            public let algorithm: String?
            public let counter: Int?
            public let tokenType: String?
            public let source: String // "manual"/"link"
            public let link: String? // if we have the complete link, replace secret value with e.g. "[hidden]"
        }
        public struct Order: Codable {
            public let position: Int
        }
        
        public let name: String
        public let secret: String
        public let serviceTypeID: String? // UUID string or null if unknown/manual
        public let order: Order
        public let otp: Otp
        public let updatedAt: Int?
        public let badge: Badge?
        public let icon: Icon
        public let groupId: String? // UUID string
    }
    
    public struct Group: Codable {
        public let id: String // UUID string
        public let name: String
        public let isExpanded: Bool
    }
    
    public struct Badge: Codable {
        public let color: String
    }
    
    public struct Icon: Codable {
        public let selected: IconTypeString
        public let label: Label?
        public let iconCollection: IconCollection
    }
    
    public enum IconTypeString: String, Codable {
        case label = "Label"
        case iconCollection = "IconCollection"
    }
    
    public struct IconCollection: Codable {
        public let id: String
    }
    
    public struct Brand: Codable {
        public let id: String // UUID in string format eg. "70611158-5583-4F11-8C74-F560DBBCEACD"
    }
    
    public struct Label: Codable {
        public let text: String
        public let backgroundColor: String // TintColor
    }
    
    public enum AppOrigin: String, Codable {
        case android
        case ios
    }
    
    public let appOrigin: AppOrigin // "android", "ios"
    public let appVersionCode: Int // 200208
    public let appVersionName: String // "2.2.8"
    public let schemaVersion: Int // 3
    public let services: [Service]
    public let servicesEncrypted: String?
    public let reference: String?
    public let groups: [Group]?
}
