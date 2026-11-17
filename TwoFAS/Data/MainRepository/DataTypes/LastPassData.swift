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

public struct LastPassData: Decodable {
    public let localDeviceId: String?
    public let deviceName: String?
    public let version: Int
    
    public let accounts: [Account]
    
    public struct Account: Decodable {
        public let issuerName: String
        public let userName: String
        public let secret: String
        public let timeStep: Int
        public let digits: Int
        public let creationTimestamp: Date
        public let algorithm: String

        enum CodingKeys: String, CodingKey {
            case issuerName
            case userName
            case secret
            case timeStep
            case digits
            case creationTimestamp
            case algorithm
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            issuerName = try container.decode(String.self, forKey: .issuerName)
            userName = try container.decode(String.self, forKey: .userName)
            secret = try container.decode(String.self, forKey: .secret)
            timeStep = try container.decode(Int.self, forKey: .timeStep)
            digits = try container.decode(Int.self, forKey: .digits)
            algorithm = try container.decode(String.self, forKey: .algorithm)

            // Unix epoch. iOS exports use seconds, values too large for that are treated as milliseconds
            let timestamp = try container.decode(Double.self, forKey: .creationTimestamp)
            let millisecondsThreshold: Double = 100_000_000_000
            creationTimestamp = Date(
                timeIntervalSince1970: timestamp >= millisecondsThreshold ? timestamp / 1000 : timestamp
            )
        }
    }
}
