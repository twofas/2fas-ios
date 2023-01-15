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

protocol NewsViewControlling: AnyObject {
    func reload(with data: NewsSection)
    func showEmptyScreen()
}

final class NewsViewController: UIViewController {
    var presenter: NewsPresenter!
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = Theme.Colors.notificationsBackground
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.allowsMultipleSelection = false
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 2, height: 1)))
        tableView.sectionHeaderTopPadding = 0

        return tableView
    }()
    
    private let emptyScreen = NewsViewEmptyScreen()
    
    private var tableViewAdapter: TableViewAdapter<NewsSection, NewsCell>!
    
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
        tableViewAdapter.delegatee.didSelectItem = { [weak self] tableView, indexPath, _ in
            tableView.deselectRow(at: indexPath, animated: true)
            self?.presenter.handleSelection(at: indexPath.row)
        }
        tableViewAdapter.delegatee.sizeForFooter = { _, _ in 0 }
        tableViewAdapter.delegatee.sizeForHeader = { _, _ in 0 }
        
        view.backgroundColor = Theme.Colors.notificationsBackground
        
        setupViewLayout()
        
        view.addSubview(emptyScreen)
        emptyScreen.pinToParent()
        emptyScreen.isHidden = true
        
        title = T.Commons.notifications
        
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
        
        presenter.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        presenter.viewWillDisappear()
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

extension NewsViewController: NewsViewControlling {
    func reload(with data: NewsSection) {
        let snapshot = TableViewDataSnapshot<NewsSection, NewsCell>()
        snapshot.appendSection(data)
        tableViewAdapter.apply(snapshot: snapshot)
        tableView.isHidden = false
        emptyScreen.isHidden = true
    }
    
    func showEmptyScreen() {
        tableView.isHidden = true
        emptyScreen.isHidden = false
    }
}

extension NewsViewController {
    func cell(for data: NewsCell, in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: NewsTableViewCell.identifier,
                for: indexPath
            ) as? NewsTableViewCell else { return UITableViewCell() }
        cell.update(
            icon: data.icon,
            title: data.title,
            wasRead: data.wasRead,
            publishedAgo: data.publishedAgo,
            hasURL: data.hasURL
        )
        
        return cell
    }
}
