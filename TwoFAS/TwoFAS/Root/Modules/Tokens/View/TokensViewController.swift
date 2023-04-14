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
    private(set) var gridLayout: UICollectionViewFlowLayout!
    private(set) var dataSource: UICollectionViewDiffableDataSource<GridSection, GridCell>!
    
    let headerHeight: CGFloat = 50
    let emptySearchScreenView = GridViewEmptySearchScreen()
    let emptyListScreenView = GridViewEmptyListScreen()
    
    private var configuredWidth: CGFloat = 0
    var searchBarAdded = false
    
    let searchController = CommonSearchController()
    
    override func loadView() {
        gridLayout = UICollectionViewFlowLayout()
        gridView = GridView(frame: .zero, collectionViewLayout: gridLayout)
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureLayout()
    }
    
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
            cellProvider: { collectionView, indexPath, item in
                if item.cellType == .serviceTOTP {
                    if collectionView.isEditing {
                        let cell = collectionView.dequeueReusableCell(
                            withReuseIdentifier: GridViewEditItemCell.reuseIdentifier,
                            for: indexPath
                        ) as? GridViewEditItemCell
                        cell?.update(
                            name: item.name,
                            additionalInfo: item.additionalInfo,
                            serviceTypeName: item.serviceTypeName,
                            iconType: item.iconType,
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
                            iconType: item.iconType,
                            category: item.category,
                            useNextToken: item.useNextToken
                        )
                        return cell
                    }
                } else if item.cellType == .serviceHOTP {
                    if collectionView.isEditing {
                        let cell = collectionView.dequeueReusableCell(
                            withReuseIdentifier: GridViewEditItemCell.reuseIdentifier,
                            for: indexPath
                        ) as? GridViewEditItemCell
                        cell?.update(
                            name: item.name,
                            additionalInfo: item.additionalInfo,
                            serviceTypeName: item.serviceTypeName,
                            iconType: item.iconType,
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
                            iconType: item.iconType,
                            category: item.category
                        )
                        return cell
                    }
                }
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: GridEmptyCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as? GridEmptyCollectionViewCell
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
    
    func configureLayout() {
        guard let screenWidth = UIApplication.keyWindow?.bounds.size.width,
              configuredWidth != screenWidth else { return }
        
        configuredWidth = screenWidth
        
        let cellHeight = Theme.Metrics.servicesCellHeight
        
        let minimumCellWidth: CGFloat = Theme.Metrics.pageWidth
        let itemsInRow = Int(screenWidth / minimumCellWidth)
        let margin: CGFloat = 0
        
        let marginsWidth = margin * CGFloat(itemsInRow - 1)
        let screenWidthWithoutMargins = screenWidth - marginsWidth
        let elementWidth = floor(screenWidthWithoutMargins / CGFloat(itemsInRow))
        
        gridLayout.itemSize = CGSize(width: elementWidth, height: cellHeight)
        gridLayout.minimumInteritemSpacing = margin
                
        gridLayout.minimumLineSpacing = 0
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
            self, selector: #selector(notificationServicesWereUpdated), name: .servicesWereUpdated, object: nil
        )
        center.addObserver(
            self, selector: #selector(notificationSectionsWereUpdated), name: .sectionsWereUpdated, object: nil
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
