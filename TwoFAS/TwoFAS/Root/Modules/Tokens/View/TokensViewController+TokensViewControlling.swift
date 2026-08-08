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
                let naviButton: UIButton
                if #available(iOS 26.0, *) {
                    let button = UnreadNewsNaviButton()
                    button.animate()
                    naviButton = button
                } else {
                    let button = LegacyUnreadNewsNaviButton()
                    button.animate()
                    naviButton = button
                }
                naviButton.translatesAutoresizingMaskIntoConstraints = false
                naviButton.accessibilityLabel = T.Commons.notifications
                naviButton.addTarget(self, action: #selector(showNotifications), for: .touchUpInside)
                let uiBarButtonItem = UIBarButtonItem(customView: naviButton)
                if #available(iOS 26.0, *) {
                    uiBarButtonItem.hidesSharedBackground = true
                }
                newsButton = .unread(uiBarButtonItem)
                return uiBarButtonItem
            } else {
                let uiBarButtonItem: UIBarButtonItem
                if #available(iOS 26.0, *) {
                    let cfg = UIImage.SymbolConfiguration(
                        pointSize: UnreadNewsNaviButton.iconReadPointSize,
                        weight: UnreadNewsNaviButton.iconWeight
                    )
                    let icon = UIImage(systemName: UnreadNewsNaviButton.iconSymbolName, withConfiguration: cfg)
                    uiBarButtonItem = UIBarButtonItem(
                        image: icon,
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
            if #available(iOS 26.0, *) {
                navigationItem.rightBarButtonItems = [resolvedNewsButton()]
            } else {
                navigationItem.rightBarButtonItems = [makeAddServiceButton(), resolvedNewsButton()]
            }
        case .normal:
            if #available(iOS 26.0, *) {
                // fixedSpace(0) splits the shared glass background so the two buttons always
                // render as separate glass capsules, regardless of the unread badge state.
                navigationItem.rightBarButtonItems = [makeMoreMenuButton(), .fixedSpace(0), resolvedNewsButton()]
            } else {
                navigationItem.rightBarButtonItems = [makeMoreMenuButton(), resolvedNewsButton()]
            }
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

        var children: [UIMenuElement] = [editAction, sortMenu]
        if #unavailable(iOS 26.0) {
            let addServiceAction = UIAction(
                title: T.Tokens.addServiceTitle,
                image: UIImage(systemName: "plus")
            ) { [weak self] _ in
                self?.presenter.handleAddService()
            }
            children.insert(addServiceAction, at: 0)
        }

        let menu = UIMenu(children: children)
        let button = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: menu)
        button.accessibilityLabel = T.Commons.optionsTitle
        return button
    }

    private func makeAddServiceButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(
            image: Asset.naviIconAddFirst.image,
            style: .plain,
            target: self,
            action: #selector(addServiceAction)
        )
        button.accessibilityLabel = T.Voiceover.addService
        return button
    }

    private func sortSystemImageName(for sortType: SortType) -> String {
        switch sortType {
        case .az: "arrow.down"
        case .za: "arrow.up"
        case .manual: "line.3.horizontal"
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
        navigationItem.hidesSearchBarWhenScrolling = true
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
        ToastPresenter.shared.presentTokenCopied()
    }
    
    func copyNextToken() {
        VoiceOver.say(T.Notifications.nextTokenCopied)
        ToastPresenter.shared.presentNextTokenCopied()
    }
}

private extension TokensViewController {
    @objc
    func addSectionAction() {
        presenter.handleShowSectionCreation()
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
    @available(iOS 26.0, *)
    final class UnreadNewsNaviButton: UIButton {
        // MARK: - Configuration
        static let iconSymbolName = "bell.fill"
        static let iconPointSize: CGFloat = 20
        static let iconReadPointSize: CGFloat = 16
        static let iconWeight: UIImage.SymbolWeight = .regular

        static let badgeSize: CGFloat = 8
        static let badgeBorderWidth: CGFloat = 1
        static var badgeFillColor: UIColor { AppColor.accentsBrand.uiColor }
        static var badgeBorderColor: UIColor { AppColor.backgroundsPrimary.uiColor }

        // Badge position measured inward from the top-trailing corner of the button.
        static let badgeCornerInset: CGFloat = 12

        // Diameter of the circular glass background. Kept square so the capsule renders as a
        // circle matching the adjacent standard bar button items (e.g. the "more" button).
        static let glassDiameter: CGFloat = 44

        static let badgePopScale: CGFloat = 2.0
        static let badgeSettleScale: CGFloat = 1.0

        let newsImageView = UIImageView()
        let badgeView = UIView()
        let glassEffectView: UIVisualEffectView = {
            let effect = UIGlassEffect()
            effect.isInteractive = true
            let view = UIVisualEffectView(effect: effect)
            view.cornerConfiguration = .capsule()
            return view
        }()

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupViews()
        }

        private func setupViews() {
            glassEffectView.translatesAutoresizingMaskIntoConstraints = false
            glassEffectView.isUserInteractionEnabled = false
            addSubview(glassEffectView)

            let cfg = UIImage.SymbolConfiguration(
                pointSize: Self.iconPointSize,
                weight: Self.iconWeight
            )
            newsImageView.image = UIImage(systemName: Self.iconSymbolName, withConfiguration: cfg)
            newsImageView.contentMode = .center
            newsImageView.translatesAutoresizingMaskIntoConstraints = false
            newsImageView.tintColor = AppColor.labelsPrimary.uiColor
            glassEffectView.contentView.addSubview(newsImageView)

            // The badge lives on top of the glass (not inside its content view) so it keeps its
            // full brand color and isn't clipped by the capsule shape.
            badgeView.backgroundColor = Self.badgeFillColor
            badgeView.layer.borderWidth = Self.badgeBorderWidth
            badgeView.layer.borderColor = Self.badgeBorderColor.cgColor
            badgeView.layer.cornerRadius = Self.badgeSize / 2
            badgeView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(badgeView)
            badgeView.isHidden = true

            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
                self.badgeView.layer.borderColor = Self.badgeBorderColor.cgColor
            }

            let content = glassEffectView.contentView
            NSLayoutConstraint.activate([
                glassEffectView.topAnchor.constraint(equalTo: topAnchor),
                glassEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
                glassEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
                glassEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
                glassEffectView.widthAnchor.constraint(equalToConstant: Self.glassDiameter),
                glassEffectView.heightAnchor.constraint(equalToConstant: Self.glassDiameter),

                newsImageView.centerXAnchor.constraint(equalTo: content.centerXAnchor),
                newsImageView.centerYAnchor.constraint(equalTo: content.centerYAnchor),

                badgeView.centerXAnchor.constraint(equalTo: trailingAnchor, constant: -Self.badgeCornerInset),
                badgeView.centerYAnchor.constraint(equalTo: topAnchor, constant: Self.badgeCornerInset),
                badgeView.widthAnchor.constraint(equalToConstant: Self.badgeSize),
                badgeView.heightAnchor.constraint(equalToConstant: Self.badgeSize)
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
                    self?.badgeView.isHidden = false
                    self?.animateBadge()
                }
            )
        }

        private func animateBadge() {
            let popScale = Self.badgePopScale
            let settleScale = Self.badgeSettleScale
            UIView.animate(
                withDuration: 0.2,
                animations: { [badgeView] in
                    badgeView.transform = CGAffineTransform(scaleX: popScale, y: popScale)
                }, completion: { [badgeView] _ in
                    UIView.animate(withDuration: 0.15) {
                        badgeView.transform = CGAffineTransform(scaleX: settleScale, y: settleScale)
                    }
                }
            )
        }
    }

    final class LegacyUnreadNewsNaviButton: UIButton {
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
