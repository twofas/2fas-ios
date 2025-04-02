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

final class ComposeServiceFormInput: LimitedTextField {
    private let height: CGFloat = 40
    
    struct InputConfig {
        let canPaste: Bool
        let shouldUppercase: Bool
        let returnKeyType: UIReturnKeyType?
        let maxLength: Int?
        let autocapitalizationType: UITextAutocapitalizationType?
        let configTextField: LimitedTextField.Config
        let actionButtonTapped: Callback?

        init(
            canPaste: Bool,
            shouldUppercase: Bool,
            returnKeyType: UIReturnKeyType?,
            maxLength: Int?,
            autocapitalizationType: UITextAutocapitalizationType?,
            configTextField: LimitedTextField.Config = .none,
            actionButtonTapped: Callback? = nil
        ) {
            self.canPaste = canPaste
            self.shouldUppercase = shouldUppercase
            self.returnKeyType = returnKeyType
            self.maxLength = maxLength
            self.autocapitalizationType = autocapitalizationType
            self.configTextField = configTextField
            self.actionButtonTapped = actionButtonTapped
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh + 2, for: .horizontal)
        font = Theme.Fonts.Form.rowInput
        textColor = Theme.Colors.Form.rowInput
    }
    
    func configure(with config: InputConfig, text: String?) {
        super.configure(for: config.configTextField)
        
        actionButtonTapped = config.actionButtonTapped
        canPaste = config.canPaste
        shouldUppercase = config.shouldUppercase
        self.text = text
        if let rkt = config.returnKeyType {
            returnKeyType = rkt
        }
        maxLength = Theme.Consts.maxFieldLength
        if let act = config.autocapitalizationType {
            autocapitalizationType = act
        }
    }
    
    override var intrinsicContentSize: CGSize { CGSize(width: super.intrinsicContentSize.width, height: height) }
}
