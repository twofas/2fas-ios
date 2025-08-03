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

protocol ExportTokensViewControlling: AnyObject {
    func reload(with data: [ExportTokensSection])
    func exporting()
    func unlock()
    func lock()
}

final class ExportTokensViewController: UIViewController {
    var presenter: ExportTokensPresenter!
    
    private let tableView = SettingsMenuTableView()
    
    private var tableViewAdapter: TableViewAdapter<ExportTokensSection, ExportTokensCell>!
    
    private var spinnerBarButtonItem: UIBarButtonItem?
    
    private let footerStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        return stack
    }()
    
    private var leadingCompact: NSLayoutConstraint?
    private var trailingCompact: NSLayoutConstraint?
    
    private var leadingRegular: NSLayoutConstraint?
    private var trailingRegular: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewAdapter = TableViewAdapter(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, cellData -> UITableViewCell in
            self?.cell(for: cellData, in: tableView, at: indexPath) ?? UITableViewCell()
        })
        tableViewAdapter.titleForHeader = { [weak self] _, sectionOffset, snapshot in
            self?.titleForHeader(offset: sectionOffset, snapshot: snapshot)
        }
        tableViewAdapter.titleForFooter = { [weak self] _, sectionOffset, snapshot in
            self?.titleForFooter(offset: sectionOffset, snapshot: snapshot)
        }
        tableViewAdapter.delegatee.didSelectItem = { [weak self] tableView, indexPath, data in
            self?.didSelect(tableView: tableView, indexPath: indexPath, data: data)
        }
        
        view.backgroundColor = Theme.Colors.Table.background
        
        setupViewLayout()
                
        title = "Export Tokens"
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(shouldRefresh),
            name: .refreshTabContent,
            object: nil
        )
        presenter.viewWillAppear()
    }
    
    @objc private func shouldRefresh() {
        presenter.handleBecomeActive()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ExportTokensViewController: ExportTokensViewControlling {
    func reload(with data: [ExportTokensSection]) {
        let snapshot = TableViewDataSnapshot<ExportTokensSection, ExportTokensCell>()
        data.forEach { snapshot.appendSection($0) }
        tableViewAdapter.apply(snapshot: snapshot)
    }
    
    func exporting() {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        
        spinnerBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItems = [spinnerBarButtonItem!]
        view.isUserInteractionEnabled = false
    }
    func unlock() {
        navigationItem.rightBarButtonItems = nil
        view.isUserInteractionEnabled = true
        spinnerBarButtonItem = nil
    }
    
    func lock() {
        tableView.isUserInteractionEnabled = false
    }
}

private extension ExportTokensViewController {
    func setupConstraints() {
        leadingCompact?.isActive = traitCollection.horizontalSizeClass == .compact
        leadingRegular?.isActive = traitCollection.horizontalSizeClass == .regular
        
        trailingCompact?.isActive = traitCollection.horizontalSizeClass == .compact
        trailingRegular?.isActive = traitCollection.horizontalSizeClass == .regular
    }
    
    func cell(
        for cellData: ExportTokensCell,
        in tableView: UITableView,
        at indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsMenuTableViewCell.identifier,
            for: indexPath
        ) as? SettingsMenuTableViewCell else { return UITableViewCell() }
        
        cell.disableIconBorder()
        cell.update(icon: cellData.icon, title: cellData.title, kind: .arrow)
        
        return cell
    }
    
    func titleForHeader(
        offset: Int,
        snapshot: TableViewDataSnapshot<ExportTokensSection, ExportTokensCell>
    ) -> String? {
        let section = snapshot.section(at: offset)
        return section.title
    }
    
    func titleForFooter(
        offset: Int,
        snapshot: TableViewDataSnapshot<ExportTokensSection, ExportTokensCell>
    ) -> String? {
        let section = snapshot.section(at: offset)
        return section.footer
    }
    
    func didSelect(tableView: UITableView, indexPath: IndexPath, data: ExportTokensCell) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.handleSelection(at: indexPath)
    }
} 
