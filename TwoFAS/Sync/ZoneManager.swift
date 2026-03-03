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
import CloudKit
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

protocol ZoneManaging: AnyObject {
    var inOldVault: Bool { get }
    var currentZoneID: CKRecordZone.ID { get }
}

final class ZoneManager: ZoneManaging {
    private(set) var currentZoneID: CKRecordZone.ID
    
    init() {
        currentZoneID = CKRecordZone.ID(zoneName: Config.vaultV2, ownerName: CKCurrentUserDefaultName)
        Log("ZoneManager: Default zone is \(Config.vaultV2)", module: .cloudSync)
    }
    
    var inOldVault: Bool {
        currentZoneID.zoneName == Config.vaultV1
    }
    
    func setCurrentZoneID(_ zoneName: String) {
        Log("ZoneManager: Changing zone to \(zoneName)", module: .cloudSync)
        currentZoneID = CKRecordZone.ID(zoneName: zoneName, ownerName: CKCurrentUserDefaultName)
    }
}
