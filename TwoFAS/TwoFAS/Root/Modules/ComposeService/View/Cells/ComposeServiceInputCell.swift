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

final class ComposeServiceInputCell: UITableViewCell, ComposeServiceInputCellKind {
    static let identifier = "ComposeServiceInputCell"
    
    var didUpdateValue: ((ComposeServiceInputKind, String?, Bool) -> Void)?
    var didSelectActionButton: ((ComposeServiceInputKind) -> Void)?
    
    private let titleLabel = ComposeServiceFormRowTitleLabel()
    private let input = ComposeServiceFormInput()
    private let errorLabel = ComposeServiceFormError()
    private let containerView = UIView()
    private(set) var kind: ComposeServiceInputKind?
    
    private var maxLength: Int?
    
    var isInputFirstResponder: Bool {
        input.isFirstResponder
    }
    
    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = Theme.Metrics.halfSpacing
        stack.alignment = .fill
        return stack
    }()
    
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
        
        titleLabel.didTap = { [weak self] in self?.input.becomeFirstResponder() }
        titleLabel.accessibilityTraits = .header
        
        input.addTarget(self, action: #selector(valueDidChanged), for: .editingChanged)
        input.actionButtonTapped = { [weak self] in self?.actionButton() }
        
        let stackView = ComposeServiceFormRow(arrangedSubviews: [titleLabel, input])
        contentView.addSubview(verticalStack, with: [
            verticalStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
        verticalStack.addArrangedSubviews([
            stackView,
            containerView
        ])
        
        containerView.addSubview(errorLabel)
        errorLabel.pinToParent()
        
        containerView.isHidden = true
        
        selectionStyle = .none
    }
    
    @objc
    private func valueDidChanged() {
        guard let kind else { return }

        let visible = !containerView.isHidden
        var changed = false
        
        if let maxLength, let text = input.text, text.count > maxLength {
            showError(T.Commons.textLongTitle(maxLength))
            if !visible {
                changed = true
            }
        } else {
            hideError()
            if visible {
                changed = true
            }
        }
        
        didUpdateValue?(kind, input.text, changed)
    }
    
    private func actionButton() {
        guard let kind else { return }
        
        didSelectActionButton?(kind)
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        input.becomeFirstResponder()
    }
    
    func selectAllText() {
        input.selectAll(nil)
    }
    
    func configure(
        title: String?,
        value: String?,
        kind: ComposeServiceInputKind,
        inputConfig: ComposeServiceFormInput.InputConfig,
        isRequired: Bool
    ) {
        if let title, isRequired {
            titleLabel.setTitleForRequiredValue(title)
        } else {
            titleLabel.text = title
        }
        titleLabel.isHidden = title == nil
        self.kind = kind
        maxLength = inputConfig.maxLength
        input.configure(with: inputConfig, text: value)
        hideError()
    }
    
    func showError(_ error: String) {
        errorLabel.text = error
        containerView.isHidden = false
        invalidateIntrinsicContentSize()
    }
    
    func hideError() {
        containerView.isHidden = true
        invalidateIntrinsicContentSize()
    }
}
