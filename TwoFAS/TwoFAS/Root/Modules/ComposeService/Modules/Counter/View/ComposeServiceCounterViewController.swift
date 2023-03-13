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

protocol ComposeServiceCounterViewControlling: AnyObject {
    func reload(with data: ComposeServiceCounterMenuSection)
    func enableSave()
    func disableSave()
    func showKeyboard()
}

final class ComposeServiceCounterViewController: UIViewController {
    var presenter: ComposeServiceCounterPresenter!
    
    private let tableView = SettingsMenuTableView()
    
    private var tableViewAdapter: TableViewAdapter<ComposeServiceCounterMenuSection, ComposeServiceCounterMenuCell>!
    
    private var leadingCompact: NSLayoutConstraint?
    private var trailingCompact: NSLayoutConstraint?
    
    private var leadingRegular: NSLayoutConstraint?
    private var trailingRegular: NSLayoutConstraint?
    
    private var saveActionBarButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ComposeServiceInputCell.self, forCellReuseIdentifier: ComposeServiceInputCell.identifier)
        tableViewAdapter = TableViewAdapter(
            tableView: tableView
        ) { [weak self] tableView, indexPath, cellData -> UITableViewCell in
            self?.cell(for: cellData, in: tableView, at: indexPath) ?? UITableViewCell()
        }
        
        view.backgroundColor = Theme.Colors.Table.background
        
        saveActionBarButtonItem = UIBarButtonItem(
            title: T.Commons.save,
            style: .plain,
            target: self,
            action: #selector(saveAction)
        )
        saveActionBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem = saveActionBarButtonItem
        
        setupViewLayout()
        
        title = T.Tokens.counter
    }
    
    private func setupViewLayout() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
        ])
        
        leadingCompact = tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        leadingRegular = tableView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor)
        
        trailingCompact = tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        trailingRegular = tableView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor)
        
        setupConstraints()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter.viewDidAppear()
    }
    
    private func setupConstraints() {
        switch traitCollection.horizontalSizeClass {
        case .regular:
            leadingRegular?.isActive = true
            trailingRegular?.isActive = true
            
            leadingCompact?.isActive = false
            trailingCompact?.isActive = false
            
        case .compact, .unspecified: fallthrough
        @unknown default:
            leadingRegular?.isActive = false
            trailingRegular?.isActive = false
            
            leadingCompact?.isActive = true
            trailingCompact?.isActive = true
        }
    }
    
    @objc(saveAction)
    private func saveAction() {
        presenter.handleSave()
    }
}

extension ComposeServiceCounterViewController: ComposeServiceCounterViewControlling {
    func reload(with data: ComposeServiceCounterMenuSection) {
        let snapshot = TableViewDataSnapshot<ComposeServiceCounterMenuSection, ComposeServiceCounterMenuCell>()
        snapshot.appendSection(data)
        tableViewAdapter.apply(snapshot: snapshot)
    }
    
    func enableSave() {
        saveActionBarButtonItem?.isEnabled = true
    }
    
    func disableSave() {
        saveActionBarButtonItem?.isEnabled = false
    }
}

extension ComposeServiceCounterViewController {
    func cell(
        for data: ComposeServiceCounterMenuCell,
        in tableView: UITableView,
        at indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ComposeServiceInputCell.identifier,
            for: indexPath
        ) as? ComposeServiceInputCell else { return UITableViewCell() }
        cell.configure(
            title: T.Tokens.initialCounter,
            value: data.counterValue,
            kind: .additionalInfo,
            inputConfig: .init(
                canPaste: true,
                shouldUppercase: false,
                returnKeyType: .done,
                maxLength: nil,
                autocapitalizationType: UITextAutocapitalizationType.allCharacters,
                configTextField: LimitedTextField.Config.number
            ),
            isRequired: true
        )
        cell.didUpdateValue = { [weak self] _, value, _ in self?.presenter.handleNewValue(value) }
        
        return cell
    }
    
    func showKeyboard() {
        guard let cellInput = findCell(for: .additionalInfo)?.cell as? ComposeServiceInputCell else { return }
        _ = cellInput.becomeFirstResponder()
        cellInput.selectAllText()
    }
    
    private func findCell(for kind: ComposeServiceInputKind) -> (cell: UITableViewCell, indexPath: IndexPath)? {
        guard let cell = tableView.visibleCells.first(where: { cell in
            guard let c = cell as? ComposeServiceInputCellKind, let cKind = c.kind else { return false }
            return cKind == kind
        }), let indexPath = tableView.indexPath(for: cell) else { return nil }
        return (cell: cell, indexPath: indexPath)
    }
}
