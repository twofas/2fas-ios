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

enum ViewPath: Equatable {
    enum Settings {
        case vault
    }
    
    case main
    case settings(option: Settings?)
    case news
}

protocol ViewPathIteracting: AnyObject {
    func setViewPath(_ path: ViewPath)
    func clear()
    func clearFor(_ path: ViewPath)
    func viewPath() -> ViewPath?
}

final class ViewPathInteractor {
    private let saveForMinutes: Int = 15
    
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension ViewPathInteractor: ViewPathIteracting {
    func setViewPath(_ path: ViewPath) {
        Log("ViewPathInteractor: Setting path: \(path)")
        mainRepository.saveViewPath(path)
    }
    
    func clearFor(_ path: ViewPath) {
        Log("ViewPathInteractor: Checking if should clear for path: \(path)")
        guard let currentPath = viewPath(), path == currentPath else { return }
        clear()
    }
    
    func clear() {
        Log("ViewPathInteractor: Clearing")
        mainRepository.clearViewPath()
    }
    
    func viewPath() -> ViewPath? {
        guard let path = mainRepository.viewPath() else { return nil }
        
        let currentDate = Date()
        guard path.savedAt < currentDate && path.savedAt.minutes(to: currentDate) <= saveForMinutes else {
            Log("ViewPathInteractor: Entry to old")
            clear()
            return nil
        }
        
        Log("ViewPathInteractor: Returning path: \(path.viewPath)")
        return path.viewPath
    }
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
