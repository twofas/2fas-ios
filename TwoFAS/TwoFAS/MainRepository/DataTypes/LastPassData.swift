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

struct LastPassData: Decodable {
    static let supportedVersion: Int = 3
    let deviceId: String
    let deviceSecret: String
    let localDeviceId: String
    let deviceName: String
    let version: Int
    
    let accounts: [Account]
    
    struct Account: Decodable {
        let issuerName: String
        let userName: String
        let secret: String
        let timeStep: Int
        let digits: Int
        let creationTimestamp: Date
        let algorithm: String
    }
}
