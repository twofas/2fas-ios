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
import Storage
import Common

extension TokensViewController: UICollectionViewDragDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        itemsForBeginning session: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        guard !collectionView.hasActiveDrag && !collectionView.hasActiveDrop else { return [] }
        Log("Preparing drag & drop")
        guard let cell = gridCell(for: indexPath),
              let serviceData = cell.serviceData,
              cell.cellType != .placeholder
        else {
            Log("Cancelling drag")
            return []
        }

        Log("Preparing drag & drop - checking drag item")
        
        guard let dragItem = presenter.handleDragItem(for: serviceData) else { return [] }
        
        if presenter.shouldAddCustomPreview {
            dragItem.previewProvider = {
                let imageView = UIImageView(image: Asset.dragDropToken.image)
                imageView.tintColor = Theme.Colors.Fill.theme
                return UIDragPreview(view: imageView)
            }
        }
        Log("Preparing drag & drop - have the dragItem")
        
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
        Log("DragSessionWillBegin")
        presenter.handleDragSessionWillBegin()
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        Log("DragSessionDidEnd")
        presenter.handleDragSessionDidEnd()
    }
}

extension TokensViewController: UICollectionViewDropDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        guard
            presenter.canDragAndDrop,
            session.localDragSession != nil,
            collectionView.hasActiveDrag
        else { return UICollectionViewDropProposal(operation: .forbidden) }
        
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        performDropWith coordinator: UICollectionViewDropCoordinator
    ) {
        let items = coordinator.items
        guard items.count == 1,
            let item = items.first,
            let sourceIndexPath = item.sourceIndexPath,
            var destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        // if item is last we should fix the position otherwise it will be out of bounds
        if destinationIndexPath.section >= collectionView.numberOfSections {
            destinationIndexPath.section = collectionView.numberOfSections - 1
        }
        
        let snapshot = dataSource.snapshot()
        let sourceSection = snapshot.sectionIdentifiers[sourceIndexPath.section]
        let destinationSection = snapshot.sectionIdentifiers[destinationIndexPath.section]
        let draggedItem = snapshot.itemIdentifiers(inSection: sourceSection)[sourceIndexPath.row]
        // destination is an empty section
        if snapshot
            .itemIdentifiers(inSection: destinationSection)
            .first(where: { $0.cellType == .placeholder }) != nil {
            destinationIndexPath.row = 0
        }
        Log("Moving item from \(sourceIndexPath), to: \(destinationIndexPath)")
        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        
        guard let serviceData = draggedItem.serviceData else { return }
        
        presenter.handleMoveService(
            serviceData,
            from: sourceIndexPath,
            to: destinationIndexPath,
            newSection: destinationSection.sectionData
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        Log("Drop session did end")
        presenter.handleDragSessionDidEnd()
    }
}
