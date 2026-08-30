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

    private(set) var tokensView: TokensView!
    private(set) var floatingHeader: TokensFloatingSectionHeader!
    /// Set while the search bar is being presented or dismissed.
    var isSearchTransitioning = false
    private(set) var dataSource: UICollectionViewDiffableDataSource<TokensSection, TokenCell>!
    
    let headerHeight: CGFloat = 44
    private static let searchTransitioningLayoutAnimationDuration: TimeInterval = 0.3
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
        tokensView.configure()
        // The list is wrapped so the floating header can sit above it, outside the scroll view.
        let container = UIView()
        tokensView.frame = container.bounds
        tokensView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(tokensView)
        view = container
        setContentScrollView(tokensView, for: .all)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupFloatingHeader()
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
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // The search bar's presentation moves the safe area in one step; animating the layout keeps
        // views pinned to it (the floating header) moving with the bar.
        if isSearchTransitioning {
            UIView.animate(withDuration: Self.searchTransitioningLayoutAnimationDuration) {
                self.view.layoutIfNeeded()
            }
        }
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
        searchController.delegate = self
        tokensView.delegate = self
        tokensView.didLayout = { [weak self] in self?.updateFloatingHeader() }
    }

    func setupFloatingHeader() {
        floatingHeader = TokensFloatingSectionHeader(scrollView: tokensView)
        floatingHeader.header.dataSource = self
        floatingHeader.isHidden = true
        view.addSubview(floatingHeader, with: [
            floatingHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            floatingHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            floatingHeader.header.topAnchor.constraint(equalTo: view.safeTopAnchor)
        ])
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
        // Both empty screens live inside the list, not in the root view: a hosted SwiftUI view
        // that receives real safe-area insets there relayouts endlessly once the keyboard is up.
        tokensView.addSubview(emptySearchScreenView, with: [
            emptySearchScreenView.leadingAnchor.constraint(equalTo: tokensView.frameLayoutGuide.leadingAnchor),
            emptySearchScreenView.trailingAnchor.constraint(equalTo: tokensView.frameLayoutGuide.trailingAnchor),
            emptySearchScreenView.topAnchor.constraint(equalTo: tokensView.frameLayoutGuide.topAnchor),
            emptySearchScreenView.bottomAnchor.constraint(equalTo: tokensView.frameLayoutGuide.bottomAnchor)
        ])
        emptySearchScreenView.isHidden = true
        emptySearchScreenView.alpha = 0
        
        addChild(emptyListHostingController)
        emptyListScreenView.backgroundColor = AppColor.backgroundsPrimary.uiColor
        tokensView.addSubview(emptyListScreenView, with: [
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
