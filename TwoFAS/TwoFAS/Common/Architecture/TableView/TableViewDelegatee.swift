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

final class TableViewDelegatee<Section, Cell>: NSObject, UITableViewDelegate
where Section: TableViewSection, Section.Cell == Cell {
    typealias DidSelectItem = ((UITableView, IndexPath, Cell) -> Void)
    typealias DisplayCell = ((UITableView, UITableViewCell, IndexPath) -> Void)
    typealias ViewForIndex = ((UITableView, Int) -> UIView)
    typealias SizeForIndex = ((UITableView, Int) -> CGFloat)
    typealias ContextMenuConfiguration = ((UITableView, IndexPath, CGPoint) -> UIContextMenuConfiguration?)
    
    private let adapter: TableViewAdapter<Section, Cell>?
    
    init(adapter: TableViewAdapter<Section, Cell>) {
        self.adapter = adapter
    }
    
    var didSelectItem: DidSelectItem?
    var header: ViewForIndex?
    var footer: ViewForIndex?
    var sizeForHeader: SizeForIndex?
    var sizeForFooter: SizeForIndex?
    var willDisplayCell: DisplayCell?
    var didEndDisplayingCell: DisplayCell?
    var contextMenuConfiguration: ContextMenuConfiguration?
    var willEndContextMenu: Callback?
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        header?(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footer?(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        sizeForHeader?(tableView, section) ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        sizeForFooter?(tableView, section) ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let object = adapter?.snapshot?.item(at: indexPath) else {
            fatalError("No object in snapshot")
        }
        didSelectItem?(tableView, indexPath, object)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        willDisplayCell?(tableView, cell, indexPath)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        didEndDisplayingCell?(tableView, cell, indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        contextMenuConfiguration?(tableView, indexPath, point)
    }
    
    func tableView(
        _ tableView: UITableView,
        willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        willEndContextMenu?()
    }
}
