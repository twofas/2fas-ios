//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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
import CommonWatch
import ProtectionWatch

protocol UserDefaultsRepository: AnyObject {
    var pin: AppPIN? { get }
    func setPIN(_ pin: AppPIN?)

    var sortType: SortType? { get }
    func setSortType(_ sortType: SortType)

    var wasIntroductionShown: Bool { get }
    func markIntroductionAsShown()
    
    func setFavoriteServices(_ services: [Secret])
    func favoriteServices() -> [Secret]?
}

final class UserDefaultsRepositoryImpl: UserDefaultsRepository {
    private enum Keys: String, CaseIterable {
        case sortType
        case introductionShown
        case pin
        case favoriteServices
    }
    private let userDefaults = UserDefaults()
    
    private let localEncryption = LocalKeyEncryption()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    var pin: AppPIN? {
        guard
            let data = userDefaults.object(forKey: Keys.pin.rawValue) as? Data,
            let object = try? decoder.decode(AppPIN.self, from: data)
        else { return nil }
        let decrypted = AppPIN(type: object.type, value: localEncryption.decrypt(object.value))
        return decrypted
    }
    
    func setPIN(_ pin: AppPIN?) {
        guard let pin else {
            userDefaults.set(nil, forKey: Keys.pin.rawValue)
            userDefaults.synchronize()
            return
        }
        do {
            let encrypted = AppPIN(type: pin.type, value: localEncryption.encrypt(pin.value))
            let encodedNode = try encoder.encode(encrypted)
            userDefaults.set(encodedNode, forKey: Keys.pin.rawValue)
            userDefaults.synchronize()
        } catch {
            Log("Can't save App PIN! Error: \(error)", severity: .error)
        }
    }
    
    var sortType: SortType? {
        guard let value = userDefaults.string(forKey: Keys.sortType.rawValue) else { return nil }
        return SortType(rawValue: value)
    }
    
    func setSortType(_ sortType: SortType) {
        userDefaults.set(sortType.rawValue, forKey: Keys.sortType.rawValue)
        userDefaults.synchronize()
    }
    
    var wasIntroductionShown: Bool {
        userDefaults.bool(forKey: Keys.introductionShown.rawValue)
    }
    
    func markIntroductionAsShown() {
        userDefaults.set(true, forKey: Keys.introductionShown.rawValue)
        userDefaults.synchronize()
    }
    
    func setFavoriteServices(_ services: [Secret]) {
        do {
            let encodedNode = try encoder.encode(services)
            userDefaults.set(encodedNode, forKey: Keys.favoriteServices.rawValue)
            userDefaults.synchronize()
        } catch {
            Log("Can't save Favorite Services! Error: \(error)", severity: .error)
        }
    }
    
    func favoriteServices() -> [Secret]? {
        guard
            let data = userDefaults.object(forKey: Keys.favoriteServices.rawValue) as? Data,
            let list = try? decoder.decode([Secret].self, from: data)
        else { return nil }
        return list
    }
}
