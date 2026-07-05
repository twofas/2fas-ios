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

protocol TokensViewControlling: AnyObject {
    func reloadData(newSnapshot: NSDiffableDataSourceSnapshot<TokensSection, TokenCell>, scrollTo: IndexPath?)
        
    func showList()
    func showEmptyScreen()
    func showSearchEmptyScreen()
    
    func enableDragging()
    func disableDragging()
    
    func updateNaviIcons(using state: TokensViewControllerAddState, hasUnreadNews: Bool)
    func updateEditState(using state: TokensViewControllerEditState)
    
    func lockBars()
    func unlockBars()
    
    func addSearchBar()
    func removeSearchBar()
    func stopSearch()
    
    func enableBounce()
    func disableBounce()
    
    func showKeyboard()
    
    func copyToken()
    func copyNextToken()
}

extension TokensViewController: TokensViewControlling {
    // MARK: - Data managment
    func reloadData(newSnapshot: NSDiffableDataSourceSnapshot<TokensSection, TokenCell>, scrollTo: IndexPath?) {
        if tokensView.hasActiveDrag || tokensView.hasActiveDrop {
            tokensView.cancelInteractiveMovement()
        }
        dataSource.apply(newSnapshot, animatingDifferences: !tokensView.hasActiveDrag, completion: nil)
        // no need to call reload other than seconds/consumer update
        tokensView.reloadData()
        
        if let scrollTo,
            tokensView.numberOfSections > scrollTo.section &&
            tokensView.numberOfItems(inSection: scrollTo.section) > scrollTo.row {
            tokensView.scrollToItem(at: scrollTo, at: .top, animated: true)
        }
    }
    
    // MARK: - Empty screen or list
    func showList() {
        if presenter.showSearchBar {
            addSearchBar()
            tokensView.alwaysBounceVertical = true
        } else {
            tokensView.alwaysBounceVertical = false
        }
        UIView.animate(
            withDuration: Theme.Animations.Timing.show,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                self.emptyListScreenView.alpha = 0
                self.emptySearchScreenView.alpha = 0
            },
            completion: { _ in
                self.emptyListScreenView.isHidden = true
                self.emptySearchScreenView.isHidden = true
            }
        )
    }
    
    func showEmptyScreen() {
        removeSearchBar()
        VoiceOver.say(T.Voiceover.useAddServiceButtonTitle)
        emptyListScreenView.setItemsInTrashCount(presenter.trashedServicesCount)
        guard emptyListScreenView.isHidden else { return }
        emptyListScreenView.alpha = 0
        emptyListScreenView.isHidden = false
        UIView.animate(withDuration: Theme.Animations.Timing.show, animations: {
            self.emptyListScreenView.alpha = 1
        })
    }
    
    func showSearchEmptyScreen() {
        VoiceOver.say(T.Voiceover.noSearchResults)
        emptySearchScreenView.alpha = 0
        emptySearchScreenView.isHidden = false
        UIView.animate(
            withDuration: Theme.Animations.Timing.show,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut]
        ) {
            self.emptySearchScreenView.alpha = 1
        }
    }
    
    func showKeyboard() {
        guard !searchController.searchBar.isFirstResponder && searchBarAdded else { return }
        searchController.searchBar.becomeFirstResponder()
    }
    
    // MARK: - Dragging
    func enableDragging() {
        tokensView.dragInteractionEnabled = true
    }
    
    func disableDragging() {
        tokensView.dragInteractionEnabled = false
    }

    // MARK: - Navibar icons
    func updateNaviIcons(using state: TokensViewControllerAddState, hasUnreadNews: Bool) {
        func createNewsButton() -> UIBarButtonItem {
            if hasUnreadNews {
                let naviButton = UnreadNewsNaviButton()
                naviButton.translatesAutoresizingMaskIntoConstraints = false
                naviButton.accessibilityLabel = T.Commons.notifications
                naviButton.addTarget(self, action: #selector(showNotifications), for: .touchUpInside)
                naviButton.animate()
                let uiBarButtonItem = UIBarButtonItem(customView: naviButton)
                newsButton = .unread(uiBarButtonItem)
                return uiBarButtonItem
            } else {
                let uiBarButtonItem: UIBarButtonItem
                if #available(iOS 26.0, *) {
                    uiBarButtonItem = UIBarButtonItem(
                        image: Asset.navibarNewsIcon.image,
                        style: .plain,
                        target: self,
                        action: #selector(showNotifications)
                    )
                } else {
                    let naviButton = UIButton(type: .custom)
                    naviButton.setBackgroundImage(Asset.navibarNewsIcon.image, for: .normal)
                    naviButton.addTarget(self, action: #selector(showNotifications), for: .touchUpInside)
                    naviButton.translatesAutoresizingMaskIntoConstraints = false
                    uiBarButtonItem = UIBarButtonItem(customView: naviButton)
                }
                uiBarButtonItem.accessibilityLabel = T.Commons.notifications
                newsButton = .read(uiBarButtonItem)
                return uiBarButtonItem
            }
        }

        func resolvedNewsButton() -> UIBarButtonItem {
            switch (hasUnreadNews, newsButton) {
            case (true, .unread(let b)): return b
            case (false, .read(let b)): return b
            default: return createNewsButton()
            }
        }

        switch state {
        case .firstTime:
            navigationItem.rightBarButtonItems = [resolvedNewsButton()]
        case .normal:
            navigationItem.rightBarButtonItems = [makeMoreMenuButton(), resolvedNewsButton()]
        case .none:
            let buttonSection = UIBarButtonItem(
                image: Asset.addCategory.image,
                style: .plain,
                target: self,
                action: #selector(addSectionAction)
            )
            buttonSection.accessibilityLabel = T.Voiceover.addGroup
            navigationItem.rightBarButtonItems = [buttonSection]
        }
    }

    private func makeMoreMenuButton() -> UIBarButtonItem {
        let editAction = UIAction(
            title: T.Commons.edit,
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in
            self?.presenter.handleEnterEditMode()
        }

        let deferredSortChildren = UIDeferredMenuElement.uncached { [weak self] completion in
            guard let self else {
                completion([])
                return
            }
            let selected = self.presenter.selectedSortType
            let actions: [UIAction] = SortType.allCases.map { sortType in
                UIAction(
                    title: sortType.localized,
                    image: UIImage(systemName: self.sortSystemImageName(for: sortType)),
                    state: sortType == selected ? .on : .off
                ) { [weak self] _ in
                    self?.presenter.handleSetSortType(sortType)
                }
            }
            completion(actions)
        }
        let sortMenu = UIMenu(
            title: T.Tokens.sortBy,
            image: Asset.naviSortIcon.image,
            children: [deferredSortChildren]
        )

        let menu = UIMenu(children: [editAction, sortMenu])
        let button = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: menu)
        button.accessibilityLabel = T.Commons.optionsTitle
        return button
    }

    private func sortSystemImageName(for sortType: SortType) -> String {
        switch sortType {
        case .az: return "arrow.down"
        case .za: return "arrow.up"
        case .manual: return "line.3.horizontal"
        }
    }
    
    func updateEditState(using state: TokensViewControllerEditState) {
        let button: UIBarButtonItem?

        switch state {
        case .edit:
            button = nil
            tokensView.isEditing = false
        case .cancel:
            button = UIBarButtonItem(
                title: T.Commons.done,
                style: .plain,
                target: self,
                action: #selector(leaveEditMode)
            )
            tokensView.isEditing = true
        case .none:
            button = nil
            tokensView.isEditing = false
        }

        navigationItem.leftBarButtonItem = button
    }
    
    func gridCell(for indexPath: IndexPath) -> TokenCell? {
        let snapshot = dataSource.snapshot()
        guard
            let section = snapshot.sectionIdentifiers[safe: indexPath.section],
            let cell = snapshot.itemIdentifiers(inSection: section)[safe: indexPath.row]
        else { return nil }
        return cell
    }
    
    @objc
    func showNotifications() {
        presenter.handleShowNotifications()
    }
    
    // MARK: - Bars
    
    func lockBars() {
        tabBarController?.tabBar.isUserInteractionEnabled = false
        navigationController?.navigationBar.isUserInteractionEnabled = false
    }
    
    func unlockBars() {
        tabBarController?.tabBar.isUserInteractionEnabled = true
        navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    // MARK: - Search Bars
    
    func addSearchBar() {
        guard !searchBarAdded else { return }
        searchBarAdded = true
        if #available(iOS 26.0, *) {
            navigationItem.preferredSearchBarPlacement = .stacked
        }
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func removeSearchBar() {
        guard searchBarAdded else { return }
        searchBarAdded = false
        navigationItem.searchController?.isActive = false
        navigationItem.searchController = nil
        if #available(iOS 26.0, *), traitCollection.horizontalSizeClass == .compact {
            navigationItem.largeTitleDisplayMode = .always
        } else {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    func stopSearch() {
        searchController.isActive = false
    }
    
    // MARK: - Bounce
    
    func enableBounce() {
        tokensView.alwaysBounceVertical = true
    }
    
    func disableBounce() {
        tokensView.alwaysBounceVertical = false
    }

    // MARK: - Notifications
    
    func copyToken() {
        VoiceOver.say(T.Notifications.tokenCopied)
        HUDNotification.presentSuccess(title: T.Notifications.tokenCopied)
    }
    
    func copyNextToken() {
        VoiceOver.say(T.Notifications.nextTokenCopied)
        HUDNotification.presentSuccess(title: T.Notifications.nextTokenCopied)
    }
}

private extension TokensViewController {
    @objc
    func addSectionAction() {
        presenter.handleShowSectionCreation()
    }
    
    @objc
    func showSortSelection() {
        presenter.handleShowSortSelection()
    }
    
    @objc
    func addServiceAction() {
        presenter.handleAddService()
    }
    
    @objc
    func enterEditMode() {
        presenter.handleEnterEditMode()
    }
    
    @objc
    func leaveEditMode() {
        presenter.handleLeaveEditMode()
    }
}

extension TokensViewController {
    @objc(notificationServicesWereUpdated:)
    func notificationServicesWereUpdated(notification: Notification) {
        let modified = notification.userInfo?[Notification.UserInfoKey.modified] as? [String]
        let deleted = notification.userInfo?[Notification.UserInfoKey.deleted] as? [String]
        presenter.handleServicesWereUpdated(modified: modified, deleted: deleted)
    }
    
    @objc
    func notificationSectionsWereUpdated() {
        presenter.handleSectionsUpdated()
    }
    
    @objc
    func vaultWasMigrated() {
        presenter.vaultWasMigrated()
    }
    
    @objc
    func notificationAppDidBecomeActive() {
        presenter.handleAppDidBecomeActive()
    }
    
    @objc
    func notificationAppDidBecomeInactive() {
        presenter.handleAppBecomesInactive()
    }
    
    @objc
    func tokensScreenIsVisible() {
        guard viewIfLoaded?.window != nil else { return }
        var modalPresent = false
        var vc: UIViewController? = self
        repeat {
            if vc?.presentedViewController != nil {
                modalPresent = true
                break
            }
            vc = vc?.parent
        } while vc != nil
        
        guard !modalPresent else { return }
        presenter.handleTokensScreenIsVisible()
    }
    
    @objc
    func userLoggedIn() {
        presenter.handleAppUnlocked()
    }

    @objc
    func allServicesRemovedAlertShouldBeShown() {
        presenter.handleAllServicesRemovedAlert()
    }
}

private extension TokensViewController {
    final class UnreadNewsNaviButton: UIButton {
        let newsImageView = UIImageView(image: Asset.navibarNewsIcon.image)
        let badgeImageView = UIImageView(image: Asset.badge.image)

        private let badgeWidth: CGFloat = 3

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupViews()
        }

        private func setupViews() {
            newsImageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(newsImageView)

            badgeImageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(badgeImageView)
            badgeImageView.isHidden = true

            NSLayoutConstraint.activate([
                newsImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                newsImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                badgeImageView.topAnchor.constraint(equalTo: topAnchor, constant: Spacing.SM.rawValue),
                badgeImageView.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: -Spacing.XS.rawValue
                ),
                badgeImageView.widthAnchor.constraint(equalToConstant: badgeWidth),
                badgeImageView.heightAnchor.constraint(equalToConstant: badgeWidth)
            ])
        }

        func animate() {
            let angle: Double = .pi / 12
            let numberOfFrames: Double = 5
            let frameDuration = Double(0.7 / numberOfFrames)

            UIView.animateKeyframes(
                withDuration: 1,
                delay: 0,
                animations: { [newsImageView] in
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: frameDuration) {
                        newsImageView.transform = CGAffineTransform(rotationAngle: -angle)
                    }
                    UIView.addKeyframe(withRelativeStartTime: frameDuration, relativeDuration: frameDuration) {
                        newsImageView.transform = CGAffineTransform(rotationAngle: +angle)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 2 * frameDuration, relativeDuration: frameDuration) {
                        newsImageView.transform = CGAffineTransform(rotationAngle: -angle)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 3 * frameDuration, relativeDuration: frameDuration) {
                        newsImageView.transform = CGAffineTransform(rotationAngle: +angle)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 4 * frameDuration, relativeDuration: frameDuration) {
                        newsImageView.transform = CGAffineTransform.identity
                    }
                }, 
                completion: { [weak self] _ in
                    self?.badgeImageView.isHidden = false
                    self?.animateBadge()
                }
            )
        }

        private func animateBadge() {
            UIView.animate(
                withDuration: 0.2,
                animations: { [badgeImageView, badgeWidth] in
                    badgeImageView.transform = CGAffineTransform(scaleX: 12.0 / badgeWidth, y: 12.0 / badgeWidth)
                }, completion: { [badgeImageView, badgeWidth] _ in
                    UIView.animate(withDuration: 0.15) {
                        badgeImageView.transform = CGAffineTransform(scaleX: 8.0 / badgeWidth, y: 8.0 / badgeWidth)
                    }
                }
            )
        }
    }
}
