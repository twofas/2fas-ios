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

final class CollectionViewAdapter<Section, Cell>: NSObject, UICollectionViewDataSource
where Section: CollectionViewSection, Section.Cell == Cell {
    typealias CellProvider = (UICollectionView, IndexPath, Cell) -> UICollectionViewCell
    typealias TitleInSection = (UICollectionView, Int, CollectionViewDataSnapshot<Section, Cell>) -> String?
    typealias IndexTitlesProvider = (UICollectionView) -> [String]?
    typealias IndexPathForTitleProvider = (UICollectionView, String, Int) -> IndexPath
    typealias ViewForSupplementaryElementOfKind = (UICollectionView, String, IndexPath) -> UICollectionReusableView
    
    private weak var collectionView: UICollectionView?
    private let cellProvider: CellProvider
    
    private(set) var snapshot: CollectionViewDataSnapshot<Section, Cell>?
    private(set) var delegatee: CollectionViewDelegatee<Section, Cell>!
    
    var titleForHeader: TitleInSection?
    var titleForFooter: TitleInSection?
    var indexTitlesProvider: IndexTitlesProvider?
    var indexPathForTitleProvider: IndexPathForTitleProvider?
    var viewForSupplementaryElementOfKind: ViewForSupplementaryElementOfKind?
    
    init(
        collectionView: UICollectionView,
        cellProvider: @escaping CellProvider,
        delegatee: CollectionViewDelegatee<Section, Cell> = CollectionViewDelegatee<Section, Cell>()
    ) {
        self.collectionView = collectionView
        self.cellProvider = cellProvider
        super.init()
        self.delegatee = delegatee
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = delegatee
        apply(snapshot: CollectionViewDataSnapshot<Section, Cell>())
        delegatee.setAdapter(self)
    }
    
    func apply(snapshot: CollectionViewDataSnapshot<Section, Cell>) {
        self.snapshot = snapshot
        collectionView?.reloadData()
    }
    
    // MARK: - UICollectionViewDataSouce
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        snapshot?.numberOfSections ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        snapshot?.numberOfItems(for: section) ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let object = snapshot?.item(at: indexPath) else {
            fatalError("Error")
        }
        return cellProvider(collectionView, indexPath, object)
    }
    
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        indexTitlesProvider?(collectionView)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        indexPathForIndexTitle title: String,
        at index: Int
    ) -> IndexPath {
        guard let indexPathForTitleProvider else { fatalError("No indexPathForTitleProvider") }
        return indexPathForTitleProvider(collectionView, title, index)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let viewForSupplementaryElementOfKind else { fatalError("No viewForSupplementaryElementOfKind") }
        return viewForSupplementaryElementOfKind(collectionView, kind, indexPath)
    }
}
