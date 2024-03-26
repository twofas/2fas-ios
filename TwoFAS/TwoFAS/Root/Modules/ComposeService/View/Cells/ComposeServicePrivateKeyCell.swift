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

final class ComposeServicePrivateKeyCell: UITableViewCell, ComposeServiceInputCellKind {
    static let identifier = "ComposeServicePrivateKeyCell"
    
    var didUpdateValue: ((ComposeServiceInputKind, String?) -> Void)?
    var didSelectActionButton: ((ComposeServiceInputKind) -> Void)?
    var revealButtonAction: Callback?
    
    private let titleLabel = ComposeServiceFormRowTitleLabel()
    private let privateKeyInput = ComposeServiceFormInput()
    private let privateKeyReveal = ComposeServiceFormReveal()
    private let privateKeyError = ComposeServiceFormError()
    
    private var privateKeyKind: ComposeServicePrivateKeyKind = .empty
    
    let kind: ComposeServiceInputKind? = .privateKey
    
    var value: String? {
        get { privateKeyInput.text }
        set { privateKeyInput.text = newValue }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = Theme.Colors.SettingsCell.background
        
        titleLabel.didTap = { [weak self] in
            guard let self else { return }
            if self.privateKeyKind == .empty {
                self.privateKeyInput.becomeFirstResponder()
            }
        }
        titleLabel.accessibilityTraits = .header
        titleLabel.text = T.Tokens.serviceKey
        
        privateKeyInput.addTarget(self, action: #selector(valueDidChanged), for: .editingChanged)
        privateKeyInput.actionButtonTapped = { [weak self] in self?.actionButton() }
        
        let stackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.distribution = .equalSpacing
            stack.spacing = 0
            stack.alignment = .fill
            return stack
        }()
        
        contentView.addSubview(stackView, with: [
            stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
        
        let row = ComposeServiceFormRow(arrangedSubviews: [titleLabel, privateKeyInput, privateKeyReveal])
        stackView.addArrangedSubviews([
            row,
            privateKeyError
        ])
        
        privateKeyInput.configure(
            with: ComposeServiceFormInput.InputConfig(
                canPaste: false,
                shouldUppercase: true,
                returnKeyType: .next,
                maxLength: ServiceRules.privateKeyMaxLength,
                autocapitalizationType: UITextAutocapitalizationType.none
            ),
            text: nil
        )
        privateKeyInput.accessibilityHint = T.Voiceover.secretHint
        privateKeyReveal.buttonPressed = { [weak self] in self?.revealButtonAction?() }
        privateKeyError.isHidden = true
        
        selectionStyle = .none
    }
    
    @objc
    private func valueDidChanged() {
        if let text = privateKeyInput.text, text != text.removeWhitespaces() {
            privateKeyInput.text = text.removeWhitespaces()
        }
        
        didUpdateValue?(kind!, privateKeyInput.text)
    }
    
    private func actionButton() {
        didSelectActionButton?(kind!)
    }
    
    override func becomeFirstResponder() -> Bool {
        privateKeyInput.becomeFirstResponder()
    }
    
    func configure(privateKeyKind: ComposeServicePrivateKeyKind) {
        self.privateKeyKind = privateKeyKind
        
        switch privateKeyKind {
        case .empty:
            privateKeyInput.isHidden = false
            privateKeyReveal.isHidden = true
            titleLabel.setTitleForRequiredValue(T.Tokens.serviceKey)
        case .hidden:
            privateKeyInput.isHidden = true
            privateKeyReveal.isHidden = false
        case .hiddenNonCopyable:
            privateKeyInput.isHidden = true
            privateKeyReveal.isHidden = false
            privateKeyReveal.removeActionButton()
        }
    }
    
    func showError(_ error: String) {
        privateKeyError.text = error
        privateKeyError.isHidden = false
    }
    
    override var isFirstResponder: Bool {
        privateKeyInput.isFirstResponder
    }
    
    func hideError() {
        privateKeyError.isHidden = true
    }
    
    func setRevealState(state: ComposeServiceFormReveal.State) {
        privateKeyReveal.changeState(newState: state)
    }
}
