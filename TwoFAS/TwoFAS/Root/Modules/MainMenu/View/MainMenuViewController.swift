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
    //func select
}

final class MainMenuViewController: UIViewController {
    var presenter: MainMenuPresenter!
    
    private var collectionView: UICollectionView!
    private var collectionViewDataSource: UICollectionViewDiffableDataSource<MainMenuSection, MainMenuCell>!

    private var listLayout: UICollectionViewLayout = {
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            configuration.showsSeparators = false
            configuration.headerMode = .firstItemInSection
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            return section
        }
    }()
    
    private let contentCellRegistration = UICollectionView
        .CellRegistration<UICollectionViewListCell, MainMenuCell> { cell, indexPath, item in
        
        var contentConfiguration = UIListContentConfiguration.sidebarHeader()
        contentConfiguration.text = item.title
        contentConfiguration.textProperties.color = .label
        contentConfiguration.image = item.icon
        
        cell.contentConfiguration = contentConfiguration
            
        cell.accessories = [.outlineDisclosure()]
    }
    
    private let subContentCellRegistration = UICollectionView
        .CellRegistration<UICollectionViewListCell, MainMenuCell> { cell, indexPath, item in
        
        var contentConfiguration = UIListContentConfiguration.sidebarCell()
        contentConfiguration.text = item.title
        contentConfiguration.textProperties.color = .label
        
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

//        collectionViewAdapter.delegatee.didSelectItemAt = { [weak self] _, indexPath in
////            self?.presenter.handleSelection(at: indexPath)
//        }

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
        if let icon = item.icon {
            return
            collectionView.dequeueConfiguredReusableCell(using: contentCellRegistration, for: indexPath, item: item)
        } else {
            return
            collectionView.dequeueConfiguredReusableCell(using: subContentCellRegistration, for: indexPath, item: item)
        }
        
//        switch item.type {
//        case .header:
//            return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
//        case .expandableRow:
//            return collectionView.dequeueConfiguredReusableCell(using: expandableRowRegistration, for: indexPath, item: item)
//        default:
//            return collectionView.dequeueConfiguredReusableCell(using: rowRegistration, for: indexPath, item: item)
//        }
        
//        guard let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: IconSelectorCollectionViewCell.reuseIdentifier,
//            for: indexPath
//        ) as? IconSelectorCollectionViewCell
//        else { return nil }
//
//        cell.setIcon(data.icon, serviceName: data.title, showTitle: data.showTitle)
//        return cell
    }
}

extension MainMenuViewController: MainMenuViewControlling {
    func reload(with data: [MainMenuSection]) {
        data.forEach { section in
            var snapshot = NSDiffableDataSourceSectionSnapshot<MainMenuCell>()
            guard let first = section.cells.first else { return }
            snapshot.append([first])
            if section.cells.count > 1 {
                let rest = Array(section.cells[1...])
                snapshot.append(rest, to: first)
            }
            collectionViewDataSource.apply(snapshot, to: section, animatingDifferences: false)
         }
    }
    
    func select() {
        
    }
}

// dodać refresh dla sekcji!
// dodać refresh dla zaznaczenia!

extension MainMenuViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.handleSelection(at: indexPath)
    }
}
