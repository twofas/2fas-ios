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

protocol ComposeServiceViewControlling: AnyObject {
    func reload(with data: [ComposeServiceSection])
    func enableSave()
    func disableSave()
    func becomeFirstResponder(for kind: ComposeServiceInputKind)
    func endEditing()
    func reloadPrivateKeyError(with data: [ComposeServiceSection])
    func revealCode(_ privateKey: String)
    func copySecret()
}

final class ComposeServiceViewController: UIViewController {
    var presenter: ComposeServicePresenter!
    
    private var saveActionBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = T.Commons.save
        button.style = .plain
        button.isEnabled = false
        return button
    }()
    private let tableView = SettingsMenuTableView()
    private var tableViewAdapter: TableViewAdapter<ComposeServiceSection, ComposeServiceSectionCell>!

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
        
        switch key.keyCode {
        case .keyboardReturn, .keyboardReturnOrEnter:
            saveAction()
        case .keyboardEscape:
            cancelAction()
        default:
            super.pressesEnded(presses, with: event)
        }
    }
    
    @objc(cancelAction)
    private func cancelAction() {
        presenter.handleCancel()
    }
    
    @objc(saveAction)
    private func saveAction() {
        presenter.handleSave()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            ComposeServiceInputCell.self,
            forCellReuseIdentifier: ComposeServiceInputCell.identifier
        )
        tableView.register(
            ComposeServicePrivateKeyCell.self,
            forCellReuseIdentifier: ComposeServicePrivateKeyCell.identifier
        )
        tableView.register(
            ComposeServiceIconTypeSelection.self,
            forCellReuseIdentifier: ComposeServiceIconTypeSelection.identifier
        )
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAction))
        recognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(recognizer)
        tableView.keyboardDismissMode = .onDrag
        
        tableViewAdapter = TableViewAdapter(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, cellData -> UITableViewCell in
                self?.cell(for: cellData, in: tableView, at: indexPath) ?? UITableViewCell()
            }
        )
        tableViewAdapter.titleForHeader = { [weak self] _, sectionOffset, snapshot in
            self?.titleForHeader(offset: sectionOffset, snapshot: snapshot)
        }
        tableViewAdapter.delegatee.didSelectItem = { [weak self] tableView, indexPath, data in
            self?.didSelect(tableView: tableView, indexPath: indexPath, data: data)
        }
        
        view.backgroundColor = Theme.Colors.Table.background
        navigationController?.navigationBar.standardAppearance.backgroundColor = Theme.Colors.Fill.System.first
        
        saveActionBarButtonItem.target = self
        saveActionBarButtonItem.action = #selector(saveAction)
                
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: T.Commons.cancel,
            style: .plain,
            target: self,
            action: #selector(cancelAction)
        )
        navigationItem.rightBarButtonItem = saveActionBarButtonItem
        
        setupTableViewLayout()
                        
        hidesBottomBarWhenPushed = false
        navigationItem.backButtonDisplayMode = .minimal
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(notificationServicesWereUpdated), name: .servicesWereUpdated, object: nil
        )
    }
    
    private func setupTableViewLayout() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter.viewDidAppear()
    }
    
    @objc(didTapAction)
    private func didTapAction() {
        endEditing()
    }
    
    @objc(notificationServicesWereUpdated:)
    private func notificationServicesWereUpdated(notification: Notification) {
        let modified = notification.userInfo?[Notification.UserInfoKey.modified] as? [String]
        let deleted = notification.userInfo?[Notification.UserInfoKey.deleted] as? [String]
        presenter.handleServicesWereUpdated(modified: modified, deleted: deleted)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ComposeServiceViewController: ComposeServiceViewControlling {
    func reload(with data: [ComposeServiceSection]) {
        let snapshot = TableViewDataSnapshot<ComposeServiceSection, ComposeServiceSectionCell>()
        data.forEach({ snapshot.appendSection($0) })
        tableViewAdapter?.apply(snapshot: snapshot)
    }
    
    func setTitle(_ title: String) {
        self.title = title
        accessibilityLabel = title
    }
    
    func enableSave() {
        saveActionBarButtonItem.isEnabled = true
    }
    
    func disableSave() {
        saveActionBarButtonItem.isEnabled = false
    }
    
    func becomeFirstResponder(for kind: ComposeServiceInputKind) {
        guard let cellInput = findCell(for: kind)?.cell else { return }
        cellInput.becomeFirstResponder()
    }
    
    func endEditing() {
        view.endEditing(true)
    }
    
    func reloadPrivateKeyError(with data: [ComposeServiceSection]) {
        guard let (cell, indexPath) = findCell(for: .privateKey),
        let privateKeyCell = cell as? ComposeServicePrivateKeyCell else { return }

        let isFirst = privateKeyCell.isFirstResponder
        
        let snapshot = TableViewDataSnapshot<ComposeServiceSection, ComposeServiceSectionCell>()
        data.forEach({ snapshot.appendSection($0) })
        tableViewAdapter.update(snapshot: snapshot)
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        guard let (cell, _) = findCell(for: .privateKey),
        let privateKeyCell = cell as? ComposeServicePrivateKeyCell else { return }
        
        if isFirst {
            _ = privateKeyCell.becomeFirstResponder()
        }
    }
    
    func revealCode(_ privateKey: String) {
        guard let (cell, _) = findCell(for: .privateKey),
        let privateKeyCell = cell as? ComposeServicePrivateKeyCell else { return }
        privateKeyCell.setRevealState(state: .copy(privateKey))
    }
    
    func copySecret() {
        VoiceOver.say(T.Notifications.serviceKeyCopied)
        HUDNotification.presentSuccess(title: T.Notifications.serviceKeyCopied)
    }
    
    private func findCell(for kind: ComposeServiceInputKind) -> (cell: UITableViewCell, indexPath: IndexPath)? {
        guard let cell = tableView.visibleCells.first(where: { cell in
            guard let c = cell as? ComposeServiceInputCellKind, let cKind = c.kind else { return false }
            return cKind == kind
        }), let indexPath = tableView.indexPath(for: cell) else { return nil }
        return (cell: cell, indexPath: indexPath)
    }
}
