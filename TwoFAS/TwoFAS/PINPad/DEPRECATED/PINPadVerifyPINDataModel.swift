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

final class PINPadVerifyPINDataModel: PINPadDataModelProtocol {
    enum VerifyType {
        case login
        case current
    }
    
    typealias CheckCode = ([Int]) -> Bool
    var checkCode: CheckCode?
    private(set) var codeLength: Int = 0
    
    private let verifyType: VerifyType
    private let leftButtonDescription: String?
    
    init (verifyType: VerifyType, leftButtonDescription: String? = nil) {
        self.verifyType = verifyType
        self.leftButtonDescription = leftButtonDescription
    }
    
    func setCodeLenght(_ newCodeLenght: Int) {
        codeLength = newCodeLenght
    }
    
    var screenTitle: String {
        switch verifyType {
        case .current:
            return T.Security.enterCurrentPin
        case .login:
            return T.Security.enterPin
        }
    }
    
    var invalidInput: (() -> Void)?
    
    var leftButton: String? {
        leftButtonDescription
    }
    
    func PINGathered(numbers: [Int]) {
        guard let checkCode else { assertionFailure(); return }
        
        if !checkCode(numbers) {
            invalidInput?()
        }
    }
}
