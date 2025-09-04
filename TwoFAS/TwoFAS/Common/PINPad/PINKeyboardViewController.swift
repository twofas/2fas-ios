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

protocol PINKeyboardViewControlling: AnyObject {
    func prepareScreen(with screenTitle: String, titleType: PINKeyboardViewController.TitleType)
    func prepareLeftButton(buttonTitle: String?)
    
    func setDots(number: Int)
    func fillDots(count: Int)
    func emptyDots()
    
    func shakeDots()
    
    func showLeftButton()
    func hideLeftButton()
    
    func showDeleteButton()
    func hideDeleteButton()
    
    func lock(withMessage message: String)
    func unlock()
    
    func showBottomButton(with title: String)
}

/// Class intended to be inherited in proper VC with custom actions associated with PIN keyboard
class PINKeyboardViewController: UIViewController {
    enum TitleType {
        case normal
        case error
    }
    
    private lazy var verticalMargin: CGFloat = {
        if UIDevice.isSmallScreen {
            return 20
        }
        return 30
    }()
    private let buttonsBottomMargin: CGFloat = 10
    
    private let titleLabel = UILabel()
    private let dots = PINPadCodeDots()
    private let PINPad = PINPadKeyboard()
    private let leftButton = UIButton()
    private let deleteButton = UIButton()
    private let numberFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let actionFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    private let backspaceCharacter = "\u{8}"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Theme.Colors.Fill.background
        
        prepareDescriptionLabel()
        
        let views = [titleLabel, dots, PINPad, leftButton, deleteButton]
        UIView.prepareViewsForAutoLayout(withViews: views, superview: view)
        
        let image = Asset.deleteCodeButton.image
            .withRenderingMode(.alwaysTemplate)
        deleteButton.setImage(image, for: .normal)
        deleteButton.tintColor = Theme.Colors.Controls.inactive
        
        let keySize = Theme.Metrics.PINButtonDimensionLarge
        let deleteButtonOffset = round((keySize - image.size.width) / 2.0)
        
        let topGuide = UILayoutGuide()
        let bottomGuide = UILayoutGuide()
        
        deleteButton.accessibilityLabel = T.Voiceover.deleteButton
        
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
        
        leftButton.addTarget(self, action: #selector(leftButtonPressed), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        
        PINPad.numberButtonAction = numberButtonPressed(number:)
    }
    
    override var keyCommands: [UIKeyCommand]? {
        var commands = (0...9).map { number in
            UIKeyCommand(
                input: String(number),
                modifierFlags: [],
                action: #selector(keyboardNumberPressed(_:))
            )
        }
        
        let backspaceCommand = UIKeyCommand(
            input: backspaceCharacter,
            modifierFlags: [],
            action: #selector(keyboardDeletePressed(_:))
        )
        
        let deleteCommand = UIKeyCommand(
            input: UIKeyCommand.inputDelete,
            modifierFlags: [],
            action: #selector(keyboardDeletePressed(_:))
        )
        
        commands.append(backspaceCommand)
        commands.append(deleteCommand)
        
        return commands
    }
    
    override var canBecomeFirstResponder: Bool { true }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        becomeFirstResponder()
    }
    
    @objc
    private func keyboardNumberPressed(_ sender: UIKeyCommand) {
        guard let input = sender.input, let number = Int(input) else { return }
        numberButtonTap(number)
    }
    
    @objc
    private func keyboardDeletePressed(_ sender: UIKeyCommand) {
        guard let input = sender.input, input == backspaceCharacter || input == UIKeyCommand.inputDelete else { return }
        deleteButtonTap()
    }
    
    // MARK: - Overridables
    
    func bottomButtonTap() {}
    func leftButtonTap() {}
    func deleteButtonTap() {}
    func numberButtonTap(_ number: Int) {}
}

    // MARK: - Public API

extension PINKeyboardViewController: PINKeyboardViewControlling {
    func prepareScreen(with screenTitle: String, titleType: TitleType) {
        titleLabel.text = screenTitle
        
        VoiceOver.say(screenTitle)
        
        switch titleType {
        case .normal:
            titleLabel.textColor = Theme.Colors.Text.main
        case .error:
            titleLabel.textColor = Theme.Colors.Text.theme
        }
        
        titleLabel.accessibilityLabel = screenTitle
    }
    
    func prepareLeftButton(buttonTitle: String?) {
        if let buttonTitle {
            decorateButtonText(withButton: leftButton, text: buttonTitle)
            showLeftButton()
        } else {
            hideLeftButton()
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
    
    func showLeftButton() {
        leftButton.isHidden = false
    }
    
    func hideLeftButton() {
        leftButton.isHidden = true
    }
    
    func showDeleteButton() {
        deleteButton.isHidden = false
    }
    
    func hideDeleteButton() {
        deleteButton.isHidden = true
    }
    
    func lock(withMessage message: String) {
        dots.alpha = Theme.Alpha.disabledElement
        PINPad.isUserInteractionEnabled = false
        PINPad.alpha = Theme.Alpha.disabledElement
        titleLabel.text = message
    }
    
    func unlock() {
        dots.alpha = 1
        PINPad.isUserInteractionEnabled = true
        PINPad.alpha = 1
    }
    
    func showBottomButton(with title: String) {
        let bottomButton: UIButton = {
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(Theme.Colors.Controls.active, for: .normal)
            button.setTitleColor(Theme.Colors.Controls.highlighed, for: .highlighted)
            button.titleLabel?.font = Theme.Fonts.Text.content
            button.imageView?.tintColor = Theme.Colors.Fill.theme
            button.imageView?.contentMode = .center
            button.tintColor = Theme.Colors.Fill.theme
            return button
        }()
        view.addSubview(bottomButton, with: [
            bottomButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -Theme.Metrics.doubleMargin)
        ])
        bottomButton.addTarget(self, action: #selector(bottomButtonAction), for: .touchUpInside)
    }
}

// MARK: - Private

private extension PINKeyboardViewController {
    @objc private func bottomButtonAction() {
        bottomButtonTap()
    }
    
    private func prepareDescriptionLabel() {
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.allowsDefaultTighteningForTruncation = true
        titleLabel.textAlignment = .center
        titleLabel.font = Theme.Fonts.Text.content
        titleLabel.textColor = Theme.Colors.Text.main
    }
    
    private func decorateButtonText(withButton button: UIButton, text: String) {
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
    
    @objc private func leftButtonPressed() {
        actionFeedback.impactOccurred()
        leftButtonTap()
    }
    
    @objc private func deleteButtonPressed() {
        actionFeedback.impactOccurred()
        deleteButtonTap()
    }
    
    private func numberButtonPressed(number: Int) {
        numberFeedback.impactOccurred()
        numberButtonTap(number)
    }
}
