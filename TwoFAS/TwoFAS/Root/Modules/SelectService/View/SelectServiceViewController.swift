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

protocol SelectServiceViewControlling: AnyObject {
    func reload(with data: [SelectServiceSection])
    func showEmptyScreen()
}

final class SelectServiceViewController: UIViewController {
    var presenter: SelectServicePresenter!
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = Theme.Colors.Fill.System.second
        tableView.separatorStyle = .singleLine
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.allowsMultipleSelection = false
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 2, height: 1)))
        tableView.sectionHeaderTopPadding = 0
        
        return tableView
    }()
    
    private var tableViewAdapter: TableViewAdapter<SelectServiceSection, SelectServiceCell>!
    
    private var leadingCompact: NSLayoutConstraint?
    private var trailingCompact: NSLayoutConstraint?
    
    private var leadingRegular: NSLayoutConstraint?
    private var trailingRegular: NSLayoutConstraint?
    
    private let searchController = CommonSearchController()
    private let tableHeaderView = SelectServiceTableViewHeader()
    
    private let emptyScreen = SearchResultEmptyView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            SelectServiceTableViewCell.self,
            forCellReuseIdentifier: SelectServiceTableViewCell.identifier
        )
        
        tableViewAdapter = TableViewAdapter(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, cellData -> UITableViewCell in
                self?.cell(for: cellData, in: tableView, at: indexPath) ?? UITableViewCell()
            }
        )
        tableViewAdapter.delegatee.didSelectItem = { [weak self] tableView, indexPath, data in
            self?.didSelect(tableView: tableView, indexPath: indexPath, data: data)
        }
        tableViewAdapter.titleForHeader = { [weak self] _, sectionOffset, snapshot in
            self?.titleForHeader(offset: sectionOffset, snapshot: snapshot)
        }
        tableViewAdapter.delegatee.sizeForFooter = { _, _ in 0 }
        tableView.tableHeaderView = tableHeaderView
        
        view.backgroundColor = Theme.Colors.Fill.System.second
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: T.Commons.cancel,
            style: .plain,
            target: self,
            action: #selector(cancel)
        )
        
        title = T.Browser.request
        
        view.addSubview(emptyScreen)
        emptyScreen.pinToParent()
        emptyScreen.isHidden = true
        
        searchController.searchBarDelegate = self
        setupViewLayout()
        
        tableHeaderView.configure(for: presenter.browserName, domain: presenter.domain)
    }
    
    private func setupViewLayout() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        leadingCompact = tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        leadingRegular = tableView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor)
        
        trailingCompact = tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        trailingRegular = tableView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor)
        
        setupConstraints()
    }
    
    @objc
    private func cancel() {
        presenter.handleCancel()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSafeAreaKeyboardAdjustment()
        presenter.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSafeAreaKeyboardAdjustment()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
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
    
    private func sizeHeaderToFit() {
        guard let headerView = tableView.tableHeaderView else { return }
        guard presenter.showTableViewHeader else {
            headerView.frame = CGRect(origin: .zero, size: .zero)
            return
        }
        
        let newHeight = headerView.systemLayoutSizeFitting(
            CGSize(width: tableView.frame.width, height: .greatestFiniteMagnitude),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow)
        var frame = headerView.frame
        
        if newHeight.height != frame.height {
            frame.size.height = newHeight.height
            headerView.frame = frame
            tableView.tableHeaderView = headerView
        }
    }
}

extension SelectServiceViewController: SelectServiceViewControlling {
    func reload(with data: [SelectServiceSection]) {
        let snapshot = TableViewDataSnapshot<SelectServiceSection, SelectServiceCell>()
        data.forEach { section in
            snapshot.appendSection(section)
        }
        tableViewAdapter.apply(snapshot: snapshot)
        tableView.isHidden = false
        emptyScreen.isHidden = true
    }
    
    func showEmptyScreen() {
        tableView.isHidden = true
        emptyScreen.isHidden = false
    }
}

extension SelectServiceViewController {
    func cell(for data: SelectServiceCell, in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SelectServiceTableViewCell.identifier,
            for: indexPath
        ) as? SelectServiceTableViewCell else { return UITableViewCell() }
        cell.update(icon: data.icon, title: data.title, subtitle: data.subtitle)
        
        return cell
    }
    
    func didSelect(tableView: UITableView, indexPath: IndexPath, data: SelectServiceCell) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.handleSelection(at: indexPath)
    }
    
    func titleForHeader(
        offset: Int,
        snapshot: TableViewDataSnapshot<SelectServiceSection, SelectServiceCell>
    ) -> String? {
        let section = snapshot.section(at: offset)
        switch section.title {
        case .noTitle: return T.Tokens.myTokens
        case .bestMatch: return T.Commons.bestMatch
        case .title(let title): return title
        }
    }
}

extension SelectServiceViewController: CommonSearchDataSourceSearchable {
    func setSearchPhrase(_ phrase: String) {
        presenter.handleSearch(phrase)
        sizeHeaderToFit()
    }
    
    func clearSearchPhrase() {
        presenter.handleClearSearch()
        sizeHeaderToFit()
    }
}
