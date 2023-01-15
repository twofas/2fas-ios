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

protocol ComposeServiceAdvancedEditViewControlling: AnyObject {
    func reload(with data: ComposeServiceAdvancedEditMenuSection)
}

final class ComposeServiceAdvancedEditViewController: UIViewController {
    var presenter: ComposeServiceAdvancedEditPresenter!
    
    private let tableView = SettingsMenuTableView()
    private var tableViewAdapter: TableViewAdapter<
        ComposeServiceAdvancedEditMenuSection, ComposeServiceAdvancedEditMenuCell
    >!
    
    private var leadingCompact: NSLayoutConstraint?
    private var trailingCompact: NSLayoutConstraint?
    
    private var leadingRegular: NSLayoutConstraint?
    private var trailingRegular: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            ComposeServiceAdvancedEditTokenTypeCell.self,
            forCellReuseIdentifier: ComposeServiceAdvancedEditTokenTypeCell.identifier
        )
        tableViewAdapter = TableViewAdapter(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, cellData -> UITableViewCell in
                self?.cell(for: cellData, in: tableView, at: indexPath) ?? UITableViewCell()
            })
        tableViewAdapter.titleForHeader = { [weak self] _, sectionOffset, snapshot in
            self?.titleForHeader(offset: sectionOffset, snapshot: snapshot)
        }
        tableViewAdapter.titleForFooter = {  [weak self] _, sectionOffset, snapshot in
            self?.titleForFooter(offset: sectionOffset, snapshot: snapshot)
        }
        tableViewAdapter.delegatee.didSelectItem = { [weak self] tableView, indexPath, data in
            self?.didSelect(tableView: tableView, indexPath: indexPath, data: data)
        }
        
        view.backgroundColor = Theme.Colors.Table.background
        
        setupTableViewLayout()
        
        title = T.Tokens.advanced
        
        hidesBottomBarWhenPushed = false
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    private func setupTableViewLayout() {
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
}

extension ComposeServiceAdvancedEditViewController: ComposeServiceAdvancedEditViewControlling {
    func reload(with data: ComposeServiceAdvancedEditMenuSection) {
        let snapshot = TableViewDataSnapshot<
            ComposeServiceAdvancedEditMenuSection,
            ComposeServiceAdvancedEditMenuCell
        >()
        snapshot.appendSection(data)
        tableViewAdapter.apply(snapshot: snapshot)
    }
}

extension ComposeServiceAdvancedEditViewController {
    func cell(
        for data: ComposeServiceAdvancedEditMenuCell,
        in tableView: UITableView,
        at indexPath: IndexPath
    ) -> UITableViewCell {
        if case ComposeServiceAdvancedEditMenuCell.Kind.tokenType(let tokenType) = data.kind {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ComposeServiceAdvancedEditTokenTypeCell.identifier,
                for: indexPath
            ) as? ComposeServiceAdvancedEditTokenTypeCell else { return UITableViewCell() }
            let selectedTokenType: TokenType = {
                switch tokenType {
                case .totp: return .totp
                case .hotp: return .hotp
                }
            }()
            cell.didSelect = { [weak self] in self?.presenter.handleTokenTypeChange($0) }
            cell.setSelectedTokenType(selectedTokenType)
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsMenuTableViewCell.identifier,
            for: indexPath
        ) as? SettingsMenuTableViewCell else { return UITableViewCell() }
        cell.update(icon: nil, title: data.kind.localizedString, kind: .infoArrow(text: data.kind.value))
        return cell
    }
    
    func titleForHeader(
        offset: Int,
        snapshot: TableViewDataSnapshot<ComposeServiceAdvancedEditMenuSection, ComposeServiceAdvancedEditMenuCell>
    ) -> String? {
        let section = snapshot.section(at: offset)
        return section.title
    }
    
    func titleForFooter(
        offset: Int,
        snapshot: TableViewDataSnapshot<ComposeServiceAdvancedEditMenuSection, ComposeServiceAdvancedEditMenuCell>
    ) -> String? {
        let section = snapshot.section(at: offset)
        return section.footer
    }
    
    func didSelect(tableView: UITableView, indexPath: IndexPath, data: ComposeServiceAdvancedEditMenuCell) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.handleSelection(at: indexPath)
    }
}
