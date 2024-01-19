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
import Data

final class TokensViewController: UIViewController {
    var presenter: TokensPresenter!
    var addButton: UIBarButtonItem? {
        navigationItem.rightBarButtonItem
    }
    private(set) var tokensView: TokensView!
    private(set) var dataSource: UICollectionViewDiffableDataSource<TokensSection, TokenCell>!
    
    let headerHeight: CGFloat = 44
    let emptySearchScreenView = TokensViewEmptySearchScreen()
    let emptyListScreenView = TokensViewEmptyListScreen()
    
    private var layout: UICollectionViewCompositionalLayout!
    
    var searchBarAdded = false
    
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
        
        view.addSubview(emptyListScreenView, with: [
            emptyListScreenView.leadingAnchor.constraint(equalTo: tokensView.frameLayoutGuide.leadingAnchor),
            emptyListScreenView.trailingAnchor.constraint(equalTo: tokensView.frameLayoutGuide.trailingAnchor),
            emptyListScreenView.topAnchor.constraint(equalTo: tokensView.safeTopAnchor),
            emptyListScreenView.bottomAnchor.constraint(equalTo: tokensView.safeBottomAnchor)
        ])
        emptyListScreenView.isHidden = true
        emptyListScreenView.alpha = 0
    }
    
    private func createLayout() {
        layout = UICollectionViewCompositionalLayout { [weak self] sectionOffset, enviroment in
            self?.getLayout(sectionOffset: sectionOffset, enviroment: enviroment)
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
        center.addObserver(
            self,
            selector: #selector(userLoggedIn),
            name: .userLoggedIn,
            object: nil
        )
    }
}
