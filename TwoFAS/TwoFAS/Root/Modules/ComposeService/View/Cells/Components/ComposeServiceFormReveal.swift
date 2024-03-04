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

final class ComposeServiceFormReveal: UIView {
    private let privateKey: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.Form.rowInput
        label.isUserInteractionEnabled = false
        return label
    }()
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(Theme.Colors.Controls.active, for: .normal)
        button.setTitleColor(Theme.Colors.Controls.highlighed, for: .highlighted)
        button.setTitleColor(Theme.Colors.Controls.inactive, for: .disabled)
        button.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()
    
    private var stack: ComposeServiceFormRow?
    
    var buttonPressed: Callback?
    
    enum State {
        case masked
        case copy(String)
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
        button.titleLabel?.font = Theme.Fonts.Controls.title
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        let stack = ComposeServiceFormRow(arrangedSubviews: [privateKey, button])
        
        addSubview(stack)
        stack.pinToParent()
        self.stack = stack
        
        changeState(newState: .masked)
    }
    
    func removeActionButton() {
        stack?.removeArrangedSubviews()
        stack?.addArrangedSubview(privateKey)
    }
    
    func changeState(newState: State) {
        switch newState {
        case .masked:
            privateKey.text = "•••••••••••••••"
            privateKey.accessibilityLabel = T.Voiceover.revealHiddenSecretKeyButtonTitle
            button.setTitle(nil, for: .normal)
            button.setImage(Asset.revealIcon.image
                .apply(Theme.Colors.Controls.active)?
                .withRenderingMode(.alwaysOriginal), for: .normal)
            button.setImage(Asset.revealIcon.image
                .apply(Theme.Colors.Controls.highlighed)?
                .withRenderingMode(.alwaysOriginal), for: .highlighted)
            button.accessibilityLabel = T.Voiceover.showServiceKey
            disable()
            
        case .copy(let privateKeyValue):
            privateKey.text = privateKeyValue
            privateKey.accessibilityLabel = privateKeyValue
            button.setTitle(T.Commons.copy, for: .normal)
            button.setImage(nil, for: .normal)
            button.setImage(nil, for: .highlighted)
            button.accessibilityLabel = T.Voiceover.copyServiceKey
            enable()
        }
    }
    
    @objc(buttonAction)
    private func buttonAction() {
        buttonPressed?()
    }
    
    private func enable() {
        privateKey.textColor = Theme.Colors.Form.rowInput
    }
    
    private func disable() {
        privateKey.textColor = Theme.Colors.Form.rowInputInactive
    }
}
