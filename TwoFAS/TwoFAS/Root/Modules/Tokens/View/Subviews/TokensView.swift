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

final class TokensView: UICollectionView {
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
        register(TokensTOTPCell.self, forCellWithReuseIdentifier: TokensTOTPCell.reuseIdentifier)
        register(TokensHOTPCell.self, forCellWithReuseIdentifier: TokensHOTPCell.reuseIdentifier)
        register(TokensEditCell.self, forCellWithReuseIdentifier: TokensEditCell.reuseIdentifier)
        register(TokensTOTPCompactCell.self, forCellWithReuseIdentifier: TokensTOTPCompactCell.reuseIdentifier)
        register(TokensHOTPCompactCell.self, forCellWithReuseIdentifier: TokensHOTPCompactCell.reuseIdentifier)
        register(
            TokensEmptyDropSpaceCell.self,
            forCellWithReuseIdentifier: TokensEmptyDropSpaceCell.reuseIdentifier
        )
        register(
            TokensSectionHeader.self,
            forSupplementaryViewOfKind: TokensSectionHeader.reuseIdentifier,
            withReuseIdentifier: TokensSectionHeader.reuseIdentifier
        )
        register(
            TokensLine.self,
            forSupplementaryViewOfKind: TokensLine.reuseIdentifier,
            withReuseIdentifier: TokensLine.reuseIdentifier
        )
    
        allowsSelectionDuringEditing = true
    }
    
    private func reloadHeaders() {
        guard let visible = visibleSupplementaryViews(
            ofKind: UICollectionView.elementKindSectionHeader
        ) as? [TokensSectionHeader] else { return }
        visible.forEach({ $0.setIsEditing(isEditing) })
    }
}
