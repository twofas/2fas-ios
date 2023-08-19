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

protocol MainMenuViewControlling: AnyObject {
    func reload(with data: [MainMenuSection])
    func selectPosition(at indexPath: IndexPath)
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
            configuration.headerTopPadding = Theme.Metrics.standardMargin
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            return section
        }
    }()
    
    private let contentCellRegistration = UICollectionView
        .CellRegistration<MenuCell, MainMenuCell> { cell, _, item in
            let badgeSymbol = "●"
            
            var contentConfiguration = UIListContentConfiguration.sidebarCell()
            
            cell.normalImage = item.icon
            cell.selectedImage = item.selectedIcon
            
            contentConfiguration.image = item.icon
            contentConfiguration.textProperties.font = contentConfiguration
                .textProperties.font.withTraits(traits: .traitBold)
            contentConfiguration.imageProperties.reservedLayoutSize = .init(width: 24, height: 24)
            contentConfiguration.textProperties.color = Theme.Colors.Text.main
            
            if item.hasBadge {
                let attributedString = NSMutableAttributedString(string: "\(item.title)\(badgeSymbol)")
                attributedString.decorate(
                    textToDecorate: badgeSymbol,
                    attributes: [
                        .foregroundColor: Theme.Colors.Fill.theme,
                        .baselineOffset: 10,
                        .font: UIFont.systemFont(ofSize: 10, weight: .bold)
                    ]
                )
                contentConfiguration.attributedText = attributedString
            } else {
                contentConfiguration.text = item.title
            }
                        
            cell.contentConfiguration = contentConfiguration
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = T.Commons._2fasToolbar
        view.backgroundColor = Theme.Colors.Fill.System.second
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.largeTitleDisplayMode = .always
        
        setupCollectionView()
        presenter.viewDidLoad()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = false
        
        collectionViewDataSource = UICollectionViewDiffableDataSource<MainMenuSection, MainMenuCell>(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
                self?.cell(for: itemIdentifier, in: collectionView, at: indexPath) ?? UICollectionViewCell()
            })
        
        collectionView.tintColor = Theme.Colors.Fill.theme
        view.tintColor = Theme.Colors.Fill.theme
        
        view.addSubview(collectionView)
        collectionView.pinToParent()
    }
}

extension MainMenuViewController {
    func cell(
        for item: MainMenuCell,
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> UICollectionViewCell? {
        collectionView.dequeueConfiguredReusableCell(using: contentCellRegistration, for: indexPath, item: item)
    }
}

extension MainMenuViewController: MainMenuViewControlling {
    func reload(with data: [MainMenuSection]) {
        var snapshot = NSDiffableDataSourceSnapshot<MainMenuSection, MainMenuCell>()
        data.forEach { section in
            snapshot.appendSections([section])
            snapshot.appendItems(section.cells, toSection: section)
        }

        collectionViewDataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func selectPosition(at indexPath: IndexPath) {
        guard self.collectionView.indexPathsForSelectedItems?.first != indexPath else { return }
        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
    }
}

extension MainMenuViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.handleSelection(at: indexPath)
    }
}

private final class MenuCell: UICollectionViewListCell {
    weak var normalImage: UIImage?
    weak var selectedImage: UIImage?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        guard
            var cConfig = self.contentConfiguration?.updated(for: state) as? UIListContentConfiguration
        else { return }
        
        if state.isSelected, let selectedImage {
            cConfig.image = selectedImage
        } else if let normalImage {
            cConfig.image = normalImage
        }
        
        cConfig.textProperties.colorTransformer = UIConfigurationColorTransformer { _ in
            if state.isSelected {
                return Theme.Colors.Text.light
            } else if state.isHighlighted {
                return Theme.Colors.Text.mainHighlighted
            }
            return Theme.Colors.Text.main
        }
        
        cConfig.imageProperties.tintColorTransformer = UIConfigurationColorTransformer { _ in
            if state.isSelected {
                return Theme.Colors.Text.light
            } else if state.isHighlighted {
                return Theme.Colors.Text.mainHighlighted
            }
            return Theme.Colors.Controls.inactive
        }
        
        self.contentConfiguration = cConfig
        
        guard var bConfig = self.backgroundConfiguration?.updated(for: state) else { return }
        bConfig.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
            if state.isSelected {
                return Theme.Colors.Fill.theme
            } else if state.isHighlighted {
                return Theme.Colors.Fill.themeLight
            }
            return .clear
        }
        self.backgroundConfiguration = bConfig
    }
}
