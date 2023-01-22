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

final class IconSelectorCollectionViewDelegatee<Section, Cell>:
    CollectionViewDelegatee<Section, Cell>, UICollectionViewDelegateFlowLayout
where Section: CollectionViewSection, Section.Cell == Cell {
    var presenter: IconSelectorPresenter!
    weak var collectionViewAdapter: CollectionViewAdapter<IconSelectorSection, IconSelectorCell>?
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let height: CGFloat = {
            if presenter.isSearching {
                return IconSelectorHeaderReusableView.dimension
            }
            if section == 0 {
                return IconSelectorOrderIconReusableView.dimension
            }
            return IconSelectorHeaderReusableView.dimension
        }()
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let snapshot = collectionViewAdapter?.snapshot
        let horizontalMargin: CGFloat = Theme.Metrics.doubleMargin * 2
        
        let spacing: CGFloat = Theme.Metrics.mediumSpacing
        guard
            let count = snapshot?.items(at: section).count,
            count == 1
        else {
            return .init(top: spacing, left: horizontalMargin, bottom: spacing, right: horizontalMargin)
        }
        let cellWidth = IconSelectorCollectionViewCell.dimension
        let width = collectionView.bounds.size.width
        let right = width - cellWidth - 2 * horizontalMargin + 2 * spacing
        return .init(top: spacing, left: horizontalMargin, bottom: spacing, right: right)
    }
}
