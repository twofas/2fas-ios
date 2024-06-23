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

public enum AEGISDataParseError: Error {
    case encrypted
    case error
}

public struct AEGISData: Decodable {
    public struct Header: Decodable {
        public let slots: String?
        public let params: String?
        
        private enum CodingKeys: String, CodingKey {
            case slots
            case params
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            do {
                slots = try container.decodeIfPresent(String.self, forKey: .slots)
                params = try container.decodeIfPresent(String.self, forKey: .params)
            } catch {
                throw AEGISDataParseError.encrypted
            }
        }
    }
    
    public struct Vault: Decodable {
        public let version: Int
        public let entries: [Entry]
        
        struct AnyCodable: Codable {}
        
        private enum CodingKeys: String, CodingKey {
            case version
            case entries
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            do {
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
            } catch {
                throw AEGISDataParseError.error
            }
        }
    }
    
    public struct Entry: Decodable {
        public enum EntryType: String, Decodable {
            case totp
            case hotp
            case steam
        }
        
        public struct Info: Decodable {
            private enum CodingKeys: String, CodingKey {
                case secret
                case algo
                case digits
                case period
                case counter
            }
            
            public enum Algo: String, Decodable {
                case sha1 = "SHA1"
                case sha256 = "SHA256"
                case sha512 = "SHA512"
            }
            public let secret: String
            public var algo: Algo = .sha1
            public var digits: Int = 6
            public var period: Int?
            public var counter: Int = 0
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                do {
                    secret = try container.decode(String.self, forKey: .secret)
                    if let algo = try? container.decode(Algo.self, forKey: .algo) {
                        self.algo = algo
                    }
                    if let digits = try? container.decode(Int.self, forKey: .digits) {
                        self.digits = digits
                    }
                    if let period = try? container.decode(Int.self, forKey: .period) {
                        self.period = period
                    }
                    if let counter = try? container.decode(Int.self, forKey: .counter) {
                        self.counter = counter
                    }
                } catch {
                    throw AEGISDataParseError.error
                }
            }
        }
        
        public let type: EntryType
        public let name: String
        public let issuer: String
        public let note: String?
        public let info: Info
    }
    
    public let version: Int
    public let header: Header
    public let db: Vault
}
