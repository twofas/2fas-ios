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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

final class SyncTokenHandler {
    private var databaseChangeToken: CKServerChangeToken?
    private var zoneChangeToken: CKServerChangeToken?
    private var notificationsInitiated: Bool?
    private var zoneInitiated: Bool?
    
    func setDatabaseChangeToken(_ databaseChangeToken: CKServerChangeToken) {
        Log("SyncTokenHandler: - setDatabaseChangeToken", module: .cloudSync)
        self.databaseChangeToken = databaseChangeToken
    }
    
    func setZoneChangeToken(_ zoneChangeToken: CKServerChangeToken) {
        Log("SyncTokenHandler: - setZoneChangeToken", module: .cloudSync)
        self.zoneChangeToken = zoneChangeToken
    }
    
    func setNotificationsInitiated() {
        Log("SyncTokenHandler: - setNotificationsInitiated", module: .cloudSync)
        self.notificationsInitiated = true
    }
    
    func setZoneInitiated() {
        Log("SyncTokenHandler: - zoneInitiated", module: .cloudSync)
        self.zoneInitiated = true
    }
    
    func commitChanges() {
        Log("SyncTokenHandler: - commitChanges", module: .cloudSync)
        
        if let databaseChangeToken {
            ConstStorage.databaseChangeToken = databaseChangeToken
        }
        if let zoneChangeToken {
            ConstStorage.zoneChangeToken = zoneChangeToken
        }
        if let notificationsInitiated {
            ConstStorage.notificationsInitiated = notificationsInitiated
        }
        if let zoneInitiated {
            ConstStorage.zoneInitiated = zoneInitiated
        }
        
        clearAll()
    }
    
    func clearZone() {
        Log("SyncTokenHandler: - clear zone", module: .cloudSync)
        clearAll()
        ConstStorage.clearZone()
    }
    
    func prepare() {
        Log("SyncTokenHandler: - prepare", module: .cloudSync)
        clearAll()
    }
    
    private func clearAll() {
        databaseChangeToken = nil
        zoneChangeToken = nil
        notificationsInitiated = nil
        zoneInitiated = nil
    }
}
