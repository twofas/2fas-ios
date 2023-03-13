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

protocol LabelComposeViewControlling: AnyObject {
    func enableSaveButton()
    func disableSaveButton()
    func setTitle(_ title: String)
    func updateTitle(_ title: String)
    func setColor(_ color: TintColor)
    func scrollToActiveColor()
    func setInitialColor(_ color: TintColor)
}

final class LabelComposeViewController: UIViewController {
    var presenter: LabelComposePresenter!
    
    private let labelRenderer = LabelRenderer()
    private let labelTextTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.Text.description
        label.textColor = Theme.Colors.Text.main
        label.text = T.Tokens.labelCharactersTitle
        return label
    }()
    private let labelTextTitleInput: UnderscoredInput = {
        let input = UnderscoredInput()
        input.font = Theme.Fonts.iconLabelInputTitle
        input.textColor = Theme.Colors.Text.main
        input.configure(for: .label)
        return input
    }()
    private let labelColorTitle: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.Text.description
        label.textColor = Theme.Colors.Text.main
        label.text = T.Tokens.pickBackgroundColor
        return label
    }()
    private let colorSelector = ColorSelector()
    private let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Theme.Colors.Fill.System.third
        navigationController?.navigationBar.standardAppearance.backgroundColor = Theme.Colors.Fill.System.third
        
        labelTextTitleInput.textDidChange = { [weak self] newString in
            self?.presenter.handleSetTitle(newString)
        }
        
        view.addSubview(scrollView, with: [
            scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        let margin = Theme.Metrics.doubleMargin
        
        scrollView.addSubview(labelRenderer, with: [
            labelRenderer.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 2 * margin),
            labelRenderer.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])

        scrollView.addSubview(labelTextTitleLabel, with: [
            labelTextTitleLabel.topAnchor.constraint(equalTo: labelRenderer.bottomAnchor, constant: 2 * margin),
            labelTextTitleLabel.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                constant: margin
            ),
            labelTextTitleLabel.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                constant: -margin
            )
        ])

        scrollView.addSubview(labelTextTitleInput, with: [
            labelTextTitleInput.topAnchor.constraint(equalTo: labelTextTitleLabel.bottomAnchor, constant: margin),
            labelTextTitleInput.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                constant: margin
            ),
            labelTextTitleInput.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                constant: -margin
            )
        ])

        scrollView.addSubview(labelColorTitle, with: [
            labelColorTitle.topAnchor.constraint(equalTo: labelTextTitleInput.bottomAnchor, constant: 2 * margin),
            labelColorTitle.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                constant: margin
            ),
            labelColorTitle.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                constant: -margin
            )
        ])

        scrollView.addSubview(colorSelector, with: [
            colorSelector.topAnchor.constraint(equalTo: labelColorTitle.bottomAnchor, constant: margin),
            colorSelector.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            colorSelector.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            colorSelector.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -margin)
        ])
        colorSelector.setSpacing(margin)

        let buttons: [ColorPickerButtonWithName] = TintColor.labelList.map { color in
            let b = ColorPickerButtonWithName()
            b.set(color: color)
            return b
        }
        colorSelector.setColorButtons(buttons)
        colorSelector.activeColorDidChange = { [weak self] in self?.presenter.handleSetColor($0) }
        
        title = T.Tokens.changeLabel
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: T.Commons.save,
            style: .plain,
            target: self,
            action: #selector(saveAction)
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        presenter.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSafeAreaKeyboardAdjustment()
        
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !UIAccessibility.isVoiceOverRunning else { return }
        labelTextTitleInput.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSafeAreaKeyboardAdjustment()
    }
    
    @objc
    private func saveAction() {
        presenter.handleSave()
    }
}

extension LabelComposeViewController: LabelComposeViewControlling {
    func enableSaveButton() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func disableSaveButton() {
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func setTitle(_ title: String) {
        labelRenderer.setText(title)
        labelTextTitleInput.setText(title)
    }
    
    func updateTitle(_ title: String) {
        labelRenderer.setText(title)
    }
    
    func setColor(_ color: TintColor) {
        labelRenderer.setColor(color, animated: true)
    }
    
    func scrollToActiveColor() {
        colorSelector.scrollToActive()
    }
    
    func setInitialColor(_ color: TintColor) {
        colorSelector.setInitialActiveColor(color)
    }
}
