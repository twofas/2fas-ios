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

final class UUIDInputField: UITextField, UITextFieldDelegate {
    private var length: UUIDInputLength = .four
    
    private var isFirst = false
    private var isLast = false
    
    var actionButtonTapped: Callback?
    var textChanged: ((String?) -> Void)?
    var overText: ((String) -> Void)?
    var overDelete: Callback?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        delegate = self
        
        smartDashesType = .no
        smartQuotesType = .no
        smartInsertDeleteType = .no
        autocorrectionType = .no
        spellCheckingType = .no
        keyboardType = .asciiCapable
        enablesReturnKeyAutomatically = true
        keyboardType = .asciiCapable
        autocapitalizationType = .allCharacters
        
        borderStyle = .none
        textColor = Theme.Colors.Text.main
        font = Theme.Fonts.Form.uuidInput
    }
    
    func setLength(_ length: UUIDInputLength) {
        self.length = length
        isFirst = length.isFirst
        isLast = length.isLast
        returnKeyType = length.returnKeyType
        placeholder = Array(repeating: "0", count: length.rawValue).joined()
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentString = textField.text! as NSString
        let newString = String(currentString.replacingCharacters(in: range, with: string))
            .replacingOccurrences(of: "-", with: "")
            .uppercased()
        
        guard newString.isUUIDCharacter else { return false }
        
        let should = newString.count <= length.rawValue
        
        guard should else {
            text = String(newString[0..<length.rawValue])
            if !isLast {
                let overflow = String(newString[length.rawValue...])
                overText?(overflow)
            }
            return false
        }
        
        if string.isUUIDCharacter {
            text = newString
            sendActions(for: .editingChanged)
            textChanged?(text)
            return false
        } else {
            return string.isBackspace
        }
    }
    
    override func deleteBackward() {
        let currentCount = text?.count ?? 0
        let isAtTheBeggining: Bool = {
            if let start = selectedTextRange?.start {
                return compare(start, to: beginningOfDocument) == .orderedSame
            }
            return false
        }()
        
        if isAtTheBeggining, !isFirst {
            overDelete?()
            return
        }
        
        if currentCount > 0 {
            super.deleteBackward()
            textChanged?(text)
            return
        }
        
        if !isFirst {
            overDelete?()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isLast {
            if textField.text?.count == length.rawValue {
                actionButtonTapped?()
                resignFirstResponder()
            }
            return true
        } else {
            resignFirstResponder()
        }
        return false
    }
    
    func carryDeletition() {
        becomeFirstResponder()
        deleteBackward()
    }
    
    func carryOverflow(_ string: String?) {
        guard var string else {
            text = nil
            return
        }
        
        guard string.isUUIDCharacter else { return }
        
        var overflow: String?
        
        let total = (string + (text ?? "")).uppercased()
        
        if total.count > length.rawValue {
            string = total[0..<length.rawValue]
            overflow = String(total[length.rawValue...])
        } else {
            string = total
        }
        
        becomeFirstResponder()
        text = string
        sendActions(for: .editingChanged)
        textChanged?(text)
        
        if let overflow, !isLast {
            overText?(overflow)
        }
    }
    
    func setTextAndDisable(_ text: String) {
        self.text = text
        self.isEnabled = false
        self.textColor = Theme.Colors.Text.inactive
    }
}

extension UUIDInputLength {
    var isFirst: Bool {
        switch self {
        case .four: return false
        case .eight: return true
        case .twelve: return false
        }
    }
    
    var isLast: Bool {
        switch self {
        case .four: return false
        case .eight: return false
        case .twelve: return true
        }
    }
    
    var returnKeyType: UIReturnKeyType {
        switch self {
        case .four: return .done
        case .eight: return .done
        case .twelve: return .send
        }
    }
}
