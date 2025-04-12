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

public protocol WatchPairingInteracting: AnyObject {
    var canModify: Bool { get }
    func list() -> [PairedWatch]
    func unpair(_ pairedWatch: PairedWatch)
    func rename(_ pairedWatch: PairedWatch, newName: String)
    func pair(deviceCodePath: DeviceCodePath, deviceName: String)
}

final class WatchPairingInteractor {
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension WatchPairingInteractor: WatchPairingInteracting {
    var canModify: Bool {
        mainRepository.isCloudBackupSynced && mainRepository.cloudCurrentEncryption == .user
    }
    
    func list() -> [PairedWatch] {
        mainRepository.watchPairingList()
    }
    
    func unpair(_ pairedWatch: PairedWatch) {
        mainRepository.watchPairingUnpair(pairedWatch)
    }
    
    func rename(_ pairedWatch: PairedWatch, newName: String) {
        mainRepository.watchPairingRename(pairedWatch, newName: newName)
    }
    
    func pair(deviceCodePath: DeviceCodePath, deviceName: String) {
        mainRepository.watchPairingPair(deviceCodePath: deviceCodePath, deviceName: deviceName)
    }
}
