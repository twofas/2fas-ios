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
import CommonUIKit

protocol BrowserExtensionMainViewControlling: AnyObject, SpinnerDisplaying {
    func reload(with data: [BrowserExtensionMainMenuSection])
}

final class BrowserExtensionMainViewController: UIViewController {
    var presenter: BrowserExtensionMainPresenter!
    
    private let tableView = SettingsMenuTableView()
    private var tableViewAdapter: TableViewAdapter<BrowserExtensionMainMenuSection, BrowserExtensionMainMenuCell>!
    
    private var leadingCompact: NSLayoutConstraint?
    private var trailingCompact: NSLayoutConstraint?
    
    private var leadingRegular: NSLayoutConstraint?
    private var trailingRegular: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            BrowserExtenionServiceTableViewCell.self,
            forCellReuseIdentifier: BrowserExtenionServiceTableViewCell.identifier
        )
        tableViewAdapter = TableViewAdapter(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, cellData -> UITableViewCell in
                self?.cell(for: cellData, in: tableView, at: indexPath) ?? UITableViewCell()
            }
        )
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
        
        setupTableViewLayout()
        
        title = T.Browser.browserExtension
        
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

extension BrowserExtensionMainViewController: BrowserExtensionMainViewControlling {
    func reload(with data: [BrowserExtensionMainMenuSection]) {
        let snapshot = TableViewDataSnapshot<BrowserExtensionMainMenuSection, BrowserExtensionMainMenuCell>()
        data.forEach {
            snapshot.appendSection($0)
        }
        tableViewAdapter.apply(snapshot: snapshot)
    }
}

extension BrowserExtensionMainViewController {
    func cell(
        for data: BrowserExtensionMainMenuCell,
        in tableView: UITableView,
        at indexPath: IndexPath
    ) -> UITableViewCell {
        if case BrowserExtensionMainMenuCell.Kind.service(let name, let date, _) = data.kind {
            return serviceCell(for: name, date: date, in: tableView, at: indexPath)
        }
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsMenuTableViewCell.identifier,
            for: indexPath
        ) as? SettingsMenuTableViewCell else { return UITableViewCell() }
        let title: String = {
            switch data.kind {
            case .addNew: return T.Browser.addNew
            case .nickname(let nick): return nick
            default: return ""
            }
        }()
        let decoration: SettingsMenuTableViewCell.TextDecoration = {
            switch data.kind {
            case .addNew: return .action
            default: return .none
            }
        }()
        let kind: SettingsMenuTableViewCell.AccessoryType = {
            switch data.kind {
            case .nickname: return .arrow
            default: return .none
            }
        }()
        cell.update(icon: nil, title: title, kind: kind, decorateText: decoration)
        return cell
    }
    
    func titleForHeader(
        offset: Int,
        snapshot: TableViewDataSnapshot<BrowserExtensionMainMenuSection, BrowserExtensionMainMenuCell>
    ) -> String? {
        let section = snapshot.section(at: offset)
        return section.title
    }
    
    func titleForFooter(
        offset: Int,
        snapshot: TableViewDataSnapshot<BrowserExtensionMainMenuSection, BrowserExtensionMainMenuCell>
    ) -> String? {
        let section = snapshot.section(at: offset)
        return section.footer
    }
        
    func didSelect(tableView: UITableView, indexPath: IndexPath, data: BrowserExtensionMainMenuCell) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.handleSelection(at: indexPath)
    }
}

private extension BrowserExtensionMainViewController {
    func serviceCell(
        for name: String,
        date: String,
        in tableView: UITableView,
        at indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BrowserExtenionServiceTableViewCell.identifier,
            for: indexPath
        ) as? BrowserExtenionServiceTableViewCell else { return UITableViewCell() }
        cell.update(title: name, subtitle: date)
        return cell
    }
}
