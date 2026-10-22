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

public struct ProtonData: Decodable {
    public struct Entry: Decodable {
        public enum EntryType: String, Decodable {
            case totp = "Totp"
            case hotp = "Hotp"
        }

        public struct Content: Decodable {
            public let uri: String
            public let name: String
            public let entryType: EntryType

            private enum CodingKeys: String, CodingKey {
                case uri
                case name
                case entryType = "entry_type"
            }
        }

        public let content: Content
    }

    struct AnyCodable: Codable {}

    public let version: Int
    public let entries: [Entry]

    private enum CodingKeys: String, CodingKey {
        case version
        case entries
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)

        var entriesContainer = try container.nestedUnkeyedContainer(forKey: .entries)
        var entriesList = [Entry]()

        while !entriesContainer.isAtEnd {
            if let entry = try? entriesContainer.decode(Entry.self) {
                entriesList.append(entry)
            } else {
                _ = try? entriesContainer.decode(AnyCodable.self)
            }
        }

        self.entries = entriesList
    }
}
