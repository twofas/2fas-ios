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

extension IconSelectorViewController {
    func cell(
        for data: IconSelectorSection.Cell,
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: IconSelectorCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? IconSelectorCollectionViewCell
        else { return nil }
        
        cell.setIcon(data.icon, serviceName: data.title, showTitle: data.showTitle)
        return cell
    }
    
    func supplementaryView(
        for kind: String,
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if indexPath.section == 0 && !presenter.isSearching {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: IconSelectorOrderIconReusableView.reuseIdentifier,
                for: indexPath) as? IconSelectorOrderIconReusableView
            else { return UICollectionReusableView() }
            header.setTitle(presenter.handleTitle(for: indexPath))
            header.didTapLink = { [weak self, weak header] in
                guard let header else { return }
                self?.presenter.handleOrderIcon(sourceView: header)
            }
            return header
        }
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: IconSelectorHeaderReusableView.reuseIdentifier,
            for: indexPath) as? IconSelectorHeaderReusableView
        else { return UICollectionReusableView() }
        header.setTitle(presenter.handleTitle(for: indexPath))
        return header
    }
}
