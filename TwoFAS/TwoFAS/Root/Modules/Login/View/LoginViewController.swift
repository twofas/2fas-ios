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

protocol LoginViewControlling: AnyObject {
    func prepareScreen(with title: String, isError: Bool, showReset: Bool, leftButtonTitle: String?)
    
    func setDots(number: Int)
    func fillDots(count: Int)
    func emptyDots()
    func shakeDots()
    
    func showDeleteButton()
    func hideDeleteButton()
    
    func hideNavigation()
    
    func lock(with message: String)
    func unlock()
}

final class LoginViewController: UIViewController {
    var presenter: LoginPresenter!
    
    private let verticalMargin: CGFloat = 30
    private let buttonsBottomMargin: CGFloat = 10
    
    private let titleLabel = UILabel()
    private let dots = PINPadCodeDots()
    private let PINPad = PINPadKeyboard()
    private let leftButton = UIButton()
    private let deleteButton = UIButton()
    private let numberFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let actionFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Theme.Colors.Fill.background
        
        prepareDescriptionLabel()
        
        let image = Asset.deleteCodeButton.image
            .withRenderingMode(.alwaysTemplate)
        deleteButton.setImage(image, for: .normal)
        deleteButton.tintColor = Theme.Colors.Controls.inactive
        deleteButton.accessibilityLabel = T.Voiceover.deleteButton
        
        setupLayout(imageWidth: image.size.width)
        
        leftButton.addTarget(self, action: #selector(leftButtonPressed), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        
        PINPad.numberButtonAction = { [weak self] number in
            self?.numberButtonPressed(number: number)
        }
        
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
}

extension LoginViewController: LoginViewControlling {
    func prepareScreen(with title: String, isError: Bool, showReset: Bool, leftButtonTitle: String?) {
        titleLabel.text = title
        VoiceOver.say(title)
        
        if isError {
            titleLabel.textColor = Theme.Colors.Text.theme
        } else {
            titleLabel.textColor = Theme.Colors.Text.main
        }
        
        if let buttonTitle = leftButtonTitle {
            decorateButtonText(withButton: leftButton, text: buttonTitle)
            showCloseButton()
        }
        
        if showReset {
            showResetButton()
        }
    }
    
    func setDots(number: Int) {
        dots.setDots(number: number)
    }
    
    func fillDots(count: Int) {
        dots.fillDots(count: count, animated: true)
    }
    
    func emptyDots() {
        dots.emptyDots(animated: true)
    }
    
    func shakeDots() {
        dots.shake()
    }
    
    func showDeleteButton() {
        deleteButton.isHidden = false
    }
    
    func hideDeleteButton() {
        deleteButton.isHidden = true
    }
    
    func lock(with message: String) {
        dots.alpha = Theme.Alpha.disabledElement
        PINPad.isUserInteractionEnabled = false
        PINPad.alpha = Theme.Alpha.disabledElement
        titleLabel.text = message
        VoiceOver.say(message)
    }
    
    func unlock() {
        dots.alpha = 1
        PINPad.isUserInteractionEnabled = true
        PINPad.alpha = 1
    }
    
    func hideNavigation() {
        hideCloseButton()
        hideDeleteButton()
    }
}

private extension LoginViewController {
    func showCloseButton() {
        leftButton.isHidden = false
    }
    
    func hideCloseButton() {
        leftButton.isHidden = true
    }
    
    func setupLayout(imageWidth: CGFloat) {
        let views = [titleLabel, dots, PINPad, leftButton, deleteButton]
        UIView.prepareViewsForAutoLayout(withViews: views, superview: view)
        
        let keySize = Theme.Metrics.PINButtonDimensionLarge
        let deleteButtonOffset = round((keySize - imageWidth) / 2.0)
        
        let topGuide = UILayoutGuide()
        let bottomGuide = UILayoutGuide()
                
        view.addLayoutGuide(topGuide)
        view.addLayoutGuide(bottomGuide)
        
        NSLayoutConstraint.activate([
            topGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.topAnchor.constraint(equalTo: topGuide.bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: PINPad.widthAnchor),
            dots.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: verticalMargin),
            dots.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            PINPad.topAnchor.constraint(equalTo: dots.bottomAnchor, constant: verticalMargin),
            PINPad.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomGuide.topAnchor.constraint(equalTo: PINPad.bottomAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: bottomGuide.bottomAnchor),
            leftButton.bottomAnchor.constraint(equalTo: PINPad.bottomAnchor, constant: -keySize / 4.0),
            leftButton.trailingAnchor.constraint(equalTo: PINPad.leadingAnchor, constant: keySize),
            deleteButton.bottomAnchor.constraint(equalTo: PINPad.bottomAnchor, constant: -deleteButtonOffset),
            deleteButton.trailingAnchor.constraint(equalTo: PINPad.trailingAnchor, constant: -deleteButtonOffset),
            bottomGuide.heightAnchor.constraint(equalTo: topGuide.heightAnchor),
            topGuide.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topGuide.widthAnchor.constraint(equalToConstant: 10),
            bottomGuide.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomGuide.widthAnchor.constraint(equalToConstant: 10)
        ])
    }
    
    func prepareDescriptionLabel() {
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.allowsDefaultTighteningForTruncation = true
        titleLabel.textAlignment = .center
        titleLabel.font = Theme.Fonts.Text.content
        titleLabel.textColor = Theme.Colors.Text.main
    }
    
    func decorateButtonText(withButton button: UIButton, text: String) {
        let basicAttributes = [
            NSAttributedString.Key.font: Theme.Fonts.Controls.title,
            NSAttributedString.Key.foregroundColor: Theme.Colors.Text.subtitle
        ]
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        paragraph.lineBreakMode = .byWordWrapping
        let completeAttributes = basicAttributes + [NSAttributedString.Key.paragraphStyle: paragraph]
        let attributedString = NSAttributedString(string: text, attributes: completeAttributes)
        button.setAttributedTitle(attributedString, for: .normal)
        
        var overAttributes = completeAttributes
        overAttributes[NSAttributedString.Key.foregroundColor] = Theme.Colors.Text.main
        let attributedStringOver = NSAttributedString(string: text, attributes: overAttributes)
        button.setAttributedTitle(attributedStringOver, for: .highlighted)
    }
    
    @objc
    func leftButtonPressed() {
        actionFeedback.impactOccurred()
        presenter.onClose()
    }
    
    @objc
    func deleteButtonPressed() {
        actionFeedback.impactOccurred()
        presenter.onDelete()
    }
    
    @objc
    func resetAction() {
        presenter.onReset()
    }
    
    func numberButtonPressed(number: Int) {
        numberFeedback.impactOccurred()
        presenter.onNumberInput(number)
    }
    
    func showResetButton() {
        var buttonConfiguration = UIButton.Configuration.borderless()
        buttonConfiguration.imagePadding = Theme.Metrics.doubleSpacing
        buttonConfiguration.image = Asset.infoIcon.image
        buttonConfiguration.baseForegroundColor = Theme.Colors.Controls.active
        buttonConfiguration.imagePlacement = .trailing
        var title = AttributedString(T.Restore.howToRestore)
        var container = AttributeContainer()
        container.font = Theme.Fonts.Text.content
        title.setAttributes(container)
        buttonConfiguration.attributedTitle = title
        buttonConfiguration.titleAlignment = .center
        
        let resetButton = UIButton(configuration: buttonConfiguration)
        resetButton.configurationUpdateHandler = { button in
            var config = button.configuration
            config?.baseForegroundColor = button.isHighlighted ?
            Theme.Colors.Controls.active :
            Theme.Colors.Controls.highlighed
            button.configuration = config
        }
        view.addSubview(resetButton, with: [
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -Theme.Metrics.doubleMargin),
            resetButton.leadingAnchor.constraint(
                equalTo: view.safeLeadingAnchor,
                constant: Theme.Metrics.standardMargin
            ),
            resetButton.trailingAnchor.constraint(
                equalTo: view.safeTrailingAnchor,
                constant: -Theme.Metrics.standardMargin
            )
        ])
        resetButton.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
    }
}
