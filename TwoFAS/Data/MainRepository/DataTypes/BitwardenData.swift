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

/// Covers both Bitwarden Authenticator and Bitwarden Password Manager exports.
/// Password Manager exports contain additional fields (folders, collections, login URIs, non-login items)
/// and their `login.totp` may be an otpauth URI, a `steam://` URI or a bare Base32 secret.
public struct BitwardenData: Decodable {
    public enum Source {
        case authenticator
        case passwordManager
    }

    public struct Item: Decodable {
        public struct Login: Decodable {
            public struct URI: Decodable {
                public let uri: String?

                public init(uri: String?) {
                    self.uri = uri
                }
            }

            public let totp: String?
            public let username: String?
            public let uris: [URI]?

            public init(totp: String?, username: String?, uris: [URI]? = nil) {
                self.totp = totp
                self.username = username
                self.uris = uris
            }
        }

        public let name: String?
        public let login: Login?

        public init(name: String?, login: Login?) {
            self.name = name
            self.login = login
        }
    }

    private enum CodingKeys: String, CodingKey {
        case encrypted
        case items
        case folders
        case collections
    }

    public let encrypted: Bool
    public let items: [Item]?
    public let source: Source

    public init(encrypted: Bool, items: [Item]?, source: Source = .authenticator) {
        self.encrypted = encrypted
        self.items = items
        self.source = source
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        encrypted = try container.decode(Bool.self, forKey: .encrypted)
        items = try container.decodeIfPresent([Item].self, forKey: .items)

        // Authenticator export has only `encrypted` and `items`; Password Manager always adds `folders`
        // (individual vault) or `collections` (organization vault) and stores URIs with logins
        let hasContainers = container.contains(.folders) || container.contains(.collections)
        let hasURIs = items?.contains(where: { $0.login?.uris != nil }) ?? false
        source = (hasContainers || hasURIs) ? .passwordManager : .authenticator
    }
}
