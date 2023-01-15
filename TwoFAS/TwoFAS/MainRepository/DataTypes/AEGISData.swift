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

enum AEGISDataParseError: Error {
    case encrypted
    case newerVersion
    case error
}

struct AEGISData: Decodable {
    struct Header: Decodable {
        let slots: String?
        let params: String?
        
        private enum CodingKeys: String, CodingKey {
            case slots
            case params
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            do {
                slots = try container.decodeIfPresent(String.self, forKey: .slots)
                params = try container.decodeIfPresent(String.self, forKey: .params)
            } catch {
                throw AEGISDataParseError.encrypted
            }
        }
    }
    
    struct Vault: Decodable {
        let version: Int
        let entries: [Entry]
        
        struct AnyCodable: Codable {}
        
        private enum CodingKeys: String, CodingKey {
            case version
            case entries
        }
        
        init(from decoder: Decoder) throws {
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
            if version != 2 {
                throw AEGISDataParseError.newerVersion
            }
        }
    }
    
    struct Entry: Decodable {
        enum EntryType: String, Decodable {
            case totp
            case hotp
        }
        
        struct Info: Decodable {
            private enum CodingKeys: String, CodingKey {
                case secret
                case algo
                case digits
                case period
                case counter
            }
            
            enum Algo: String, Decodable {
                case sha1 = "SHA1"
                case sha256 = "SHA256"
                case sha512 = "SHA512"
            }
            let secret: String
            var algo: Algo = .sha1
            var digits: Int = 6
            var period: Int?
            var counter: Int = 0
            
            init(from decoder: Decoder) throws {
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
        
        let type: EntryType
        let name: String
        let issuer: String
        let note: String?
        let info: Info
    }
    
    let version: Int
    let header: Header
    let db: Vault
}
