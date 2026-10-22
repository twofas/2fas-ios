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

public struct BitwardenData: Decodable {
    public struct Item: Decodable {
        public struct Login: Decodable {
            public let totp: String?
            public let username: String?

            public init(totp: String?, username: String?) {
                self.totp = totp
                self.username = username
            }
        }

        public let name: String?
        public let login: Login?

        public init(name: String?, login: Login?) {
            self.name = name
            self.login = login
        }
    }

    public let encrypted: Bool
    public let items: [Item]?

    public init(encrypted: Bool, items: [Item]?) {
        self.encrypted = encrypted
        self.items = items
    }
}
