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

protocol WebExtensionLocalDeviceNameInteracting: AnyObject {
    var currentDeviceName: String { get }
    func setNewDeviceName(_ newName: String)
}

final class WebExtensionLocalDeviceNameInteractor {
    private let mainRepository: MainRepository
        
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension WebExtensionLocalDeviceNameInteractor: WebExtensionLocalDeviceNameInteracting {
    var currentDeviceName: String {
        if let savedDeviceName = mainRepository.savedDeviceName {
            return savedDeviceName
        }
        let generated = mainRepository.getProposedDeviceName
        mainRepository.saveNewDeviceName(generated)
        return generated
    }
    
    func setNewDeviceName(_ newName: String) {
        Log("WebExtensionLocalDeviceNameInteractor - set new device name: \(newName)", module: .interactor)
        mainRepository.saveNewDeviceName(newName)
    }
}
