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

public struct ExchangeData: Codable {
    public struct Service: Codable {
        public struct Otp: Codable {
            let account: String? // additionalInfo
            let issuer: String?
            let digits: Int?
            let period: Int?
            let algorithm: String?
            let counter: Int?
            let tokenType: String?
        }
        public struct Order: Codable {
            let position: Int
        }
        
        public let name: String
        public let secret: String
        public let type: String
        public let order: Order
        public let otp: Otp
        public let updatedAt: Int?
        public let badge: Badge?
        public let icon: Icon?
        public let groupId: String? // uuid string!
    }
    
    public struct Group: Codable {
        public let id: String // uuid string!
        public let name: String
        public let isExpanded: Bool
    }
    
    public struct Badge: Codable {
        public let color: String
    }
    
    public struct Icon: Codable {
        public let selected: IconTypeString
        public let brand: Brand?
        public let label: Label?
    }
    
    public enum IconTypeString: String, Codable {
        case brand = "Brand"
        case label = "Label"
    }
    
    public struct Brand: Codable {
        public let id: String // ServiceType
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
    public let schemaVersion: Int // 1
    public let services: [Service]
    public let servicesEncrypted: String?
    public let reference: String?
    public let groups: [Group]?
}
