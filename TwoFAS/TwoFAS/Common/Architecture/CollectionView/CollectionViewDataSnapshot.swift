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

import Foundation

protocol CollectionViewSection: Hashable {
    associatedtype Cell: Hashable
    var cells: [Cell] { get set }
}

final class CollectionViewDataSnapshot<Section, Cell> where Section: CollectionViewSection, Section.Cell == Cell {
    private var items: [Section] = []
    
    var numberOfSections: Int { items.count }
    
    func setItems(_ items: [Section]) {
        self.items = items
    }
    
    func numberOfItems(for section: Int) -> Int {
        items[safe: section]?.cells.count ?? 0
    }
    
    func item(at indexPath: IndexPath) -> Cell? {
        items[safe: indexPath.section]?.cells[safe: indexPath.row]
    }
    
    func items(at section: Int = 0) -> [Cell] {
        items[safe: section]?.cells ?? []
    }
    
    func appendSection(_ item: Section) {
        items.append(item)
    }
    
    func deleteSection(at index: Int) {
        items.remove(at: index)
    }
    
    func deleteSection(_ section: Section) {
        guard let index = items.firstIndex(of: section) else { return }
        items.remove(at: index)
    }
    
    func replaceSection(_ section: Section, with newSection: Section) {
        guard let index = items.firstIndex(of: section) else { return }
        items[index] = newSection
    }
    
    func replaceSection(at index: Int, with item: Section) {
        items[index] = item
    }
    
    func section(at index: Int) -> Section {
        items[index]
    }
    
    func appendCell(_ item: Cell, at section: Int) {
        var cells = items[section].cells
        cells.append(item)
        items[section].cells = cells
    }
    
    func deleteCell(at index: Int, at section: Int) {
        var cells = items[section].cells
        cells.remove(at: index)

        items[section].cells = cells
    }
    
    func replaceCell(_ index: Int, with item: Cell, at section: Int = 0) {
        var cells = items[section].cells
        cells[index] = item
        
        items[section].cells = cells
    }
    
    func removeAll() {
        items.removeAll()
    }
}
