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

final class GridView: UICollectionView {
    override var isEditing: Bool {
        get {
            super.isEditing
        }
        
        set {
            guard newValue != super.isEditing else { return }
            super.isEditing = newValue
            reloadHeaders()
        }
    }
    
    func configure() {
        backgroundColor = Theme.Colors.Fill.background
        register(GridViewItemCell.self, forCellWithReuseIdentifier: GridViewItemCell.reuseIdentifier)
        register(GridViewCounterItemCell.self, forCellWithReuseIdentifier: GridViewCounterItemCell.reuseIdentifier)
        register(TokensEditCell.self, forCellWithReuseIdentifier: TokensEditCell.reuseIdentifier)
        register(
            TokensEmptyDropSpaceCell.self,
            forCellWithReuseIdentifier: TokensEmptyDropSpaceCell.reuseIdentifier
        )
        register(
            GridSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: GridSectionHeader.reuseIdentifier
        )
        allowsSelectionDuringEditing = true
    }
    
    private func reloadHeaders() {
        guard let visible = visibleSupplementaryViews(
            ofKind: UICollectionView.elementKindSectionHeader
        ) as? [GridSectionHeader] else { return }
        visible.forEach({ $0.setIsEditing(isEditing) })
    }
}
