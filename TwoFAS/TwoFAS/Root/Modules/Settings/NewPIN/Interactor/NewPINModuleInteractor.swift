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
import Data
import Common

protocol NewPINModuleInteracting: AnyObject {
    var selectedPIN: String? { get set }
    var selectedPINType: PINType? { get set }
    
    var lockNavigation: Bool { get }
    
    var pinType: PINType { get }
    
    func validatePIN(_ PIN: String) -> Bool
    func setPINType(_ pinType: PINType)
}

final class NewPINModuleInteractor {
    let lockNavigation: Bool
    var selectedPIN: String?
    var selectedPINType: PINType?
    
    init(lockNavigation: Bool, selectedPIN: String? = nil, selectedPINType: PINType? = nil) {
        self.lockNavigation = lockNavigation
        self.selectedPIN = selectedPIN
        self.selectedPINType = selectedPINType
    }
}

extension NewPINModuleInteractor: NewPINModuleInteracting {
    var pinType: PINType {
        selectedPINType ?? .digits4
    }
    
    func validatePIN(_ PIN: String) -> Bool {
        guard let selectedPIN else { return false }
        return PIN == selectedPIN
    }
    
    func setPINType(_ pinType: PINType) {
        selectedPINType = pinType
    }
}
