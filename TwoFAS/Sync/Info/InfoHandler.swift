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
    private let allowedDevicesNone = "none"
    
    private enum Keys: String, CaseIterable {
        case metadata
        case modificationDate
        case version
        case encryptionReference
        case encryptionType
        case allowedDevices
        case enableWatch
    }
    private let userDefault = UserDefaults()
    private let zoneID: CKRecordZone.ID
    private let syncEncryptionHandler: SyncEncryptionHandling
    
    init(zoneID: CKRecordZone.ID, syncEncryptionHandler: SyncEncryptionHandling) {
        self.zoneID = zoneID
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
    }
    
    func createNew(encryptionReference: Data) -> CKRecord? { // first creation with default value
        InfoRecord.create(
            zoneID: zoneID,
            version: Info.version,
            encryption: Info.Encryption.system.rawValue,
            allowedDevices: [allowedDevicesNone],
            enableWatch: false,
            encryptionReference: encryptionReference,
            modificationDate: Date()
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
    }
    
    func prepareForSendoff() -> [CKRecord] {
        if let record = recreate() {
            return [record]
        }
        return []
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
        return InfoRecord.recreate(
            with: metadata,
            version: version,
            encryption: encryptionType.rawValue,
            allowedDevices: allowedDevices,
            enableWatch: enableWatch,
            encryptionReference: encryptionReference,
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
}
