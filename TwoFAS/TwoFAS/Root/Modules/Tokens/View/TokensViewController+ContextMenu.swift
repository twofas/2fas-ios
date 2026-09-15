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
        
        beginContextMenuLift()
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let edit = UIAction(
                title: T.Commons.edit,
                image: UIImage(icon: .squareAndPencil)
            ) { [weak self] _ in
                self?.presenter.handleEditService(serviceData)
            }
            
            let copy = UIAction(
                title: T.Tokens.copyToken,
                image: UIImage(icon: .docOnDoc)
            ) { [weak self] _ in
                self?.presenter.handleCopyToken(from: serviceData)
            }

            let delete = UIAction(
                title: T.Commons.delete,
                image: UIImage(icon: .trash),
                attributes: .destructive
            ) { [weak self] _ in
                self?.presenter.handleDeleteService(serviceData)
            }
            
            let topActions = [edit, copy, delete]
            
            let canMoveUp = self?.presenter.canMoveServiceUp(serviceData) == true
            let canModeDown = self?.presenter.canMoveServiceDown(serviceData) == true
            
            if canMoveUp || canModeDown {
                let divider = UIMenu(title: "", options: .displayInline, children: topActions)
                var actions: [UIMenuElement] = [divider]
                if canMoveUp {
                    actions.append(UIAction(
                        title: T.Tokens.moveUp,
                        image: UIImage(icon: .chevronUp)
                    ) { [weak self] _ in
                        self?.presenter.handleMoveServiceUp(serviceData)
                    })
                }
                if canModeDown {
                    actions.append(UIAction(
                        title: T.Tokens.moveDown,
                        image: UIImage(icon: .chevronDown)
                    ) { [weak self] _ in
                        self?.presenter.handleMoveServiceDown(serviceData)
                    })
                }
                return UIMenu(title: T.Commons.service, children: actions)
            } else {
                return UIMenu(title: T.Commons.service, children: topActions)
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplayContextMenu configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        if case .lifting(let expiry) = contextMenuState {
            expiry.cancel()
        }
        contextMenuState = .shown
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        presenter.handleMenuEnded()
        if case .lifting(let expiry) = contextMenuState {
            expiry.cancel()
        }
        contextMenuState = .none
        // The cell flies back into the list first, so a reload that came in the meantime does not swap it
        // mid-flight. A reload triggered by the chosen action is not held back: the state is already clear.
        if let animator {
            animator.addCompletion { [weak self] in
                self?.applyPendingReload()
            }
        } else {
            applyPendingReload()
        }
    }
    
    var isContextMenuActive: Bool {
        switch contextMenuState {
        case .none: return false
        case .lifting, .shown: return true
        }
    }
    
    /// Once the lift has run for this long with no menu shown, the press was released early and the
    /// interaction is over. UIKit does not report a lift that ends before the menu appears.
    private static let contextMenuLiftTimeout: TimeInterval = 2
    
    private func beginContextMenuLift() {
        if case .lifting(let expiry) = contextMenuState {
            expiry.cancel()
        }
        let expiry = DispatchWorkItem { [weak self] in
            guard let self, case .lifting = self.contextMenuState else { return }
            self.contextMenuState = .none
            self.applyPendingReload()
        }
        contextMenuState = .lifting(expiry: expiry)
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.contextMenuLiftTimeout, execute: expiry)
    }
    
    private func applyPendingReload() {
        guard let pendingReload else { return }
        self.pendingReload = nil
        reloadData(newSnapshot: pendingReload.snapshot, scrollTo: pendingReload.scrollTo)
    }
}
