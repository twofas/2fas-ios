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

final class PasswordTextField: LimitedTextField {
    typealias TextDidChange = (String) -> Void
    var didBecomeFirstResponder: Callback?
    
    var notAllowedCharacter: Callback?
    var isActive: Callback?
    var textDidChange: TextDidChange?
    var didResign: Callback?
    var verifyPassword = true
    
    override func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        let should = newString.length <= maxLength

        guard should else { return false }
        
        let matches = string.matches(ExportFileRules.regExp) || string.isBackspace
        
        if !matches && verifyPassword {
            notAllowedCharacter?()
        } else {
            textDidChange?(newString as String)
        }
        
        return matches || !verifyPassword
    }
    
    override func resignFirstResponder() -> Bool {
        let value = super.resignFirstResponder()
        if value {
            didResign?()
        }
        return value
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let value = super.becomeFirstResponder()
        if value {
            isActive?()
        }
        return value
    }
}
