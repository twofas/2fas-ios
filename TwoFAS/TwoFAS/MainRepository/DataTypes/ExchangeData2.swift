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

struct ExchangeData2: Codable {
    struct Service: Codable {
        struct Otp: Codable {
            let account: String? // additionalInfo
            let issuer: String? // if we have it in database
            let digits: Int?
            let period: Int?
            let algorithm: String?
            let counter: Int?
            let tokenType: String?
            let source: String // "manual"/"link"
            let link: String? // if we have the complete link, replace secret value with e.g. "[hidden]"
        }
        struct Order: Codable {
            let position: Int
        }
        
        let name: String
        let secret: String
        let serviceTypeID: String? // UUID string or null if unknown/manual
        let order: Order
        let otp: Otp
        let updatedAt: Int?
        let badge: Badge?
        let icon: Icon
        let groupId: String? // UUID string
    }
    
    struct Group: Codable {
        let id: String // UUID string
        let name: String
        let isExpanded: Bool
    }
    
    struct Badge: Codable {
        let color: String
    }
    
    struct Icon: Codable {
        let selected: IconTypeString
        let label: Label?
        let iconCollection: IconCollection
    }
    
    enum IconTypeString: String, Codable {
        case label = "Label"
        case iconCollection = "IconCollection"
    }
    
    struct IconCollection: Codable {
        let id: String
    }
    
    struct Brand: Codable {
        let id: String // UUID in string format eg. "70611158-5583-4F11-8C74-F560DBBCEACD"
    }
    
    struct Label: Codable {
        let text: String
        let backgroundColor: String // TintColor
    }
    
    enum AppOrigin: String, Codable {
        case android
        case ios
    }
    
    let appOrigin: AppOrigin // "android", "ios"
    let appVersionCode: Int // 200208
    let appVersionName: String // "2.2.8"
    let schemaVersion: Int // 3
    let services: [Service]
    let servicesEncrypted: String?
    let reference: String?
    let groups: [Group]?
}
