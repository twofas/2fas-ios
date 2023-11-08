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
    func userWasAuthenticated()
    func lockUI()
    func unlockUI()
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
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    // MARK: - Public API
    
    func prepareScreen(withScreenData data: PINPadScreenData) {
        titleLabel.text = data.screenTitle
        
        switch data.titleType {
        case .normal:
            titleLabel.textColor = Theme.Colors.Text.main
        case .error:
            titleLabel.textColor = Theme.Colors.Text.theme
        }
        
        titleLabel.accessibilityLabel = data.screenTitle
        
        if let title = data.buttonTitle {
            decorateButtonText(withButton: leftButton, text: title)
            showLeftButton()
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
    
    func hideRightButton() {
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
    
    func showReset() {
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
    
    // MARK: - Private
    
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
        viewModel.leftButtonPressed()
    }
    
    @objc private func deleteButtonPressed() {
        actionFeedback.impactOccurred()
        viewModel.deleteButtonPressed()
    }
    
    @objc private func resetAction() {
        viewModel.reset()
    }
    
    private func numberButtonPressed(number: Int) {
        numberFeedback.impactOccurred()
        viewModel.numberButtonPressed(number: number)
    }
}
