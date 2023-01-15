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
import UIKit

class CollectionViewDelegatee<Section, Cell>: NSObject, UICollectionViewDelegate
where Section: CollectionViewSection, Section.Cell == Cell {
    typealias ShouldSelectItemAt = (UICollectionView, IndexPath) -> Bool
    typealias DidSelectItemAt = (UICollectionView, IndexPath) -> Void
    typealias WillDisplayCellForItemAt = (UICollectionView, UICollectionViewCell, IndexPath) -> Void
    typealias DidEndDisplayingCellForItemAt = (UICollectionView, UICollectionViewCell, IndexPath) -> Void
    typealias CanEditItemAt = (UICollectionView, IndexPath) -> Bool
    typealias ContextMenuConfigurationAt = (UICollectionView, IndexPath) -> UIContextMenuConfiguration?
    typealias ContextMenuWillEnd = (UICollectionView, UIContextMenuConfiguration) -> Void
    
    private var adapter: CollectionViewAdapter<Section, Cell>?

    func setAdapter(_ adapter: CollectionViewAdapter<Section, Cell>) {
        self.adapter = adapter
    }
    
    var shouldSelectItemAt: ShouldSelectItemAt?
    var didSelectItemAt: DidSelectItemAt?
    var willDisplayCellForItemAt: WillDisplayCellForItemAt?
    var didEndDisplayingCellForItemAt: DidEndDisplayingCellForItemAt?
    var canEditItemAt: CanEditItemAt?
    var contextMenuConfigurationAt: ContextMenuConfigurationAt?
    var contextMenuWillEnd: ContextMenuWillEnd?
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        shouldSelectItemAt?(collectionView, indexPath) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItemAt?(collectionView, indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath
    ) {
        willDisplayCellForItemAt?(collectionView, cell, indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath
    ) {
        didEndDisplayingCellForItemAt?(collectionView, cell, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        canEditItemAt?(collectionView, indexPath) ?? false
    }

    func collectionView(
        _ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint
    ) -> UIContextMenuConfiguration? {
        contextMenuConfigurationAt?(collectionView, indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        contextMenuWillEnd?(collectionView, configuration)
    }
}
