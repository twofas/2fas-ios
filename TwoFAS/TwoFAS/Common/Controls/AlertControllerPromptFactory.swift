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

enum AlertControllerPromptFactory {
    enum InputConfiguration {
        case name
        case intNumber
    }
    static func create(
        title: String,
        message: String?,
        actionName: String,
        defaultText: String?,
        inputConfiguration: InputConfiguration,
        action: @escaping (String) -> Void,
        cancel: Callback?,
        verify: ((String) -> Bool)?
    ) -> UIAlertController {
        let alert = AlertControllerPrompt(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: T.Commons.cancel, style: .cancel) { _ in
            cancel?()
        }
        
        let textAction = UIAlertAction(title: actionName, style: .default) { _ in
            guard let tf = alert.textFields?.first, let text = tf.text else { return }
            action(text)
        }
        
        alert.verify = verify
        alert.addAction(cancelAction, type: .cancel)
        alert.addAction(textAction, type: .textAction)
        switch inputConfiguration {
        case .name: alert.configureTextFieldName(defaultText: defaultText)
        case .intNumber: alert.configureTextFieldIntNumber(defaultText: defaultText)
        }
        
        return alert
    }
}

final class AlertControllerPrompt: UIAlertController {
    private var textAction: UIAlertAction?
    var verify: ((String) -> Bool)?
    
    enum ActionType {
        case cancel
        case textAction
    }
    
    func addAction(_ action: UIAlertAction, type: ActionType) {
        switch type {
        case .cancel:
            addAction(action)
        case .textAction:
            textAction = action
            addAction(action)
        }
    }
    
    func configureTextFieldName(defaultText: String?) {
        addTextField { [weak self] tx in
            tx.text = defaultText
            tx.autocapitalizationType = .words
            tx.selectedTextRange = tx.textRange(from: tx.beginningOfDocument, to: tx.endOfDocument)
            tx.addTarget(self, action: #selector(self?.textChanged(sender:)), for: .editingChanged)
        }
        
        textAction?.isEnabled = !(defaultText == nil || defaultText?.isEmpty == true)
    }
    
    func configureTextFieldIntNumber(defaultText: String?) {
        addTextField { [weak self] tx in
            tx.placeholder = defaultText
            tx.autocapitalizationType = .none
            tx.keyboardType = .numberPad
            tx.addTarget(self, action: #selector(self?.textChanged(sender:)), for: .editingChanged)
        }
        
        textAction?.isEnabled = !(defaultText == nil || defaultText?.isEmpty == true)
    }
    
    @objc private func textChanged(sender: UITextField) {
        if let text = sender.text, !text.isEmpty {
            if let v = verify {
                textAction?.isEnabled = v(text)
            } else {
                textAction?.isEnabled = true
            }
        } else {
            textAction?.isEnabled = false
        }
    }
}

extension UIAlertController {
    static func makeSimple(
        with title: String,
        message: String,
        buttonTitle: String = T.Commons.ok,
        finished: Callback? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .cancel) { _ in finished?() })
        return alert
    }
}
