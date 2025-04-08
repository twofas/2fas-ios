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
import Common

public struct PairedWatch {
    public let deviceName: String
    let deviceCodeKey: DeviceCodeKey
    
    init(deviceCodeKey: DeviceCodeKey) {
        self.deviceName = deviceCodeKey.deviceName
        self.deviceCodeKey = deviceCodeKey
    }
}

public protocol WatchPairHandling: AnyObject {
    func list() -> [PairedWatch]
    func unpair(_ pairedWatch: PairedWatch)
    func rename(_ pairedWatch: PairedWatch, newName: String)
    func pair(deviceCodePath: DeviceCodePath)
}

protocol WatchPairInfoHandling: AnyObject {
    func update(cloudList: [String])
    func cloudList() -> [String]
}

final class WatchPairHandler {
    private let syncEncryptionHandler: SyncEncryptionHandler
    private let infoHandler: InfoHandler
    private let key = "WatchPairHandlerStorage"
    private let userDefaults: UserDefaults
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    
    private var cachedList: [DeviceCodeKey]?
    
    init(syncEncryptionHandler: SyncEncryptionHandler, infoHandler: InfoHandler) {
        self.userDefaults = .standard
        self.jsonEncoder = JSONEncoder()
        self.jsonDecoder = JSONDecoder()
        self.syncEncryptionHandler = syncEncryptionHandler
        self.infoHandler = infoHandler
    }
}

extension WatchPairHandler: WatchPairHandling {
    func list() -> [PairedWatch] {
        getList().map { PairedWatch(deviceCodeKey: $0) }
    }
    
    func unpair(_ pairedWatch: PairedWatch) {
        var list = getList()
        guard let index = list.firstIndex(where: { $0.deviceCode == pairedWatch.deviceCodeKey.deviceCode }) else {
            return
        }
        list.remove(at: index)
        saveList(list)
    }
    
    func rename(_ pairedWatch: PairedWatch, newName: String) {
        var list = getList()
        guard let index = list.firstIndex(where: { $0.deviceCode == pairedWatch.deviceCodeKey.deviceCode }) else {
            return
        }
        var deviceCodeKey = list[index]
        deviceCodeKey.updateName(newName)
        list[index] = deviceCodeKey
        saveList(list)
    }
    
    func pair(deviceCodePath: DeviceCodePath) {
        guard let device = DeviceCodeKey(deviceCodePath: deviceCodePath) else {
            Log("Error while creating DeviceCodeKey from code path", module: .cloudSync, severity: .error)
            return
        }
        var list = getList()
        if let index = list.firstIndex(where: { $0.deviceCode == device.deviceCode }) {
            list[index] = device
        } else {
            list.append(device)
        }
        saveList(list)
    }
}

extension WatchPairHandler: WatchPairInfoHandling {
    func update(cloudList: [String]) {
        let list = getList()
        let cloudList = cloudList.compactMap({ DeviceCodeKey(string: $0) })
        let listSet = Set<DeviceCodeKey>(list)
        let cloudSet = Set<DeviceCodeKey>(cloudList)
        if listSet == cloudSet {
            return
        }
        saveList(cloudList, sync: false)
    }
    
    func cloudList() -> [String] {
        let list = getList()
        return list.compactMap({ $0.createString() })
    }
}

private extension WatchPairHandler {
    func getList() -> [DeviceCodeKey] {
        if let cachedList {
            return cachedList
        }
        let list = storedList()
        cachedList = list
        return list
    }
    
    func saveList(_ list: [DeviceCodeKey], sync: Bool = true) {
        let list = list.sorted(by: { $0.deviceCode < $1.deviceCode })
        cachedList = list
        storeList(list)
        
        // update info!
        if sync {
            //        sync()
        }
    }
    
    func getCurrentKey() -> Data {
        Data() // get from encryption handler
    }
    
    func storeList(_ list: [DeviceCodeKey]) {
        guard let encodedList = try? jsonEncoder.encode(list) else {
            Log("Error while encoding DeviceCodeKey list", module: .cloudSync, severity: .error)
            return
        }
        userDefaults.set(encodedList, forKey: key)
        userDefaults.synchronize()
    }
    
    func storedList() -> [DeviceCodeKey] {
        guard let encodedList = userDefaults.data(forKey: key) else {
            return []
        }
        guard let list = try? jsonDecoder.decode([DeviceCodeKey].self, from: encodedList) else {
            Log("Error while decoding DeviceCodeKey list", module: .cloudSync, severity: .error)
            return []
        }
        return list
    }
}
