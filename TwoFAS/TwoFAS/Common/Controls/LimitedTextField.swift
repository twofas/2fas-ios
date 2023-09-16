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

class LimitedTextField: UITextField, UITextFieldDelegate {
    // swiftlint:disable discouraged_none_name
    enum Config {
        case none
        case email
        case number
        case key
        case label
        case password
    }
    // swiftlint:enable discouraged_none_name
    
    var actionButtonTapped: Callback?
    var shouldUppercase = false
    var canPaste = true
    
    private var maxLengthOfText: Int = 1000
    private var config: Config = .none
    
    var maxLength: Int {
        get { maxLengthOfText }
        set { maxLengthOfText = newValue }
    }
    
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
        borderStyle = .none
        
        smartDashesType = .no
        smartQuotesType = .no
        smartInsertDeleteType = .no
        autocorrectionType = .no
        spellCheckingType = .no
        keyboardType = .asciiCapable
        enablesReturnKeyAutomatically = true
        textColor = Theme.Colors.Text.main
        font = Theme.Fonts.Form.rowInput
    }
    
    func enable() {
        isEnabled = true
        textColor = Theme.Colors.Text.main
    }
    
    func disable() {
        isEnabled = false
        textColor = Theme.Colors.Text.inactive
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        let isWhitespace: Bool = {
            let str = String(newString)
            return str.count == 1 && str.first?.isWhitespace == true
        }()
        let should = newString.length <= maxLengthOfText && !isWhitespace
        
        guard should else { return false }
        
        switch config {
        case .none:
            if string.rangeOfCharacter(from: .lowercaseLetters) != nil && shouldUppercase {
                text = (text ?? "") + string.uppercased()
                sendActions(for: .editingChanged)
                textDidChange(newString: (text ?? ""))
                return false
            }
            textDidChange(newString: newString as String)
        case .number:
            if string.rangeOfCharacter(from: .decimalDigits) != nil {
                textDidChange(newString: newString as String)
                return true
            } else {
                return string.isBackspace
            }
        case .key:
            let s = string.uppercased()
            
            if (s.isASCIILetter || s.isNumber) && shouldUppercase {
                text = (text ?? "") + s
                sendActions(for: .editingChanged)
                textDidChange(newString: (text ?? ""))
                return false
            } else {
                return string.isBackspace
            }
        case .label:
            let s = string.uppercased()
            
            if s.isValidLabel {
                text = (text ?? "") + s
                sendActions(for: .editingChanged)
                textDidChange(newString: (text ?? ""))
                return false
            } else {
                return string.isBackspace
            }
        default:
            textDidChange(newString: newString as String)
        }
        
        return true
    }
    
    override func deleteBackward() {
        let currentCount = text?.count ?? 0
        
        super.deleteBackward()
        
        let countAfterDeletition = text?.count ?? 0
        if currentCount != countAfterDeletition {
            textDidChange(newString: text ?? "")
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard !canPaste else { return super.canPerformAction(action, withSender: sender) }
        
        switch action {
        case #selector(UIResponderStandardEditActions.copy(_:)),
            #selector(UIResponderStandardEditActions.cut(_:)):
            return false
            
        default:
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        actionButtonTapped?()
        return true
    }
    
    func configure(for config: Config) {
        self.config = config
        
        switch config {
        case .email:
            maxLengthOfText = 256
            returnKeyType = .continue
            autocapitalizationType = .none
            canPaste = true
            shouldUppercase = false
            textContentType = .emailAddress
            keyboardType = .emailAddress
        case .number:
            returnKeyType = .continue
            autocapitalizationType = .none
            canPaste = true
            shouldUppercase = false
            keyboardType = .numberPad
        case .key:
            maxLengthOfText = 256
            returnKeyType = .next
            autocapitalizationType = .allCharacters
            canPaste = true
            shouldUppercase = true
            keyboardType = .asciiCapable
        case .label:
            maxLengthOfText = ServiceRules.labelMaxLength
            returnKeyType = .done
            autocapitalizationType = .allCharacters
            canPaste = false
            shouldUppercase = true
            keyboardType = .default
        case .password:
            autocapitalizationType = .none
            canPaste = true
            shouldUppercase = false
            keyboardType = .asciiCapable
        case .none:
            break
        }
    }
    
    func textDidChange(newString: String) {}
}
