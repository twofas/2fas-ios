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

protocol IconSelectorViewControlling: AnyObject {
    func showEmptyScreen()
    func hideEmptyScreen()
    func selectItem(at indexPath: IndexPath, animated: Bool, scroll: Bool)
    func reload(with data: [IconSelectorSection])
}

final class IconSelectorViewController: UIViewController {
    var presenter: IconSelectorPresenter! {
        didSet {
            delegatee.presenter = presenter
        }
    }
    
    private(set) var collectionViewAdapter: CollectionViewAdapter<IconSelectorSection, IconSelectorCell>!
    private let delegatee = IconSelectorCollectionViewDelegatee<IconSelectorSection, IconSelectorCell>()
    private var gridLayout: UICollectionViewFlowLayout = {
        let horizontalMargin: CGFloat = Theme.Metrics.doubleMargin
        let spacing: CGFloat = Theme.Metrics.halfSpacing

        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(
            width: IconSelectorCollectionViewCell.dimension,
            height: IconSelectorCollectionViewCell.dimension
            + IconSelectorCollectionViewCell.labelHeight
            + Theme.Metrics.halfSpacing
        )
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.headerReferenceSize = CGSize(width: spacing, height: IconSelectorHeaderReusableView.dimension)
        layout.sectionHeadersPinToVisibleBounds = true
        layout.sectionInset = .init(top: spacing, left: horizontalMargin, bottom: spacing, right: horizontalMargin)
        return layout
    }()
    private var gridView: UICollectionView!

    private let searchController = CommonSearchController()
    private let emptyView = SearchResultEmptyView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Theme.Colors.Fill.System.third
        navigationController?.navigationBar.standardAppearance.backgroundColor = Theme.Colors.Fill.System.third
        
        gridView = UICollectionView(frame: .zero, collectionViewLayout: gridLayout)
        gridView.backgroundColor = Theme.Colors.Fill.System.first
        gridView.register(
            IconSelectorCollectionViewCell.self,
            forCellWithReuseIdentifier: IconSelectorCollectionViewCell.reuseIdentifier
        )
        gridView.register(
            IconSelectorOrderIconReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: IconSelectorOrderIconReusableView.reuseIdentifier
        )
        gridView.register(
            IconSelectorHeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: IconSelectorHeaderReusableView.reuseIdentifier
        )
        gridView.tintColor = Theme.Colors.Fill.theme
        gridView.keyboardDismissMode = .interactive

        collectionViewAdapter = CollectionViewAdapter<IconSelectorSection, IconSelectorCell>(
            collectionView: gridView,
            cellProvider: { [weak self] collectionView, indexPath, cellData -> UICollectionViewCell in
                self?.cell(for: cellData, in: collectionView, at: indexPath) ?? UICollectionViewCell()
            },
            delegatee: delegatee
        )
        delegatee.collectionViewAdapter = collectionViewAdapter

        collectionViewAdapter.indexPathForTitleProvider = { [weak self] _, _, offset in
            guard let self else { return .init(index: .zero) }
            return self.presenter.handleIndexPathForOffset(offset)
        }
        collectionViewAdapter.delegatee.didSelectItemAt = { [weak self] _, indexPath in
            self?.presenter.handleSelection(at: indexPath)
        }
        collectionViewAdapter.indexTitlesProvider = { [weak self] _ in self?.presenter.handleIndexTitles() }
        collectionViewAdapter.viewForSupplementaryElementOfKind = { [weak self] collectionView, kind, indexPath in
            self?.supplementaryView(for: kind, in: collectionView, at: indexPath) ?? UICollectionReusableView()
        }

        view.addSubview(gridView)
        gridView.pinToParent()

        title = T.Tokens.changeBrandIcon

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.backButtonDisplayMode = .minimal
        searchController.searchBarDelegate = self

        view.addSubview(emptyView)
        emptyView.pinToParent()
        emptyView.isHidden = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dismissKeyboard),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
        startSafeAreaKeyboardAdjustment()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSafeAreaKeyboardAdjustment()
    }
    
    @objc
    private func dismissKeyboard() {
        searchController.searchBar.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension IconSelectorViewController: CommonSearchDataSourceSearchable {
    func setSearchPhrase(_ phrase: String) {
        presenter.handleSearch(phrase)
    }
    
    func clearSearchPhrase() {
        presenter.handleSearchClearing()
    }
}

extension IconSelectorViewController: IconSelectorViewControlling {
    func showEmptyScreen() {
        emptyView.isHidden = false
        gridView.isHidden = true
    }
    
    func hideEmptyScreen() {
        emptyView.isHidden = true
        gridView.isHidden = false
    }
    
    func selectItem(at indexPath: IndexPath, animated: Bool, scroll: Bool) {
        DispatchQueue.main.async {
            self.gridView?.selectItem(
                at: indexPath,
                animated: animated,
                scrollPosition: scroll ? [.centeredHorizontally, .centeredVertically] : []
            )
        }
    }
    
    func reload(with data: [IconSelectorSection]) {
        let snapshot = CollectionViewDataSnapshot<IconSelectorSection, IconSelectorCell>()
        data.forEach { snapshot.appendSection($0) }

        collectionViewAdapter.apply(snapshot: snapshot)
    }
}
