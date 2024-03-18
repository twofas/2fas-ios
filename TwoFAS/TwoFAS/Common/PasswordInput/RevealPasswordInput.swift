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

final class RevealPasswordInput: UIView {
    enum Order {
        case single
        case first
        case last
    }
    
    var completeAction: Callback?
    var revealAction: Callback?
    var didChangeValue: ((String) -> Void)?
    var isActive: Callback?
    var notAllowedCharacter: Callback?
    var didResign: Callback?
    
    var order: Order = .single {
        didSet {
            switch order {
            case .single, .last: input.returnKeyType = .continue
            case .first: input.returnKeyType = .next
            }
        }
    }
    
    var inputIsActive: Bool {
        input.isFirstResponder
    }
    
    var currentInput: String {
        input.text ?? ""
    }
    
    var verifyPassword: Bool {
        get {
            input.verifyPassword
        }
        
        set {
            input.verifyPassword = newValue
        }
    }
    
    private let lineHeight: CGFloat = 25
    
    private let titleLabel = TitleLabel()
    private let input = PasswordTextField()
    private let line = FormLine()
    private let errorLabel = ErrorLabel()
    private let showButton = ShowButton()
    
    private let horizontalContainer = UIView()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .equalSpacing
        sv.alignment = .fill
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(stackView)
        stackView.pinToParent(with: UIEdgeInsets(
            top: Theme.Metrics.standardMargin,
            left: 0,
            bottom: Theme.Metrics.standardMargin,
            right: 0
        ))
        
        stackView.addArrangedSubviews([
            titleLabel,
            horizontalContainer,
            line,
            errorLabel
        ])
        stackView.setCustomSpacing(Theme.Metrics.standardMargin, after: titleLabel)
        stackView.setCustomSpacing(Theme.Metrics.standardMargin, after: line)
        
        let margin = Theme.Metrics.doubleMargin
        
        horizontalContainer.addSubview(input, with: [
            input.leadingAnchor.constraint(equalTo: horizontalContainer.leadingAnchor),
            input.topAnchor.constraint(equalTo: horizontalContainer.topAnchor),
            input.bottomAnchor.constraint(equalTo: horizontalContainer.bottomAnchor),
            input.heightAnchor.constraint(equalToConstant: lineHeight)
        ])
        horizontalContainer.addSubview(showButton, with: [
            showButton.trailingAnchor.constraint(equalTo: horizontalContainer.trailingAnchor),
            showButton.topAnchor.constraint(equalTo: horizontalContainer.topAnchor),
            showButton.bottomAnchor.constraint(equalTo: horizontalContainer.bottomAnchor),
            showButton.heightAnchor.constraint(equalToConstant: lineHeight),
            showButton.widthAnchor.constraint(equalToConstant: lineHeight),
            input.trailingAnchor.constraint(equalTo: showButton.leadingAnchor, constant: -margin)
        ])
        
        showButton.didTapAction = { [weak self] in self?.toggleState() }
        input.actionButtonTapped = { [weak self] in self?.completeAction?() }
        
        input.returnKeyType = .continue
        input.font = Theme.Fonts.iconLabelInputTitle
        input.maxLength = ExportFileRules.maxLength
        input.isActive = { [weak self] in self?.isActive?() }
        input.didResign = { [weak self] in self?.didResign?() }
        input.textDidChange = { [weak self] in self?.didChangeValue?($0) }
        input.notAllowedCharacter = { [weak self] in self?.notAllowedCharacter?() }
        
        setRevealState(isPassHidden: true)
    }
    
    private func toggleState() {
        revealAction?()
    }
    
    func setRevealState(isPassHidden: Bool) {
        showButton.showIconVisible(isVisible: !isPassHidden)
        input.isSecureTextEntry = isPassHidden
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func hideError() {
        errorLabel.isHidden = true
        errorLabel.text = nil
    }
    
    func showError(_ error: String) {
        errorLabel.text = error
        errorLabel.isHidden = false
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return input.resignFirstResponder()
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return input.becomeFirstResponder()
    }
    
    override var intrinsicContentSize: CGSize { CGSize(width: UIView.noIntrinsicMetric, height: lineHeight) }
}

private final class TitleLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        font = Theme.Fonts.Text.info
        textColor = Theme.Colors.Text.main
    }
}

private final class ErrorLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        font = Theme.Fonts.Text.info
        textColor = Theme.Colors.Text.error
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
    }
}

private final class ShowButton: UIView {
    var didTapAction: Callback?
    
    private let size: CGSize = .init(width: 25, height: 25)
    
    private let showIcon = UIImageView(image: Asset.passwordHide.image)
    private let hideIcon = UIImageView(image: Asset.passwordReveal.image)
    
    private let container = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(container, with: [
            leadingAnchor.constraint(equalTo: container.leadingAnchor),
            trailingAnchor.constraint(equalTo: container.trailingAnchor),
            topAnchor.constraint(equalTo: container.topAnchor),
            bottomAnchor.constraint(equalTo: container.bottomAnchor),
            container.widthAnchor.constraint(equalToConstant: size.width),
            container.heightAnchor.constraint(equalToConstant: size.height)
        ])
        
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        
        container.addSubview(showIcon)
        showIcon.pinToParent()
        
        container.addSubview(hideIcon)
        hideIcon.pinToParent()
        
        showIcon.tintColor = Theme.Colors.Icon.theme
        hideIcon.tintColor = Theme.Colors.Icon.theme
        
        showIcon.contentMode = .center
        hideIcon.contentMode = .center
        
        showIconVisible(isVisible: true)
    }
    
    func showIconVisible(isVisible: Bool) {
        showIcon.isHidden = !isVisible
        hideIcon.isHidden = isVisible
    }
    
    @objc(didTap)
    private func didTap() {
        didTapAction?()
    }
    
    override var intrinsicContentSize: CGSize { size }
}
