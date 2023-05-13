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
import Common

final class TokensViewController: UIViewController {
    var presenter: TokensPresenter!
    var addButton: UIBarButtonItem? {
        navigationItem.rightBarButtonItem
    }
    private(set) var gridView: GridView!
    private(set) var dataSource: UICollectionViewDiffableDataSource<GridSection, GridCell>!
    
    let headerHeight: CGFloat = 44
    let emptySearchScreenView = GridViewEmptySearchScreen()
    let emptyListScreenView = GridViewEmptyListScreen()
    
    private var layout: UICollectionViewCompositionalLayout!
    
    var searchBarAdded = false
    
    let searchController = CommonSearchController()
    
    override func loadView() {
        createLayout()
        gridView = GridView(frame: .zero, collectionViewLayout: layout)
        self.view = gridView
        gridView.configure()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupEmptyScreensLayout()
        setupEmptyScreensEvents()
        setupDelegates()
        setupDataSource()
        setupDragAndDrop()
        setupNotificationsListeners()
    }
    
    func scrollToTop() {
        let snapshot = dataSource.snapshot()
        let indexPath = IndexPath(row: 0, section: 0)
        guard snapshot.item(for: indexPath) != nil else { return }
        gridView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    // MARK: - App events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
        navigationController?.setNavigationBarHidden(false, animated: animated)
        startSafeAreaKeyboardAdjustment()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        stopSafeAreaKeyboardAdjustment()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension TokensViewController {
    func setupView() {
        extendedLayoutIncludesOpaqueBars = true
        view.backgroundColor = Theme.Colors.Fill.background
        title = T.Commons.tokens
        accessibilityTraits = .header
    }
    
    func setupDelegates() {
        searchController.searchBarDelegate = self
        gridView.delegate = self
    }
    
    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: gridView,
            cellProvider: { collectionView, indexPath, item -> UICollectionViewCell? in
                if item.cellType == .serviceTOTP {
                    if collectionView.isEditing {
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
                    } else {
                        let cell = collectionView.dequeueReusableCell(
                            withReuseIdentifier: GridViewItemCell.reuseIdentifier,
                            for: indexPath
                        ) as? GridViewItemCell
                        cell?.update(
                            name: item.name,
                            secret: item.secret,
                            serviceTypeName: item.serviceTypeName,
                            additionalInfo: item.additionalInfo,
                            logoType: item.logoType,
                            category: item.category,
                            useNextToken: item.useNextToken
                        )
                        return cell
                    }
                } else if item.cellType == .serviceHOTP {
                    if collectionView.isEditing {
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
                    } else {
                        let cell = collectionView.dequeueReusableCell(
                            withReuseIdentifier: GridViewCounterItemCell.reuseIdentifier,
                            for: indexPath
                        ) as? GridViewCounterItemCell
                        cell?.update(
                            name: item.name,
                            secret: item.secret,
                            serviceTypeName: item.serviceTypeName,
                            additionalInfo: item.additionalInfo,
                            logoType: item.logoType,
                            category: item.category
                        )
                        return cell
                    }
                }
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TokensEmptyDropSpaceCell.reuseIdentifier,
                    for: indexPath
                ) as? TokensEmptyDropSpaceCell
                return cell
            })
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath
            -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: GridSectionHeader.reuseIdentifier,
                for: indexPath
            ) as? GridSectionHeader
            header?.setIsEditing(collectionView.isEditing)
            header?.dataSource = self
            if let data = self?.dataSource.snapshot().sectionIdentifiers[indexPath.section] {
                header?.setConfiguration(data)
            }
            return header
        }
    }
    
    func setupDragAndDrop() {
        gridView.dragDelegate = self
        gridView.dropDelegate = self
        gridView.dragInteractionEnabled = presenter.enableDragAndDropOnStart
    }
    
    func setupEmptyScreensLayout() {
        view.addSubview(emptySearchScreenView, with: [
            emptySearchScreenView.leadingAnchor.constraint(equalTo: gridView.frameLayoutGuide.leadingAnchor),
            emptySearchScreenView.trailingAnchor.constraint(equalTo: gridView.frameLayoutGuide.trailingAnchor),
            emptySearchScreenView.topAnchor.constraint(equalTo: gridView.frameLayoutGuide.topAnchor),
            emptySearchScreenView.bottomAnchor.constraint(equalTo: gridView.frameLayoutGuide.bottomAnchor)
        ])
        emptySearchScreenView.isHidden = true
        emptySearchScreenView.alpha = 0
        
        view.addSubview(emptyListScreenView, with: [
            emptyListScreenView.leadingAnchor.constraint(equalTo: gridView.frameLayoutGuide.leadingAnchor),
            emptyListScreenView.trailingAnchor.constraint(equalTo: gridView.frameLayoutGuide.trailingAnchor),
            emptyListScreenView.topAnchor.constraint(equalTo: gridView.safeTopAnchor),
            emptyListScreenView.bottomAnchor.constraint(equalTo: gridView.safeBottomAnchor)
        ])
        emptyListScreenView.isHidden = true
        emptyListScreenView.alpha = 0
    }
    
    private func createLayout() {
        layout = UICollectionViewCompositionalLayout { [weak self] sectionOffset, env in
            guard let self else { return nil }
            let minimumCellWidth: CGFloat = Theme.Metrics.pageWidth
            let itemsInRow: Int = {
                let snapshot = self.dataSource.snapshot()
                if let section = snapshot.sectionIdentifiers[safe: sectionOffset],
                   let item = snapshot.itemIdentifiers(inSection: section).first,
                   item.cellType == .placeholder {
                    return 1
                }
                let availableWidth = env.container.effectiveContentSize.width
                var columns = Int(availableWidth / minimumCellWidth)
                let layoutMultiplier = env.traitCollection.preferredContentSizeCategory.layoutMultiplier
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
                heightDimension: .estimated(60) // TODO: Move to constant depending on cell type
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(60) // TODO: Move to constant depending on cell type
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: itemsInRow
            )
            
            let headerFooterSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(self.headerHeight)
            )
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            sectionHeader.pinToVisibleBounds = true
            let section = NSCollectionLayoutSection(group: group)
            
            if !(!self.gridView.isEditing && sectionOffset == 0 && self.presenter.isMainOnlyCategory) {
                section.boundarySupplementaryItems = [sectionHeader]
            }
            
            return section
        }
    }
    
    func setupEmptyScreensEvents() {
        emptyListScreenView.pairNewService = { [weak self] in self?.presenter.handleAddService() }
        emptyListScreenView.importFromExternalService = { [weak self] in
            AppEventLog(.onboardingBackupFile)
            self?.presenter.handleImportExternalFile()
        }
        emptyListScreenView.help = { [weak self] in self?.presenter.handleShowHelp() }
    }
    
    func setupNotificationsListeners() {
        let center = NotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(notificationServicesWereUpdated),
            name: .servicesWereUpdated,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(notificationSectionsWereUpdated),
            name: .sectionsWereUpdated,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(notificationAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(notificationAppDidBecomeInactive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(notificationAppDidBecomeInactive),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(tokensScreenIsVisible),
            name: .tokensScreenIsVisible,
            object: nil
        )
    }
}

extension UIContentSizeCategory {
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
