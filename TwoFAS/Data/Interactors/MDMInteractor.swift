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

public protocol MDMInteracting: AnyObject {
    var isBackupBlocked: Bool { get }
    var isBiometryBlocked: Bool { get }
    var isBrowserExtensionBlocked: Bool { get }
    
    func apply()
}

final class MDMInteractor {
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension MDMInteractor: MDMInteracting {
    var isBackupBlocked: Bool {
        mainRepository.mdmIsBackupBlocked
    }
    
    var isBiometryBlocked: Bool {
        mainRepository.mdmIsBiometryBlocked
    }
    
    var isBrowserExtensionBlocked: Bool {
        mainRepository.mdmIsBrowserExtensionBlocked
    }
    
    func apply() {
        if isBackupBlocked, mainRepository.isCloudBackupConnected {
            mainRepository.clearBackup()
        }
        
        if mainRepository.isBiometryEnabled {
            mainRepository.disableBiometry()
        }
    }
}
