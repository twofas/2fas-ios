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

protocol ExporterPasswordProtectionViewControlling: AnyObject {
    func enableExportButton()
    func disableExportButton()
    func setFirstInputAsFirstResponder()
    func setSecondInputAsFirstResponder()
    func setSecondInputResignAsFirstResponder()
    func setRevealState(_ isRevealed: Bool)
    func showFirstIncorrectCharacterError()
    func showSecondIncorrectCharacterError()
    func showFirstToShortError()
    func showSecondToShortError()
    func hideFirstError()
    func hideSecondError()
    func showErrorPasswordsDontMatch()
}

final class ExporterPasswordProtectionViewController: UIViewController {
    var presenter: ExporterPasswordProtectionPresenter!
    
    private var exportButton: LoadingContentButton?
    
    private let incorrectCharacterError = T.Backup.incorrectCharacterError
    private let toShortError = T.Backup.toShortError
    
    private let firstInput = RevealPasswordInput()
    private let secondInput = RevealPasswordInput()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = generate()
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToParent()
        vc.didMove(toParent: self)
        
        configureInputs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewWillAppear()
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
            .text(text: T.Backup.setPasswordTitle, style: MainContainerTextStyling.boldContent),
            .extraSpacing,
            .view(view: firstInput),
            .view(view: secondInput),
            .elasticSpacer
        ])
        
        let contentBottom = MainContainerBottomContentGenerator(elements: [
            .filledButton(
                text: T.Backup.saveAndExport,
                callback: { [weak self] in self?.presenter.handleExport() },
                created: { [weak self] button in self?.exportButton = button }
            ),
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
    
    private func configureInputs() {
        firstInput.order = .first
        secondInput.order = .last
        
        firstInput.completeAction = { [weak self] in self?.handleFirstDone() }
        firstInput.didResign = { [weak self] in self?.handleFirstDone() }
        firstInput.didChangeValue = { [weak self] _ in self?.presenter.handleFirstChanged() }
        firstInput.notAllowedCharacter = { [weak self] in self?.presenter.handleFirstNotAllowedCharacter() }
        
        secondInput.completeAction = { [weak self] in self?.handleSecondDone() }
        secondInput.didResign = { [weak self] in self?.handleSecondDone() }
        secondInput.didChangeValue = { [weak self] _ in self?.presenter.handleSecondChanged() }
        secondInput.notAllowedCharacter = { [weak self] in self?.presenter.handleSecondNotAllowedCharacter() }
        
        firstInput.revealAction = { [weak self] in self?.presenter.handleReveal() }
        secondInput.revealAction = { [weak self] in self?.presenter.handleReveal() }
        
        firstInput.setTitle(T.Backup.password)
        secondInput.setTitle(T.Backup.repeatPassword)
    }
    
    private func handleFirstDone() {
        presenter.handleFirstDone(firstInput.currentInput)
    }
    
    private func handleSecondDone() {
        presenter.handleSecondDone(secondInput.currentInput)
    }
}

extension ExporterPasswordProtectionViewController: ExporterPasswordProtectionViewControlling {
    func enableExportButton() {
        exportButton?.setState(.active)
    }
    
    func disableExportButton() {
        exportButton?.setState(.inactive)
    }
    
    func setFirstInputAsFirstResponder() {
        _ = firstInput.becomeFirstResponder()
    }
    
    func setSecondInputAsFirstResponder() {
        _ = secondInput.becomeFirstResponder()
    }
    
    func setSecondInputResignAsFirstResponder() {
        _ = secondInput.resignFirstResponder()
    }
    
    func setRevealState(_ isRevealed: Bool) {
        firstInput.setRevealState(isPassHidden: !isRevealed)
        secondInput.setRevealState(isPassHidden: !isRevealed)
    }
    
    func showFirstIncorrectCharacterError() {
        firstInput.showError(incorrectCharacterError)
    }
    
    func showSecondIncorrectCharacterError() {
        secondInput.showError(incorrectCharacterError)
    }
    
    func showFirstToShortError() {
        firstInput.showError(toShortError)
    }
    
    func showSecondToShortError() {
        secondInput.showError(toShortError)
    }
    
    func hideFirstError() {
        firstInput.hideError()
    }
    
    func hideSecondError() {
        secondInput.hideError()
    }
    
    func showErrorPasswordsDontMatch() {
        secondInput.showError(T.Backup.passwordsDontMatch)
    }
}
