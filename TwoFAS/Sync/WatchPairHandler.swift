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

public protocol WatchPairHandling: AnyObject {
    func list() -> [PairedWatch]
    func unpair(_ pairedWatch: PairedWatch)
    func rename(_ pairedWatch: PairedWatch, newName: String)
    func pair(deviceCodePath: DeviceCodePath, deviceName: String)
}

protocol WatchPairInfoHandling: AnyObject {
    func update(cloudList: [String])
    func cloudList() -> [String]
}

final class WatchPairHandler {
    var synchronize: Callback?
    var logInfoModification: Callback?
    
    private let syncEncryptionHandler: SyncEncryptionHandler
    private let infoHandler: InfoHandler
    
    private let storageKey = "WatchPairHandlerStorage"
    private let newDataForSyncKey = "WatchPairHandlerNewDataForSync"
    
    private let userDefaults: UserDefaults
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    private let notificationCenter: NotificationCenter
    
    private var cachedList: [DeviceCodeKey]?
    
    init(syncEncryptionHandler: SyncEncryptionHandler, infoHandler: InfoHandler) {
        self.userDefaults = .standard
        self.jsonEncoder = JSONEncoder()
        self.jsonDecoder = JSONDecoder()
        self.syncEncryptionHandler = syncEncryptionHandler
        self.infoHandler = infoHandler
        self.notificationCenter = .default
        notificationCenter.addObserver(
                self,
                selector: #selector(syncFinished),
                name: .syncCompletedSuccessfuly,
                object: nil
            )
        infoHandler.allowedDevicesUpdated = { [weak self] in
            self?.update(cloudList: $0)
        }
        infoHandler.allowedList = { [weak self] in
            self?.cloudList() ?? []
        }
        infoHandler.allowedDevicesChanged = { [weak self] in
            self?.needsUpdateFlag ?? false
        }
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
    
    func pair(deviceCodePath: DeviceCodePath, deviceName: String) {
        guard let deviceCode = deviceCodePath.extractDeviceCode(),
              let key = getCurrentKey() else {
            Log("Error while creating DeviceCodeKey from code path", module: .cloudSync, severity: .error)
            return
        }
        let device = DeviceCodeKey(deviceCode: deviceCode, encryptedData: key, deviceName: deviceName)
        var list = getList()
        if let index = list.firstIndex(where: { $0.deviceCode == device.deviceCode }) {
            list[index] = device
        } else {
            list.append(device)
        }
        saveList(list)
    }
    
    func clearList() {
        cachedList = nil
        removeList()
        update()
        synchronize?()
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
    @objc
    func syncFinished() {
        clearNeedsUpdateFlag()
    }
    
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
        
        update()
        if sync {
            synchronize?()
        }
    }
    
    func update() {
        setNeedsUpdateFlag()
        
        logInfoModification?()
    }
        
    func getCurrentKey() -> Data? {
        syncEncryptionHandler.encryptedWatchTicket
    }
    
    func setNeedsUpdateFlag() {
        userDefaults.set(true, forKey: newDataForSyncKey)
        userDefaults.synchronize()
    }
    
    func clearNeedsUpdateFlag() {
        userDefaults.set(false, forKey: newDataForSyncKey)
        userDefaults.synchronize()
    }
    
    var needsUpdateFlag: Bool {
        userDefaults.bool(forKey: newDataForSyncKey)
    }
    
    func storeList(_ list: [DeviceCodeKey]) {
        guard let encodedList = try? jsonEncoder.encode(list) else {
            Log("Error while encoding DeviceCodeKey list", module: .cloudSync, severity: .error)
            return
        }
        userDefaults.set(encodedList, forKey: storageKey)
        userDefaults.synchronize()
    }
    
    func removeList() {
        userDefaults.removeObject(forKey: storageKey)
        userDefaults.synchronize()
    }
    
    func storedList() -> [DeviceCodeKey] {
        guard let encodedList = userDefaults.data(forKey: storageKey) else {
            return []
        }
        guard let list = try? jsonDecoder.decode([DeviceCodeKey].self, from: encodedList) else {
            Log("Error while decoding DeviceCodeKey list", module: .cloudSync, severity: .error)
            return []
        }
        return list
    }
}
