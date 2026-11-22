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
import CloudKit

final class InfoHandler {
    var allowedDevicesUpdated: (([String]) -> Void)?
    var allowedList: (() -> [String])?
    var allowedDevicesChanged: (() -> Bool)?
    
    private let allowedDevicesNone = Info.noAllowedDevices
    
    private enum Keys: String, CaseIterable {
        case metadata
        case modificationDate
        case version
        case encryptionReference
        case encryptionType
        case allowedDevices
        case enableWatch
        case kdfSalt
        case kdfParameters
        case identifierKey
    }
    private let userDefault: UserDefaults
    private let syncEncryptionHandler: SyncEncryptionHandling
    private let zoneManager: ZoneManaging
    
    /// - Parameter userDefaults: Where what the Info record said is kept between launches.
    init(
        zoneManager: ZoneManaging,
        syncEncryptionHandler: SyncEncryptionHandling,
        userDefaults: UserDefaults = UserDefaults()
    ) {
        self.userDefault = userDefaults
        self.zoneManager = zoneManager
        self.syncEncryptionHandler = syncEncryptionHandler
    }
    
    func updateUsingRecord(_ record: InfoRecord) {
        saveMetadata(record.encodeSystemFields())
        saveVersion(record.version)
        saveAllowedDevices(record.allowedDevices)
        saveEnableWatch(record.enableWatch)
        saveEncryptionReference(record.encryptionReference ?? Data())
        saveEncryptionType(Info.Encryption(rawValue: record.encryption) ?? .system)
        saveModificationDate(record.modificationDate)
        saveEncryptionInfo(record.encryptionInfo)
        syncEncryptionHandler.cloudEncryptionInfoFetched(record.encryptionInfo)
        allowedDevicesUpdated?(record.allowedDevices)
    }
    
    /// The first Info record of the current vault. In a clean cloud everything has its default value; in a vault
    /// the data is being migrated to, the encryption and the paired watches are the ones of the old vault
    /// (`prepareForNewVault()`).
    func createNew(encryptionReference: Data) -> CKRecord? {
        let devicesList = allowedList?() ?? []
        return InfoRecord.create(
            zoneID: zoneManager.currentZoneID,
            version: Info.version,
            // What the record says about the key is what its reference is sealed with – the key this device
            // uses now, never what another record said. Named after one key and sealed with the other, the
            // vault couldn't be opened by anything.
            encryption: syncEncryptionHandler.encryptionType.rawValue,
            allowedDevices: devicesList.isEmpty ? allowedDevices : devicesList,
            enableWatch: enableWatch,
            encryptionReference: encryptionReference,
            encryptionInfo: syncEncryptionHandler.cloudEncryptionInfo(cached: encryptionInfo),
            modificationDate: Date()
        )
    }
    
    func clear() {
        update(
            version: nil,
            encryption: .system,
            allowedDevices: [allowedDevicesNone],
            enableWatch: false,
            encryptionReference: syncEncryptionHandler.encryptionReference
        )
    }
    
    func update(
        version: Int?,
        encryption: Info.Encryption?,
        allowedDevices: [String]?,
        enableWatch: Bool?,
        encryptionReference: Data?
    ) {
        if let version {
            saveVersion(version)
        }
        if let encryption {
            saveEncryptionType(encryption)
        }
        if let allowedDevices {
            saveAllowedDevices(allowedDevices)
        }
        if let enableWatch {
            saveEnableWatch(enableWatch)
        }
        if let encryptionReference {
            saveEncryptionReference(encryptionReference)
        }
        saveModificationDate(Date())
    }
    
    func prepareForSendoffCachedVersion() -> [CKRecord] {
        if let record = recreateCached() {
            return [record]
        }
        return []
    }
    
    func prepareForSendoff() -> [CKRecord] {
        if let record = recreate() {
            return [record]
        }
        return createNewRecord()
    }
    
    func createNewRecord() -> [CKRecord] {
        if let record = createNew(encryptionReference: syncEncryptionHandler.encryptionReference ?? Data()) {
            return [record]
        }
        return []
    }
    
    func recreate() -> CKRecord? {
        guard let metadata,
              let version,
              let encryptionReference,
              let encryptionType
        else {
            return nil
        }
        let devicesChanged = allowedDevicesChanged?() == true
        let devicesList = allowedList?() ?? []
        let devices = {
            if devicesChanged {
                return devicesList
            }
            return allowedDevices
        }()
        let date: Date = {
            if devicesChanged {
                return Date()
            }
            return modificationDate
        }()
        return InfoRecord.recreate(
            with: metadata,
            version: version,
            encryption: encryptionType.rawValue,
            allowedDevices: devices,
            enableWatch: enableWatch,
            encryptionReference: encryptionReference,
            encryptionInfo: syncEncryptionHandler.cloudEncryptionInfo(cached: encryptionInfo),
            modificationDate: date
        )
    }
    
    func recreateCached() -> CKRecord? {
        guard let metadata,
              let version,
              let encryptionReference,
              let encryptionType
        else {
            return nil
        }
        return InfoRecord.recreate(
            with: metadata,
            version: version,
            encryption: encryptionType.rawValue,
            allowedDevices: allowedDevices,
            enableWatch: enableWatch,
            encryptionReference: encryptionReference,
            encryptionInfo: encryptionInfo,
            modificationDate: modificationDate
        )
    }
}

extension InfoHandler {
    func purge() {
        Keys.allCases.forEach { key in
            userDefault.set(nil, forKey: key.rawValue)
        }
        userDefault.synchronize()
    }
    
    /// What the Info record says and has to keep saying in the vault the data is migrated to
    struct CarriedOver {
        let encryptionType: Info.Encryption?
        let allowedDevices: [String]
        let enableWatch: Bool
        let encryptionInfo: SyncCloudEncryptionInfo
    }
    
    var carriedOver: CarriedOver {
        CarriedOver(
            encryptionType: encryptionType,
            allowedDevices: allowedDevices,
            enableWatch: enableWatch,
            encryptionInfo: encryptionInfo
        )
    }
    
    /// After the cache of the old vault was purged: the record of the new vault doesn't exist yet (no metadata,
    /// no version), but it will say what the old one said.
    func prepareForNewVault(_ carried: CarriedOver) {
        if let encryptionType = carried.encryptionType {
            saveEncryptionType(encryptionType)
        }
        saveAllowedDevices(carried.allowedDevices)
        saveEnableWatch(carried.enableWatch)
        saveEncryptionInfo(carried.encryptionInfo)
    }

    //
    
    var metadata: Data? {
        userDefault.data(forKey: Keys.metadata.rawValue)
    }

    func saveMetadata(_ metadata: Data) {
        userDefault.set(metadata, forKey: Keys.metadata.rawValue)
        userDefault.synchronize()
    }
    
    //
    
    var modificationDate: Date {
        let value = userDefault.double(forKey: Keys.modificationDate.rawValue)
        guard !value.isZero else {
            return Date()
        }
        return Date(timeIntervalSince1970: value)
    }

    func saveModificationDate(_ date: Date) {
        userDefault.set(date.timeIntervalSince1970, forKey: Keys.modificationDate.rawValue)
        userDefault.synchronize()
    }
    
    //
    
    var version: Int? {
        let value = userDefault.integer(forKey: Keys.version.rawValue)
        if value == 0 {
            return nil
        }
        return value
    }
    
    func saveVersion(_ version: Int) {
        userDefault.set(version, forKey: Keys.version.rawValue)
        userDefault.synchronize()
    }
    
    //
    
    var encryptionReference: Data? {
        userDefault.data(forKey: Keys.encryptionReference.rawValue)
    }

    func saveEncryptionReference(_ encryptionReference: Data) {
        userDefault.set(encryptionReference, forKey: Keys.encryptionReference.rawValue)
        userDefault.synchronize()
    }
    
    //
    
    var encryptionType: Info.Encryption? {
        guard let str = userDefault.string(forKey: Keys.encryptionType.rawValue),
              let value = Info.Encryption(rawValue: str)
        else {
            return nil
        }
        return value
    }

    func saveEncryptionType(_ encryptionType: Info.Encryption) {
        userDefault.set(encryptionType.rawValue, forKey: Keys.encryptionType.rawValue)
        userDefault.synchronize()
    }
    
    //
    
    var allowedDevices: [String] {
        guard let devices = userDefault.array(forKey: Keys.allowedDevices.rawValue) as? [String],
              !devices.isEmpty
        else {
            return [allowedDevicesNone]
        }
        return devices
    }
    
    func saveAllowedDevices(_ devices: [String]?) {
        if let devices, !devices.isEmpty {
            userDefault.set(devices, forKey: Keys.allowedDevices.rawValue)
        } else {
            userDefault.set([allowedDevices], forKey: Keys.allowedDevices.rawValue)
        }
        userDefault.synchronize()
    }
    
    //
    
    var enableWatch: Bool {
        userDefault.bool(forKey: Keys.enableWatch.rawValue)
    }
    
    func saveEnableWatch(_ enable: Bool?) {
        if let enable {
            userDefault.set(enable, forKey: Keys.enableWatch.rawValue)
        } else {
            userDefault.set(false, forKey: Keys.enableWatch.rawValue)
        }
        userDefault.synchronize()
    }
    
    //
    
    /// What the Info record carried about the encryption when it was last fetched
    var encryptionInfo: SyncCloudEncryptionInfo {
        SyncCloudEncryptionInfo(
            kdfSalt: userDefault.data(forKey: Keys.kdfSalt.rawValue),
            kdfParameters: userDefault.data(forKey: Keys.kdfParameters.rawValue),
            wrappedIdentifierKey: userDefault.data(forKey: Keys.identifierKey.rawValue)
        )
    }
    
    func saveEncryptionInfo(_ info: SyncCloudEncryptionInfo) {
        userDefault.set(info.kdfSalt, forKey: Keys.kdfSalt.rawValue)
        userDefault.set(info.kdfParameters, forKey: Keys.kdfParameters.rawValue)
        userDefault.set(info.wrappedIdentifierKey, forKey: Keys.identifierKey.rawValue)
        userDefault.synchronize()
    }
}
