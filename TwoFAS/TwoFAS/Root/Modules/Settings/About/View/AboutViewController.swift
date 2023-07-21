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

protocol AboutViewControlling: AnyObject {
    func reload(with data: [AboutSection])
}

final class AboutViewController: UIViewController {
    var presenter: AboutPresenter!
    
    private let tableView = SettingsMenuTableView()
    private let footer = AboutFooter()
    
    private var tableViewAdapter: TableViewAdapter<AboutSection, AboutCell>!
    
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
        
        title = T.Settings.about
        
        hidesBottomBarWhenPushed = false
        navigationItem.backButtonDisplayMode = .minimal
        
        footer.setText(T.Settings.version(presenter.appVersion))
        tableView.tableFooterView = footer
        tableView.separatorInset = .zero
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
}

extension AboutViewController {
    func cell(for data: AboutCell, in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell? {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsMenuTableViewCell.identifier,
            for: indexPath
        ) as? SettingsMenuTableViewCell else { return nil }
        
        let accessory: SettingsMenuTableViewCell.AccessoryType = {
            if let image = data.accessory.icon {
                let imageView = UIImageView(image: image)
                imageView.tintColor = Theme.Colors.Icon.theme
                return .customView(customView: imageView)
            }
            if case AboutCell.AccessoryKind.toggle(let isOn) = data.accessory {
                return .toggle(isEnabled: isOn) { [weak self] _, _ in
                    self?.presenter.handleToogle()
                }
            }
            
            return .none
        }()
        
        let decorateText: SettingsMenuTableViewCell.TextDecoration = {
            if case SettingsMenuTableViewCell.AccessoryType.none = accessory {
                return .action
            }
            return .none
        }()
        if data.action == nil {
            cell.selectionStyle = .none
        } else {
            cell.selectionStyle = .default
        }
        let icon: UIImage? = {
            guard let img = data.icon else { return nil }
            let traitCollection = UITraitCollection(userInterfaceStyle: .light)
            return img.withConfiguration(traitCollection.imageConfiguration)
        }()
        
        cell.update(icon: icon, title: data.title, kind: accessory, decorateText: decorateText)
        return cell
    }
    
    func titleForHeader(offset: Int, snapshot: TableViewDataSnapshot<AboutSection, AboutCell>) -> String? {
        let section = snapshot.section(at: offset)
        return section.title
    }
    
    func titleForFooter(
        offset: Int,
        snapshot: TableViewDataSnapshot<AboutSection, AboutCell>
    ) -> String? {
        let section = snapshot.section(at: offset)
        return section.footer
    }
    
    func didSelect(tableView: UITableView, indexPath: IndexPath, data: AboutCell) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.handleSelection(at: indexPath)
    }
}

extension AboutViewController: AboutViewControlling {
    func reload(with data: [AboutSection]) {
        let snapshot = TableViewDataSnapshot<AboutSection, AboutCell>()
        data.forEach { snapshot.appendSection($0) }
        tableViewAdapter.apply(snapshot: snapshot)
    }
}
