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
import Common

protocol ViewPathType: AnyObject {
    func set(_ path: ViewPath)
    func clear()
    func clearFor(_ path: ViewPath)
    func get() -> ViewPath?
}

protocol ViewPathNodeType: AnyObject {
    func updatePath(_ viewPath: ViewPathType)
}

final class ViewPathController: ViewPathType {
    private enum Consts {
        static let saveForMinutes: Int = 15
        static let key = "ViewPathController.ViewStatePath"
    }
    
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let userDefaults: UserDefaults
    
    init() {
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        userDefaults = UserDefaults.standard
    }
    
    func set(_ path: ViewPath) {
        Log("ViewPathController: Setting path: \(path)")
        let node = ViewStatePath(savedAt: Date(), path: path)
        guard let encodedNode = try? encoder.encode(node) else {
            assertionFailure()
            return
        }
        userDefaults.set(encodedNode, forKey: Consts.key)
        userDefaults.synchronize()
    }
    
    func clearFor(_ path: ViewPath) {
        Log("ViewPathController: Checking if should clear for path: \(path)")
        guard let currentPath = get(), path == currentPath else { return }
        clear()
    }
    
    func clear() {
        Log("ViewPathController: Clearing")
        userDefaults.set(nil, forKey: Consts.key)
        userDefaults.synchronize()
    }
    
    func get() -> ViewPath? {
        guard
            let nodeData = userDefaults.object(forKey: Consts.key) as? Data,
            let node = try? decoder.decode(ViewStatePath.self, from: nodeData)
        else {
            Log("ViewPathController: Can't get or decode anything")
            return nil
        }
        
        let currentDate = Date()
        guard node.savedAt < currentDate && node.savedAt.minutes(to: currentDate) <= Consts.saveForMinutes else {
            
            Log("ViewPathController: Entry to old")
            clear()
            return nil
        }
        
        Log("ViewPathController: Returning path: \(node.path)")
        return node.path
    }
}

enum ViewPath: Equatable {
    enum Settings {
        case vault
    }
    
    case main
    case settings(option: Settings?)
    case news
}

private struct ViewStatePath: Codable {
    
    let savedAt: Date
    let path: ViewPath
}

// MARK: - Codable

extension ViewPath: Codable {
    
    enum Key: CodingKey {
        
        case rawValue
        case associatedValue
    }
    
    enum Value: Int {
        
        case main = 0
        case settings = 1
        case news = 2
    }
    
    enum CodingError: Error {
        
        case unknownValue
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case Value.main.rawValue:
            self = .main
        case Value.settings.rawValue:
            let value = try container.decodeIfPresent(Settings.self, forKey: .associatedValue)
            self = .settings(option: value)
        default:
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: Key.self)
        
        switch self {
        case .main:
            try container.encode(Value.main.rawValue, forKey: .rawValue)
        case .settings(let value):
            try container.encode(Value.settings.rawValue, forKey: .rawValue)
            try container.encode(value, forKey: .associatedValue)
        case .news:
            try container.encode(Value.news.rawValue, forKey: .rawValue)
        }
    }
}

extension ViewPath.Settings: Codable {
    enum Key: CodingKey {
        case rawValue
    }
    
    enum Value: Int {
        case vault = 0
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case Value.vault.rawValue:
            self = .vault
        default:
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        
        switch self {
        case .vault:
            try container.encode(Value.vault.rawValue, forKey: .rawValue)
        }
    }
}
