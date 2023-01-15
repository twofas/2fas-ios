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

final class TableViewAdapter<Section, Cell>: NSObject, UITableViewDataSource where Section: TableViewSection,
                                                                                   Section.Cell == Cell {
    typealias CellProvider = (UITableView, IndexPath, Cell) -> UITableViewCell
    typealias TitleInSection = (UITableView, Int, TableViewDataSnapshot<Section, Cell>) -> String?
    
    private weak var tableView: UITableView?
    private let cellProvider: CellProvider

    private(set) var snapshot: TableViewDataSnapshot<Section, Cell>?
    private(set) var delegatee: TableViewDelegatee<Section, Cell>!
    
    var titleForHeader: TitleInSection?
    var titleForFooter: TitleInSection?
    
    init(
        tableView: UITableView,
        cellProvider: @escaping CellProvider
    ) {
        self.tableView = tableView
        self.cellProvider = cellProvider
        super.init()
        delegatee = TableViewDelegatee(adapter: self)
        self.tableView?.dataSource = self
        self.tableView?.delegate = delegatee
        apply(snapshot: TableViewDataSnapshot<Section, Cell>())
    }
    
    func apply(snapshot: TableViewDataSnapshot<Section, Cell>) {
        self.snapshot = snapshot
        tableView?.reloadData()
    }
    
    func update(snapshot: TableViewDataSnapshot<Section, Cell>) {
        self.snapshot = snapshot
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        snapshot?.numberOfSections ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        snapshot?.numberOfItems(for: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let object = snapshot?.item(at: indexPath) else {
            fatalError("No snapshot item")
        }
        return cellProvider(tableView, indexPath, object)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let snapshot else { return nil }
        return titleForHeader?(tableView, section, snapshot)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let snapshot else { return nil }
        return titleForFooter?(tableView, section, snapshot)
    }
}
