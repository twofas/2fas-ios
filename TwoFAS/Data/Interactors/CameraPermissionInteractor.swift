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

import UIKit
import Common

public protocol CameraPermissionInteracting: AnyObject, PermissionsStateChildDataControllerProtocol {
    var isCameraAvailable: Bool { get }
    var isCameraAllowed: Bool { get }
    func checkPermission(result: @escaping ((Bool) -> Void))
    func register(callback: ((CameraPermissionState) -> Void)?)
    func checkState()
}

final class CameraPermissionInteractor {
    private let mainRepository: MainRepository
    private var shouldAskForCamera: Bool { mainRepository.permission == .unknown }
    
    var isCameraAvailable: Bool { mainRepository.isCameraPresent && (shouldAskForCamera || isCameraAllowed) }
    var isCameraAllowed: Bool {
        mainRepository.isCameraPresent
        && mainRepository.permission == .granted
    }
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension CameraPermissionInteractor: CameraPermissionInteracting {
    func register(callback: ((CameraPermissionState) -> Void)?) {
        mainRepository.requestPermission { state in
            Log("CameraPermissionInteractor. Camera register - request permission: \(state)", module: .interactor)
            callback?(state)
        }
    }
    
    func checkPermission(result: @escaping ((Bool) -> Void)) {
        Log("CameraPermissionInteractor - checkPermission", module: .interactor)
        if isCameraAllowed {
            Log("CameraPermissionInteractor - camera allowed", module: .interactor)
            result(true)
            return
        }
        
        Log("CameraPermissionInteractor - requestPermission", module: .interactor)
        
        mainRepository.requestPermission { state in
            guard state == .granted else {
                Log("CameraPermissionInteractor - requestPermission - failure. No access", module: .interactor)
                result(false)
                return
            }
            
            Log("CameraPermissionInteractor - requestPermission - granted!", module: .interactor)
            
            result(true)
        }
    }
    
    func checkState() {
        let state = mainRepository.checkForPermission()
        Log("CameraPermissionInteractor. Camera permission state: \(state)", module: .interactor)
    }
}
