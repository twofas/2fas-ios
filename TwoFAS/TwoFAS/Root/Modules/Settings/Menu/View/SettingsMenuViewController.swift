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

final class SettingsMenuViewController: UIViewController {
    var presenter: SettingsMenuPresenter!
    
    private let tableView = SettingsMenuTableView()
    private let footer = SettingsViewFooter()

    private var tableViewAdapter: TableViewAdapter<SettingsMenuSection, SettingsMenuCell>!
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewAdapter = TableViewAdapter(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, cellData -> UITableViewCell in
                self?.cell(for: cellData, in: tableView, at: indexPath) ?? UITableViewCell()
            }
        )
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
        
        title = T.Settings.settings
        footer.openURL = { [weak self] in self?.presenter.handleSocialChannel($0) }
                
        hidesBottomBarWhenPushed = false
        navigationItem.backButtonDisplayMode = .minimal        
    }
    
    private func setupTableViewLayout() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tintColor = Theme.Colors.Fill.theme
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        footer.frame.size = CGSize(width: view.bounds.size.width, height: footer.height)
        tableView.tableFooterView = footer
        footer.setNeedsLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewWillAppear()
    }
}

extension SettingsMenuViewController: SettingsMenuViewControlling {
    func reload(with data: [SettingsMenuSection]) {
        guard let tableViewAdapter else { return }
        let snapshot = TableViewDataSnapshot<SettingsMenuSection, SettingsMenuCell>()
        data.forEach { snapshot.appendSection($0) }
        tableViewAdapter.apply(snapshot: snapshot)
        guard !presenter.isCollapsed else {
            clearSelection()
            return
        }
        guard let selectedIndex = presenter.selectedIndex else { return }
        setSelection(at: selectedIndex)
    }
    
    func clearSelection() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func setSelection(at indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
}
