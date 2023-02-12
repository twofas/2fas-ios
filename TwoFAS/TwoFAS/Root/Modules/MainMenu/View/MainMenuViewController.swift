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

protocol MainMenuViewControlling: AnyObject {
    func reload(with data: [MainMenuSection])
}

final class MainMenuViewController: UIViewController {
    var presenter: MainMenuPresenter!
    
    private var collectionView: UICollectionView!
    private var collectionViewDataSource: UICollectionViewDiffableDataSource<MainMenuSection, MainMenuCell>!
    
    private var listLayout: UICollectionViewLayout = {
        UICollectionViewCompositionalLayout { _, layoutEnvironment -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            configuration.showsSeparators = false
            configuration.headerMode = .none
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            return section
        }
    }()
    
    private let contentCellRegistration = UICollectionView
        .CellRegistration<UICollectionViewListCell, MainMenuCell> { cell, _, item in
            var contentConfiguration = UIListContentConfiguration.sidebarHeader()
            contentConfiguration.text = item.title
            contentConfiguration.textProperties.color = .label
            contentConfiguration.image = item.icon
            cell.contentConfiguration = contentConfiguration
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Theme.Colors.Table.background
        navigationItem.backButtonDisplayMode = .minimal
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
        collectionView.backgroundColor = Theme.Colors.Fill.System.first
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        
        collectionViewDataSource = UICollectionViewDiffableDataSource<MainMenuSection, MainMenuCell>(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
                self?.cell(for: itemIdentifier, in: collectionView, at: indexPath) ?? UICollectionViewCell()
            })
        
        collectionView.tintColor = Theme.Colors.Fill.theme
        
        view.addSubview(collectionView)
        collectionView.pinToParent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewWillAppear()
    }
    
    func handleChangeViewPath(_ viewPath: ViewPath) {
        presenter.handleChangeViewPath(viewPath)
    }
}

extension MainMenuViewController {
    func cell(
        for item: MainMenuCell,
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> UICollectionViewCell? {
        // TODO: Add seperate section with section shortcuts
        collectionView.dequeueConfiguredReusableCell(using: contentCellRegistration, for: indexPath, item: item)
    }
}

extension MainMenuViewController: MainMenuViewControlling {
    func reload(with data: [MainMenuSection]) {
        data.forEach { section in
            var snapshot = NSDiffableDataSourceSectionSnapshot<MainMenuCell>()
            snapshot.append(section.cells)
            collectionViewDataSource.apply(snapshot, to: section, animatingDifferences: false)
        }
    }
}

// dodać refresh dla zaznaczenia! chyba, że automatycznie?

extension MainMenuViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.handleSelection(at: indexPath)
    }
}
