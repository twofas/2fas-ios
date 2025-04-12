//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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

public struct DeviceCodePath: Equatable, Hashable {
    private static let prefix = "twofas://pair-watch/"
    
    public let codePath: String
    
    public init(code: String) {
        self.codePath = Self.prefix + code
    }
    
    public static func isDeviceCode(_ path: String) -> Bool {
        extractCode(from: path) != nil
    }
    
    public func extractDeviceCode() -> DeviceCode? {
        Self.extractDeviceCode(from: codePath)
    }
    
    public static func extractDeviceCode(from path: String) -> DeviceCode? {
        guard let code = extractCode(from: path) else {
            return nil
        }
        return DeviceCode(code: code)
    }
    
    private static func extractCode(from path: String) -> String? {
        guard path.hasPrefix(Self.prefix) else {
            return nil
        }
        var path = path
        path.removeFirst(Self.prefix.count)
        guard path.count == DeviceCode.prefixLength else {
            return nil
        }
        return path
    }
}

public struct DeviceCode: Equatable, Codable, Comparable, Hashable {
    public static func < (lhs: DeviceCode, rhs: DeviceCode) -> Bool {
        lhs.code < rhs.code
    }
    
    static let prefixLength = 14
    
    public let code: String
    
    public init(code: String) {
        self.code = code
    }
    
    public static func generate() -> String {
        let uuidSubstring = UUID().uuidString.uppercased().replacing("-", with: "").prefix(prefixLength)
        return String(uuidSubstring)
    }
}

public struct DeviceCodeKey: Equatable, Codable, Hashable {
    private static let separator = "___"
    
    public let deviceCode: DeviceCode
    public let encryptedData: Data
    public private(set) var deviceName: String
    
    public init?(string: String) {
        let splitted = string.split(separator: Self.separator)
        guard splitted.count == 3 else {
            return nil
        }
        let code = String(splitted[0])
        let encrypted = String(splitted[1])
        let nameEncoded = String(splitted[2])
        guard code.count == DeviceCode.prefixLength,
              let data = Data(base64Encoded: encrypted),
              let decodedNameData = Data(base64Encoded: nameEncoded),
              let name = String(data: decodedNameData, encoding: .utf8)
        else {
            return nil
        }
        self.deviceCode = DeviceCode(code: code)
        self.encryptedData = data
        self.deviceName = name
    }
    
    public init(deviceCode: DeviceCode, encryptedData: Data, deviceName: String) {
        self.deviceCode = deviceCode
        self.encryptedData = encryptedData
        self.deviceName = deviceName
    }
    
    public static func findKeyFor(deviceCode: DeviceCode, in array: [String]) -> DeviceCodeKey? {
        let prefix = "\(deviceCode.code)\(separator)"
        guard let entry = array.first(where: { $0.hasPrefix(prefix) }) else {
            return nil
        }
        return Self(string: entry)
    }
    
    public static func findIndexFor(deviceCode: DeviceCode, in array: [String]) -> Int? {
        let prefix = "\(deviceCode.code)\(separator)"
        guard let index = array.firstIndex(where: { $0.hasPrefix(prefix) }), Self(string: array[index]) != nil else {
            return nil
        }
        return index
    }
    
    public func createString() -> String? {
        let strData = encryptedData.base64EncodedString()
        guard let name = deviceName.data(using: .utf8)?.base64EncodedString() else {
            return nil
        }
        return "\(deviceCode.code)\(Self.separator)\(strData)\(Self.separator)\(name)"
    }
    
    public mutating func updateName(_ deviceName: String) {
        self.deviceName = deviceName
    }
}
