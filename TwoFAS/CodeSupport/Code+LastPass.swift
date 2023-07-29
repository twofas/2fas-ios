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
import Compression
import Common

extension Code {
    static func checkLastPass(with str: String) -> [Code]? {
        guard let components = NSURLComponents(string: str),
              let scheme = components.scheme, scheme == "lpaauth-migration",
              let host = components.host, host == "offline",
              let query = components.queryItems,
              let data = query.first(where: { $0.name == "data" }),
              let value = data.value?.removingPercentEncoding,
              let encodeData = Data(base64Encoded: value),
              let decompressedData = decompress(encodeData),
              let codes = parseAndDecompressMainStructure(for: decompressedData)
        else { return nil }
        return codes
    }
}

private extension Code {
    struct LastPassService: Decodable {
        let a: String // Algorithm
        let iN: String? // Issuer/title
        let s: String // Secret
        let d: Int // Digits
        let uN: String? // Account
        let tS: Int? // Period
    }
    
    static func decompress(_ data: Data) -> Data? {
        let pageSize = 128
        var decompressedData = Data()
        var inputFilter: InputFilter<Data>
        do {
            var index = 10 // Skipping header
            let bufferSize = data.count
            
            inputFilter = try InputFilter(.decompress, using: .zlib) { (length: Int) -> Data? in
                let rangeLength = min(length, bufferSize - index)
                let subdata = data.subdata(in: index ..< index + rangeLength)
                index += rangeLength
                return subdata
            }
        } catch {
            Log("Error occurred while creating input filter for LastPass scanner: \(error as NSError)")
            return nil
        }
        
        do {
            while let page = try inputFilter.readData(ofLength: pageSize) {
                decompressedData.append(page)
            }
        } catch {
            Log("Error occurred during decoding from LastPass export url: \(error as NSError)")
            return nil
        }
        return decompressedData
    }
    
    static func parseAndDecompressMainStructure(for data: Data) -> [Code]? {
        let supportedVersion: Int = 3
        struct MainStructure: Decodable {
            let content: String
            let version: Int
        }
        struct ContentStructure: Decodable {
            let a: [LastPassService]
        }
        
        guard let mainStruct = try? JSONDecoder().decode(MainStructure.self, from: data) else {
            Log("Error occurred during parsing main structure from LastPass")
            return nil
        }
        
        guard mainStruct.version == supportedVersion else {
            Log("Error during parsing main structure from LastPass - trying to import newer version")
            return nil
        }
        
        guard let baseEncodedContent = Data(base64Encoded: mainStruct.content) else {
            Log("Error during parsing main structure from LastPass - can't parse base64 of the content")
            return nil
        }
        
        guard let contentStruct = decompress(baseEncodedContent) else {
            Log("Error during decompresssing main structure from LastPass")
            return nil
        }
        
        guard let content = try? JSONDecoder().decode(ContentStructure.self, from: contentStruct) else {
            Log("Error during parsing content structure from LastPass - can't parse ContentStructure")
            return nil
        }
        
        return content.a.map({ parseLastPassService($0) })
    }
    
    static func parseLastPassService(_ service: LastPassService) -> Code {
        Code(
            issuer: service.iN,
            label: service.uN?.sanitizeInfo(),
            secret: service.s.sanitazeSecret(),
            period: .create(service.tS),
            digits: .create(service.d),
            algorithm: .create(service.a),
            tokenType: .totp,
            counter: 0,
            otpAuth: nil
        )
    }
}
