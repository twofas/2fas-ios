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

protocol AppSecurityViewControlling: AnyObject {
    func reload(with data: [AppSecurityMenuSection])
}

final class AppSecurityViewController: UIViewController {
    var presenter: AppSecurityPresenter!
    
    private let tableView = SettingsMenuTableView()
    
    private var tableViewAdapter: TableViewAdapter<AppSecurityMenuSection, AppSecurityMenuCell>!
    
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

        title = T.Settings.appSecurity
        navigationItem.backButtonDisplayMode = .minimal
        
        presenter.viewDidLoad()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc
    private func shouldRefresh() {
        presenter.handleBecomeActive()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension AppSecurityViewController: AppSecurityViewControlling {
    func reload(with data: [AppSecurityMenuSection]) {
        let snapshot = TableViewDataSnapshot<AppSecurityMenuSection, AppSecurityMenuCell>()
        data.forEach { snapshot.appendSection($0) }
        tableViewAdapter.apply(snapshot: snapshot)
    }
}

extension AppSecurityViewController {
    func cell(for data: AppSecurityMenuCell, in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsMenuTableViewCell.identifier,
            for: indexPath
        ) as? SettingsMenuTableViewCell else { return UITableViewCell() }
        let accessoryType = dataToKind(data, tableView: tableView)
        cell.update(icon: nil, title: data.title, kind: accessoryType, decorateText: textDecoration(for: data))
        if data.action != nil {
            cell.selectionStyle = .default
        } else {
            cell.selectionStyle = .none
        }
        
        let accessory = data.accessory
        if case let .toggle(toggle) = accessory, toggle.isBlocked {
            cell.disable()
            cell.disableToggle()
        }

        return cell
    }
    
    func titleForHeader(
        offset: Int,
        snapshot: TableViewDataSnapshot<AppSecurityMenuSection, AppSecurityMenuCell>
    ) -> String? {
        let section = snapshot.section(at: offset)
        return section.title
    }
    
    func titleForFooter(
        offset: Int,
        snapshot: TableViewDataSnapshot<AppSecurityMenuSection, AppSecurityMenuCell>
    ) -> String? {
        let section = snapshot.section(at: offset)
        return section.footer
    }
    
    func didSelect(tableView: UITableView, indexPath: IndexPath, data: AppSecurityMenuCell) {
        let animated = data.action != nil
        tableView.deselectRow(at: indexPath, animated: animated)
        presenter.handleSelection(at: indexPath)
    }
    
    private func textDecoration(for data: AppSecurityMenuCell) -> SettingsMenuTableViewCell.TextDecoration {
        guard let action = data.action else { return .none }
        switch action {
        case .changePIN: return .action
        case .limit: return .none
        }
    }
    
    private func dataToKind(
        _ data: AppSecurityMenuCell,
        tableView: UITableView
    ) -> SettingsMenuTableViewCell.AccessoryType {
        switch data.accessory {
        case .none: return .none
        case .arrow: return .arrow
        case .info(let text): return .infoArrow(text: text)
        case .toggle(let toggle): return .toggle(isEnabled: toggle.isOn) { [weak tableView, weak self] calledCell, _ in
            guard let indexPath = tableView?.indexPath(for: calledCell), !toggle.isBlocked else { return }
            self?.presenter.handleToggle(for: indexPath)
        }
        }
    }
}
