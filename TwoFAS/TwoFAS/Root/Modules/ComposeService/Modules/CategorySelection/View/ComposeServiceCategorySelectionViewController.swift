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

protocol ComposeServiceCategorySelectionViewControlling: AnyObject {
    func reload(with data: ComposeServiceCategorySelectionMenuSection)
}

final class ComposeServiceCategorySelectionViewController: UIViewController {
    var presenter: ComposeServiceCategorySelectionPresenter!
    
    private let tableView = SettingsMenuTableView()
    
    private var tableViewAdapter: TableViewAdapter<
        ComposeServiceCategorySelectionMenuSection,
        ComposeServiceCategorySelectionMenuCell
    >!
    
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
            }
        )
        tableViewAdapter.delegatee.didSelectItem = { [weak self] tableView, indexPath, data in
            self?.didSelect(tableView: tableView, indexPath: indexPath, data: data)
        }
        
        view.backgroundColor = Theme.Colors.Table.background
        
        setupViewLayout()
        
        title = T.Tokens.selectGroup
        
        let buttonSection = UIBarButtonItem(
            image: Asset.addCategory.image,
            style: .plain,
            target: self,
            action: #selector(addSectionAction)
        )
        buttonSection.accessibilityLabel = T.Voiceover.addGroup
        navigationItem.rightBarButtonItem = buttonSection
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
    
    @objc
    private func addSectionAction() {
        presenter.handleAddSection()
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

extension ComposeServiceCategorySelectionViewController: ComposeServiceCategorySelectionViewControlling {
    func reload(with data: ComposeServiceCategorySelectionMenuSection) {
        let snapshot = TableViewDataSnapshot<
            ComposeServiceCategorySelectionMenuSection,
            ComposeServiceCategorySelectionMenuCell
        >()
        snapshot.appendSection(data)
        tableViewAdapter.apply(snapshot: snapshot)
    }
}

extension ComposeServiceCategorySelectionViewController {
    func cell(
        for data: ComposeServiceCategorySelectionMenuCell,
        in tableView: UITableView,
        at indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsMenuTableViewCell.identifier,
            for: indexPath
        ) as? SettingsMenuTableViewCell else { return UITableViewCell() }
        let accessory: SettingsMenuTableViewCell.AccessoryType = {
            if data.checkmark {
                return .checkmark
            }
            return .none
        }()
        cell.update(icon: nil, title: data.title, kind: accessory)
        cell.tintColor = Theme.Colors.Fill.theme
        cell.selectionStyle = .none
        
        return cell
    }
    
    func didSelect(tableView: UITableView, indexPath: IndexPath, data: ComposeServiceCategorySelectionMenuCell) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.handleSelection(at: indexPath)
    }
}
