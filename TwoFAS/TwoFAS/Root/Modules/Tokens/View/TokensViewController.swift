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
import SwiftUI
import Common
import Data

final class TokensViewController: UIViewController {
    enum NewsButtonType {
        case unread(UIBarButtonItem)
        case read(UIBarButtonItem)
    }

    var presenter: TokensPresenter!
    var addButton: UIBarButtonItem? {
        navigationItem.rightBarButtonItem
    }
    var newsButton: NewsButtonType?

    var newsButtonSourceView: UIView? {
        guard #available(iOS 26.0, *) else { return nil }
        let item: UIBarButtonItem?
        switch newsButton {
        case .unread(let button), .read(let button): item = button
        case .none: item = nil
        }
        guard let view = item?.customView,
              view.window != nil,
              view.bounds.width > 0,
              view.bounds.height > 0
        else { return nil }
        return view
    }

    private(set) var tokensView: TokensView!
    private(set) var dataSource: UICollectionViewDiffableDataSource<TokensSection, TokenCell>!
    
    let headerHeight: CGFloat = 44
    let emptySearchScreenView = TokensViewEmptySearchScreen()

    let emptyListModel = TokensEmptyListModel()
    private(set) lazy var emptyListHostingController = UIHostingController(
        rootView: TokensEmptyListView(model: emptyListModel)
    )
    var emptyListScreenView: UIView { emptyListHostingController.view }
    
    private var layout: UICollectionViewCompositionalLayout!
    
    var searchBarAdded = false
    var pendingSearchFocus = false

    let searchController = CommonSearchController()
    
    override func loadView() {
        createLayout()
        tokensView = TokensView(frame: .zero, collectionViewLayout: layout)
        self.view = tokensView
        tokensView.configure()
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
        tokensView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    // MARK: - App events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
        navigationController?.setNavigationBarHidden(false, animated: animated)
        applyLargeTitleIfNeeded()
        startSafeAreaKeyboardAdjustment()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tryFulfillPendingSearchFocus()
        consumePendingTokensQuickActions()
    }

    override func willTransition(
        to newCollection: UITraitCollection,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.willTransition(to: newCollection, with: coordinator)
        applyLargeTitleIfNeeded(sizeClass: newCollection.horizontalSizeClass)
    }

    private func applyLargeTitleIfNeeded(sizeClass: UIUserInterfaceSizeClass? = nil) {
        guard #available(iOS 26.0, *) else { return }
        let horizontal = sizeClass ?? traitCollection.horizontalSizeClass
        let isCompact = horizontal == .compact
        navigationController?.navigationBar.prefersLargeTitles = isCompact
        navigationItem.largeTitleDisplayMode = isCompact ? .always : .never
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
        view.backgroundColor = AppColor.backgroundsPrimary.uiColor
        title = T.Commons.tokens
        accessibilityTraits = .header
    }
    
    func setupDelegates() {
        searchController.searchBarDelegate = self
        tokensView.delegate = self
    }
    
    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: tokensView,
            cellProvider: { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
                self?.getCell(for: collectionView, indexPath: indexPath, item: item)
            })
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath
            -> UICollectionReusableView? in
            self?.getHeader(for: collectionView, kind: kind, indexPath: indexPath)
        }
    }
    
    func setupDragAndDrop() {
        tokensView.dragDelegate = self
        tokensView.dropDelegate = self
        tokensView.dragInteractionEnabled = presenter.enableDragAndDropOnStart
    }
    
    func setupEmptyScreensLayout() {
        view.addSubview(emptySearchScreenView, with: [
            emptySearchScreenView.leadingAnchor.constraint(equalTo: tokensView.frameLayoutGuide.leadingAnchor),
            emptySearchScreenView.trailingAnchor.constraint(equalTo: tokensView.frameLayoutGuide.trailingAnchor),
            emptySearchScreenView.topAnchor.constraint(equalTo: tokensView.frameLayoutGuide.topAnchor),
            emptySearchScreenView.bottomAnchor.constraint(equalTo: tokensView.frameLayoutGuide.bottomAnchor)
        ])
        emptySearchScreenView.isHidden = true
        emptySearchScreenView.alpha = 0
        
        addChild(emptyListHostingController)
        emptyListScreenView.backgroundColor = AppColor.backgroundsPrimary.uiColor
        view.addSubview(emptyListScreenView, with: [
            emptyListScreenView.leadingAnchor.constraint(equalTo: tokensView.frameLayoutGuide.leadingAnchor),
            emptyListScreenView.trailingAnchor.constraint(equalTo: tokensView.frameLayoutGuide.trailingAnchor),
            emptyListScreenView.topAnchor.constraint(equalTo: tokensView.safeTopAnchor),
            emptyListScreenView.bottomAnchor.constraint(equalTo: tokensView.safeBottomAnchor)
        ])
        emptyListHostingController.didMove(toParent: self)
        emptyListScreenView.isHidden = true
        emptyListScreenView.alpha = 0
    }
    
    private func createLayout() {
        layout = UICollectionViewCompositionalLayout { [weak self] sectionOffset, enviroment in
            self?.getLayout(sectionOffset: sectionOffset, enviroment: enviroment)
        }
    }
    
    func setupEmptyScreensEvents() {
        emptyListModel.pairNewService = { [weak self] in self?.presenter.handleAddService() }
        emptyListModel.importFromExternalService = { [weak self] in
            AppEventLog(.onboardingBackupFile)
            self?.presenter.handleImportExternalFile()
        }
        emptyListModel.help = { [weak self] in self?.presenter.handleShowHelp() }
        emptyListModel.goToTrashAction = { [weak self] in self?.presenter.goToTrash() }
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
            selector: #selector(vaultWasMigrated),
            name: .vaultWasMigrated,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(activeSearchShouldFocus),
            name: .activeSearchShouldFocus,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(userLoggedIn),
            name: .userLoggedIn,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(quickActionTokensRequested),
            name: .quickActionTokensRequested,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(allServicesRemovedAlertShouldBeShown),
            name: .allServicesRemovedAlertShouldBeShown,
            object: nil
        )
    }
}
