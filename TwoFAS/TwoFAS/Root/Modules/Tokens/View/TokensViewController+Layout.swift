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
import Data

extension TokensViewController {
    func getCell(
        for collectionView: UICollectionView,
        indexPath: IndexPath,
        item: TokenCell
    ) -> UICollectionViewCell? {
        switch item.cellType {
        case .serviceTOTP, .serviceSteam:
            if collectionView.isEditing {
                return getEditCell(for: collectionView, indexPath: indexPath, item: item)
            }
            return getTOTPCell(for: collectionView, indexPath: indexPath, item: item)
        case .serviceHOTP:
            if collectionView.isEditing {
                return getEditCell(for: collectionView, indexPath: indexPath, item: item)
            }
            return getHOTPCell(for: collectionView, indexPath: indexPath, item: item)
        case .placeholder:
            return placeholderCell(for: collectionView, indexPath: indexPath)
        case .pass:
            return passCell(for: collectionView, indexPath: indexPath)
        }
    }
    
    func placeholderCell(for collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(
            withReuseIdentifier: TokensEmptyDropSpaceCell.reuseIdentifier,
            for: indexPath
        )
    }

    func passCell(for collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TokensPassCell.reuseIdentifier,
            for: indexPath
        ) as? TokensPassCell
        cell?.cancelAction = { [weak self] in
            self?.presenter.passCellCancel()
        }
        cell?.gotoStoreAction = { [weak self] in
            self?.presenter.passCellGoToStore()
        }
        return cell ?? UICollectionViewCell()
    }
    
    func getEditCell(
        for collectionView: UICollectionView,
        indexPath: IndexPath,
        item: TokenCell
    ) -> UICollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TokensEditCell.reuseIdentifier,
            for: indexPath
        ) as? TokensEditCell
        cell?.update(
            name: item.name,
            additionalInfo: item.additionalInfo,
            serviceTypeName: item.serviceTypeName,
            logoType: item.logoType,
            category: item.category,
            canBeDragged: item.canBeDragged
        )
        return cell
    }
    
    func getTOTPCell(
        for collectionView: UICollectionView,
        indexPath: IndexPath,
        item: TokenCell
    ) -> UICollectionViewCell? {
        let cell: (UICollectionViewCell & TokensTOTPCellType)? = {
            switch presenter.listStyle {
            case .default: return collectionView.dequeueReusableCell(
                withReuseIdentifier: TokensTOTPCell.reuseIdentifier,
                for: indexPath
            ) as? TokensTOTPCell
            case .compact: return collectionView.dequeueReusableCell(
                withReuseIdentifier: TokensTOTPCompactCell.reuseIdentifier,
                for: indexPath
            ) as? TokensTOTPCompactCell
            }
        }()
        cell?.update(
            name: item.name,
            secret: item.secret,
            serviceTypeName: item.serviceTypeName,
            additionalInfo: item.additionalInfo,
            logoType: item.logoType,
            category: item.category,
            useNextToken: item.useNextToken,
            shouldAnimate: presenter.shouldAnimate
        )
        cell?.accessibilityCustomActions = tokenActions(item)
        return cell
    }

    func getHOTPCell(
        for collectionView: UICollectionView,
        indexPath: IndexPath,
        item: TokenCell
    ) -> UICollectionViewCell? {
        let cell: (UICollectionViewCell & TokensHOTPCellType)? = {
            switch presenter.listStyle {
            case .default: return collectionView.dequeueReusableCell(
                withReuseIdentifier: TokensHOTPCell.reuseIdentifier,
                for: indexPath
            ) as? TokensHOTPCell
            case .compact: return collectionView.dequeueReusableCell(
                withReuseIdentifier: TokensHOTPCompactCell.reuseIdentifier,
                for: indexPath
            ) as? TokensHOTPCompactCell
            }
        }()
        cell?.update(
            name: item.name,
            secret: item.secret,
            serviceTypeName: item.serviceTypeName,
            additionalInfo: item.additionalInfo,
            logoType: item.logoType,
            category: item.category,
            shouldAnimate: presenter.shouldAnimate
        )
        cell?.accessibilityCustomActions = tokenActions(item)
        return cell
    }
    
    func getHeader(
        for collectionView: UICollectionView,
        kind: String,
        indexPath: IndexPath
    ) -> UICollectionReusableView? {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: kind,
            for: indexPath
        )
        if kind == TokensSectionHeader.reuseIdentifier {
            let header = header as? TokensSectionHeader
            header?.setIsEditing(collectionView.isEditing)
            header?.dataSource = self
            if let data = dataSource.snapshot().sectionIdentifiers[safe: indexPath.section] {
                header?.setConfiguration(data)
            }
        }
        return header
    }
    
    func getLayout(sectionOffset: Int, enviroment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let snapshot = self.dataSource.snapshot()
        if let section = snapshot.sectionIdentifiers[safe: sectionOffset],
           let item = snapshot.itemIdentifiers(inSection: section).first,
           item.cellType == .pass {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(TokensPassCell.height)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(TokensPassCell.height)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .zero
            return section
        }

        let minimumCellWidth: CGFloat = {
            guard presenter.listStyle == .default else { return Theme.Metrics.compactCellWidth }
            return Theme.Metrics.defaultCellWidth
        }()
        let itemsInRow: Int = {
            let snapshot = self.dataSource.snapshot()
            if let section = snapshot.sectionIdentifiers[safe: sectionOffset],
               let item = snapshot.itemIdentifiers(inSection: section).first,
               item.cellType == .placeholder {
                return 1
            }
            let availableWidth = enviroment.container.effectiveContentSize.width
            var columns = Int(availableWidth / minimumCellWidth)
            let layoutMultiplier: CGFloat = {
                guard presenter.listStyle == .default else { return 1.0 }
                return enviroment.traitCollection.preferredContentSizeCategory.layoutMultiplier
            }()
            if columns > 1 && layoutMultiplier != 1.0 {
                let newSize = minimumCellWidth * layoutMultiplier
                columns = Int(availableWidth / newSize)
            }
            if columns < 1 {
                columns = 1
            }
            return columns
        }()
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: cellHeight()
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / CGFloat(itemsInRow)),
            heightDimension: cellHeight()
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: itemsInRow
        )
        
        let headerFooterSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(headerHeight)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: TokensSectionHeader.reuseIdentifier,
            alignment: .top
        )
        sectionHeader.pinToVisibleBounds = false
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        
        if !(!tokensView.isEditing && sectionOffset == 0 && presenter.isMainOnlyCategory) {
            section.boundarySupplementaryItems = [sectionHeader]
        }
        
        return section
    }
    
    /// Mirrors the header of the section whose own header has reached the top of the visible area
    /// and pushes it away when the next section's header arrives. The mirrored list header hides
    /// its content so the two never draw on top of each other; sections without a header and the
    /// empty screens leave the floating header hidden.
    func updateFloatingHeader() {
        guard dataSource != nil, floatingHeader != nil else { return }
        let layout = tokensView.collectionViewLayout
        let kind = TokensSectionHeader.reuseIdentifier
        let pinLine = tokensView.contentOffset.y + tokensView.adjustedContentInset.top
        var current: Int?
        var nextHeaderTop: CGFloat?
        for section in 0..<tokensView.numberOfSections {
            guard let attributes = layout.layoutAttributesForSupplementaryView(
                ofKind: kind,
                at: IndexPath(item: 0, section: section)
            ) else { continue }
            if attributes.frame.minY <= pinLine {
                current = section
            } else {
                nextHeaderTop = attributes.frame.minY
                break
            }
        }
        let emptyScreenShown = !emptySearchScreenView.isHidden || !emptyListScreenView.isHidden
        let mirrored: Int? = emptyScreenShown ? nil : current
        for indexPath in tokensView.indexPathsForVisibleSupplementaryElements(ofKind: kind) {
            (tokensView.supplementaryView(forElementKind: kind, at: indexPath) as? TokensSectionHeader)?
                .isContentHidden = indexPath.section == mirrored
        }
        guard let mirrored, let section = dataSource.sectionIdentifier(for: mirrored) else {
            floatingHeader.isHidden = true
            return
        }
        if floatingHeader.header.isEditing != tokensView.isEditing {
            floatingHeader.header.setIsEditing(tokensView.isEditing)
        }
        if floatingHeader.header.config != section {
            floatingHeader.header.setConfiguration(section)
        }
        floatingHeader.isHidden = false
        if let nextHeaderTop {
            // Before the first layout pass the floating header has no size yet; every section
            // header shares the same height, so the layout's estimate is a good stand-in.
            let measured = floatingHeader.header.bounds.height
            let height = measured > 0 ? measured : headerHeight
            floatingHeader.pushOffset = min(0, nextHeaderTop - pinLine - height)
        } else {
            floatingHeader.pushOffset = 0
        }
    }

    func cellHeight() -> NSCollectionLayoutDimension {
        guard !tokensView.isEditing else {
            return .estimated(60)
        }
        switch presenter.listStyle {
        case .default: return .estimated(135)
        case .compact: return .absolute(90)
        }
    }
    
    /// Returns some actions a user can do using *Voice Over*.
    /// There are the same actions as the ones defined in the *context menu*.
    private func tokenActions(_ token: TokenCell) -> [UIAccessibilityCustomAction] {
        guard let serviceData = token.serviceData else { return [] }
        return [
            UIAccessibilityCustomAction(name: T.Commons.edit,
                                        actionHandler: { (_: UIAccessibilityCustomAction) -> Bool in
                                            self.presenter.handleEditService(serviceData)
                                            return true
                                        }),
            
            UIAccessibilityCustomAction(name: T.Tokens.copyToken,
                                        actionHandler: { (_: UIAccessibilityCustomAction) -> Bool in
                                            self.presenter.handleCopyToken(from: serviceData)
                                            return true
                                        }),
            
            UIAccessibilityCustomAction(name: T.Commons.delete,
                                        actionHandler: { (_: UIAccessibilityCustomAction) -> Bool in
                                            self.presenter.handleDeleteService(serviceData)
                                            return true
                                        })
        ]
    }
}

private extension UIContentSizeCategory {
    var layoutMultiplier: CGFloat {
        switch self {
        case UIContentSizeCategory.accessibilityExtraExtraExtraLarge: return 23.0 / 16.0
        case UIContentSizeCategory.accessibilityExtraExtraLarge: return 22.0 / 16.0
        case UIContentSizeCategory.accessibilityExtraLarge: return 21.0 / 16.0
        case UIContentSizeCategory.accessibilityLarge: return 20.0 / 16.0
        case UIContentSizeCategory.accessibilityMedium: return 19.0 / 16.0
        case UIContentSizeCategory.extraExtraExtraLarge: return 19.0 / 16.0
        case UIContentSizeCategory.extraExtraLarge: return 18.0 / 16.0
        case UIContentSizeCategory.extraLarge: return 17.0 / 16.0
        case UIContentSizeCategory.large: return 1.0
        case UIContentSizeCategory.medium: return 15.0 / 16.0
        case UIContentSizeCategory.small: return 14.0 / 16.0
        case UIContentSizeCategory.extraSmall: return 13.0 / 16.0
        default: return 1.0
        }
    }
}
