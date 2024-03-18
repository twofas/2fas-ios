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

protocol ImporterEnterPasswordViewControling: AnyObject {
    func inputBecomesFirstResponder()
    func importResignsFirstResponder()
    func setRevealState(isRevealed: Bool)
    func enableDecryptButton()
    func disableDecryptButton()
    func hideError()
    func showErrorIncorrectCharacter()
    func showErrorToShort()
}

final class ImporterEnterPasswordViewController: UIViewController {
    var presenter: ImporterEnterPasswordPresenter!
    
    private var decryptButton: LoadingContentButton?
    
    private let incorrectCharacterError = T.Backup.incorrectCharacterError
    private let toShortError = T.Backup.toShortError
    
    private let input = RevealPasswordInput()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = generate()
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToParent()
        vc.didMove(toParent: self)
        
        configureInput()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter.viewDidAppear()
    }

    private func generate() -> UIViewController {
        let barConfiguration = MainContainerBarConfiguration(
            title: nil,
            left: nil,
            right: nil,
            hideTabBar: true,
            hideNavigationBar: true,
            statusBar: nil
        )
        
        let contentTop = MainContainerTopContentGenerator(placement: .centerHorizontallyLimitWidth, elements: [
            .text(text: T.Backup.enterPasswordTitle, style: MainContainerTextStyling.boldContent),
            .extraSpacing,
            .view(view: input),
            .elasticSpacer
        ])

        let contentBottom = MainContainerBottomContentGenerator(elements: [
            .filledButton(
                text: T.Commons.continue,
                callback: { [weak self] in self?.presenter.handlePreimport() },
                created: { [weak self] button in
                self?.decryptButton = button
                button.setState(.inactive)
            }),
            .textButton(
                text: T.Commons.cancel,
                callback: { [weak self] in self?.presenter.handleCancel() },
                created: { button in button.apply(MainContainerButtonStyling.text.value) }
            )
        ])

        let config = MainContainerViewController.Configuration(
            barConfiguration: barConfiguration,
            contentTop: contentTop,
            contentMiddle: nil,
            contentBottom: contentBottom,
            generalConfiguration: MainContainerNonScrollable()
        )

        let vc = MainContainerViewController()
        vc.configure(with: config)
        vc.dismissKeyboardOnTap = true

        return vc
    }
    
    private func configureInput() {
        input.order = .first
        input.verifyPassword = false
        
        input.completeAction = { [weak self] in self?.done() }
        input.didResign = { [weak self] in self?.done() }
        input.didChangeValue = { [weak self] _ in self?.presenter.handleChange() }
        input.notAllowedCharacter = { [weak self] in self?.presenter.handleNotAllowedCharacter() }
        
        input.revealAction = { [weak self] in self?.presenter.handleReveal() }
        
        input.setTitle(T.Backup.password)
    }

    private func done() {
        presenter.handleDone(with: input.currentInput)
    }
}

extension ImporterEnterPasswordViewController: ImporterEnterPasswordViewControling {
    func inputBecomesFirstResponder() {
        _ = input.becomeFirstResponder()
    }
    
    func importResignsFirstResponder() {
        _ = input.resignFirstResponder()
    }
    
    func setRevealState(isRevealed: Bool) {
        input.setRevealState(isPassHidden: !isRevealed)
    }
    
    func enableDecryptButton() {
        decryptButton?.setState(.active)
    }
    
    func disableDecryptButton() {
        decryptButton?.setState(.inactive)
    }
    
    func hideError() {
        input.hideError()
    }
    
    func showErrorIncorrectCharacter() {
        input.showError(incorrectCharacterError)
    }
    
    func showErrorToShort() {
        input.showError(toShortError)
    }
}
