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

public protocol ProtectionInteracting: AnyObject {
    var isPINSet: Bool { get }
    var isBiometryEnabled: Bool { get }
    var isBiometryAvailable: Bool { get }
    var pinType: PINType? { get }
    var currentCodeLength: Int { get }
    var biometryType: BiometryType { get }
    
    func disableBiometry()
    func enableBiometry()
    func setPINOff()
    func savePIN(_ PIN: String, typeOfPIN: PINType)
    func validatePIN(_ PIN: String) -> Bool
    func isPINCorrect(_ PIN: [Int]) -> Bool
}

final class ProtectionInteractor {
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension ProtectionInteractor: ProtectionInteracting {
    var isPINSet: Bool {
        mainRepository.isPINSet
    }
    
    var isBiometryEnabled: Bool {
        mainRepository.isBiometryEnabled
    }
    
    var isBiometryAvailable: Bool {
        mainRepository.isBiometryAvailable
    }
    
    var pinType: PINType? {
        mainRepository.pinType
    }
    
    var currentCodeLength: Int {
        mainRepository.currentCodeLength
    }
            
    var biometryType: BiometryType {
        mainRepository.biometryType
    }
    
    func disableBiometry() {
        Log("ProtectionInteractor - disableBiometry", module: .interactor)
        mainRepository.disableBiometry()
    }
    
    func enableBiometry() {
        Log("ProtectionInteractor - enableBiometry", module: .interactor)
        mainRepository.enableBiometry()
    }
    
    func setPINOff() {
        Log("ProtectionInteractor - setPINOff", module: .interactor)
        mainRepository.setPINOff()
    }
    
    func savePIN(_ PIN: String, typeOfPIN: PINType) {
        Log("ProtectionInteractor - savePIN", module: .interactor)
        mainRepository.savePIN(PIN, typeOfPIN: typeOfPIN)
    }
    
    func validatePIN(_ PIN: String) -> Bool {
        Log("ProtectionInteractor - validatePIN", module: .interactor)
        return mainRepository.validatePIN(PIN)
    }
    
    func isPINCorrect(_ PIN: [Int]) -> Bool {
        mainRepository.isPINCorrect(PIN)
    }
}
