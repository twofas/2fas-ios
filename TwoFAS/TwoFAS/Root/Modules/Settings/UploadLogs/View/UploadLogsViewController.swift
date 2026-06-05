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

protocol UploadLogsViewControlling: AnyObject, SpinnerDisplaying {
    func setCode(_ code: UUID)
    func setForEdit(clearCode: Bool)
    func disableClose()
    func enableClose()
}

final class UploadLogsViewController: UIViewController {
    var presenter: UploadLogsPresenter!
    
    private let infoLabel: UILabel = {
        let l = UILabel()
        l.textColor = Theme.Colors.Text.main
        l.font = Theme.Fonts.Text.boldContent
        l.numberOfLines = 0
        l.textAlignment = .center
        l.lineBreakMode = .byWordWrapping
        return l
    }()
    private let group = UUIDGroupInput()
    private let sendButton: LoadingContentButton = {
        let button = LoadingContentButton()
        button.update(title: T.Commons.send)
        button.apply(MainContainerButtonStyling.filledInDecoratedContainerLightText.value)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Theme.Colors.Fill.System.first
        
        title = T.Settings.sendLogsTitle
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: T.Commons.cancel,
            style: .plain,
            target: self,
            action: #selector(cancelAction)
        )
        
        let spacing = Theme.Metrics.doubleSpacing
        
        view.addSubview(infoLabel, with: [
            infoLabel.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: spacing),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -spacing)
        ])
        view.addSubview(group, with: [
            group.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 2 * spacing),
            group.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.Metrics.standardSpacing),
            group.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.Metrics.standardSpacing)
        ])
        view.addSubview(sendButton, with: [
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendButton.topAnchor.constraint(equalTo: group.bottomAnchor, constant: 4 * spacing)
        ])
        
        group.valueChanged = { [weak self] value in
            let correct = UUID(uuidString: value) != nil
            self?.sendButton.setState(correct ? .active : .inactive)
        }
        
        group.actionCallback = { [weak self] in self?.sendAction() }
        sendButton.action = { [weak self] in
            self?.group.stop()
            self?.sendAction()
        }        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewWillAppear()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        group.showKeyboard()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @objc
    private func cancelAction() {
        presenter.handleClose()
    }
    
    private func sendAction() {
        guard let uuid = UUID(uuidString: group.value) else { return }
        presenter.handleSend(uuid)
    }
}

extension UploadLogsViewController: UploadLogsViewControlling {
    func setCode(_ code: UUID) {
        group.setReadOnlyValue(code)
        infoLabel.text = T.Settings.sendLogsDescriptionLink
    }
    
    func setForEdit(clearCode: Bool) {
        sendButton.setState(.inactive)
        infoLabel.text = T.Settings.sendLogsDescriptionEdit
        group.start(clearCode: clearCode)
    }
    
    func disableClose() {
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    func enableClose() {
        navigationItem.leftBarButtonItem?.isEnabled = true
    }
}
