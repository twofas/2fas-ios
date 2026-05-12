//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

import SwiftUI
import CommonUI

@Observable
class PINPresenter {
    var totalDigits: Int = 0
    var enteredDigitCount: Int = 0
    
    var isBlocked = false
    
    private var pin: [Int] = [] {
        didSet {
            enteredDigitCount = pin.count
        }
    }
    
    func onKeyPressed(_ digit: TFPinKey) {
        guard !isBlocked else { return }
        if let number = digit.number, pin.count < totalDigits {
            pin.append(number)
            if pin.count >= totalDigits {
                allEntered()
            }
        } else if digit.isDelete {
            _ = pin.popLast()
        }
    }
    
    func onAppear() {
        setup()
    }
    
    func allEntered() {
        
    }
    
    func setup() {
        
    }
}
