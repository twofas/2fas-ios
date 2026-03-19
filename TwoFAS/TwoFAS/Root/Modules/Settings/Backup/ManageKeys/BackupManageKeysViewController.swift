//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//

import UIKit
import Common

protocol BackupManageKeysViewControlling: AnyObject {
    func reload(with data: [BackupManageKeysSection])
}

final class BackupManageKeysViewController: UIViewController {
    private let iconSize: CGFloat = 20
    
    var presenter: BackupManageKeysPresenter!
    
    private let tableView = SettingsMenuTableView()
    
    private var tableViewAdapter: TableViewAdapter<BackupManageKeysSection, BackupManageKeysCell>!
    
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
        tableViewAdapter.titleForFooter = { [weak self] _, sectionOffset, snapshot in
            self?.titleForFooter(offset: sectionOffset, snapshot: snapshot)
        }
        tableViewAdapter.delegatee.didSelectItem = { [weak self] tableView, indexPath, data in
            self?.didSelect(tableView: tableView, indexPath: indexPath, data: data)
        }
        
        view.backgroundColor = Theme.Colors.Table.background
        
        setupTableViewLayout()
        
        hidesBottomBarWhenPushed = false
        navigationItem.backButtonDisplayMode = .minimal
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

extension BackupManageKeysViewController {
    func cell(
        for data: BackupManageKeysCell,
        in tableView: UITableView,
        at indexPath: IndexPath
    ) -> UITableViewCell? {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsMenuTableViewCell.identifier,
            for: indexPath
        ) as? SettingsMenuTableViewCell else { return nil }
        cell.selectionStyle = .default
        let icon: UIImage = {
            let traitCollection = UITraitCollection(userInterfaceStyle: .light)
            return data.icon.withConfiguration(traitCollection.imageConfiguration)
                .scalePreservingAspectRatio(targetSize: .init(width: iconSize, height: iconSize))
                .withTintColor(Theme.Colors.Icon.theme)
        }()
        
        cell.update(icon: icon, title: data.title, kind: .none, decorateText: .none)
        return cell
    }
    
    func titleForHeader(
        offset: Int,
        snapshot: TableViewDataSnapshot<BackupManageKeysSection, BackupManageKeysCell>
    ) -> String? {
        let section = snapshot.section(at: offset)
        return section.title
    }
    
    func titleForFooter(
        offset: Int,
        snapshot: TableViewDataSnapshot<BackupManageKeysSection, BackupManageKeysCell>
    ) -> String? {
        let section = snapshot.section(at: offset)
        return section.footer
    }
    
    func didSelect(tableView: UITableView, indexPath: IndexPath, data: BackupManageKeysCell) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.handleSelection(at: indexPath)
    }
}

extension BackupManageKeysViewController: BackupManageKeysViewControlling {
    func reload(with data: [BackupManageKeysSection]) {
        title = T.Backup.encryptionTitle
        let snapshot = TableViewDataSnapshot<BackupManageKeysSection, BackupManageKeysCell>()
        data.forEach { snapshot.appendSection($0) }
        tableViewAdapter.apply(snapshot: snapshot)
    }
}
