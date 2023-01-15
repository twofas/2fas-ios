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

extension TokensViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard
            let cell = gridCell(for: indexPath),
                let serviceData = cell.serviceData,
                presenter.enableMenu
        else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let edit = UIAction(
                title: T.Commons.edit,
                image: UIImage(systemName: "square.and.pencil")
            ) { [weak self] _ in
                self?.presenter.handleEditService(serviceData)
            }
            
            let copy = UIAction(
                title: T.Tokens.copyToken,
                image: UIImage(systemName: "doc.on.doc")
            ) { [weak self] _ in
                self?.presenter.handleCopyToken(from: serviceData)
            }

            let delete = UIAction(
                title: T.Commons.delete,
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.presenter.handleDeleteService(serviceData)
            }
            
            return UIMenu(title: T.Commons.service, children: [edit, copy, delete])
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        presenter.handleMenuEnded()
    }
}
