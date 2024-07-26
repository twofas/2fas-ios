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

protocol TokensViewControlling: AnyObject {
    func reloadData(newSnapshot: NSDiffableDataSourceSnapshot<TokensSection, TokenCell>, scrollTo: IndexPath?)
        
    func showList()
    func showEmptyScreen()
    func showSearchEmptyScreen()
    
    func enableDragging()
    func disableDragging()
    
    func updateAddIcon(using state: TokensViewControllerAddState)
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

    class DualImageButton: UIButton {
        let imageView1 = UIImageView(image: Asset.navibarNewsIcon.image)
        let imageView2 = UIImageView(image: Asset.badge.image)

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupViews()
        }

        private func setupViews() {
            imageView1.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView1)

            imageView2.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView2)
            imageView2.isHidden = true

            // Constraints for imageView1 to be centered
            NSLayoutConstraint.activate([
                imageView1.centerXAnchor.constraint(equalTo: centerXAnchor),
                imageView1.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            
            NSLayoutConstraint.activate([
                imageView2.topAnchor.constraint(equalTo: topAnchor, constant: 4),
                imageView2.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
                imageView2.widthAnchor.constraint(equalToConstant: 3),
                imageView2.heightAnchor.constraint(equalToConstant: 3)
            ])
        }
    }


    private func animate(_ barButtonItem: UIBarButtonItem) {
        let angle: Double = .pi / 8
        let numberOfFrames: Double = 5
        let frameDuration = Double(1/numberOfFrames)

        let button = barButtonItem.customView as? DualImageButton

        UIView.animateKeyframes(withDuration: 1, delay: 0, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: frameDuration) {
                button?.imageView1.transform = CGAffineTransform(rotationAngle: -angle)
            }

            UIView.addKeyframe(withRelativeStartTime: frameDuration, relativeDuration: frameDuration) {
                button?.imageView1.transform = CGAffineTransform(rotationAngle: +angle)
            }

            UIView.addKeyframe(withRelativeStartTime: 2*frameDuration, relativeDuration: frameDuration) {
                button?.imageView1.transform = CGAffineTransform(rotationAngle: -angle)
            }

            UIView.addKeyframe(withRelativeStartTime: 3*frameDuration, relativeDuration: frameDuration) {
                button?.imageView1.transform = CGAffineTransform(rotationAngle: +angle)
            }

            UIView.addKeyframe(withRelativeStartTime: 4*frameDuration, relativeDuration: frameDuration) {
                button?.imageView1.transform = CGAffineTransform.identity
            }
        }, completion: { _ in
            button?.imageView2.isHidden = false
            UIView.animate(withDuration: 0.4,
                             animations: {
                                button?.imageView2.transform = CGAffineTransform(scaleX: 12.0/3.0, y: 12.0/3.0)
                             },
                             completion: { _ in
                                 UIView.animate(withDuration: 0.2,
                                                animations: {
                                     button?.imageView2.transform = CGAffineTransform(scaleX: 8.0/3.0, y: 8.0/3.0)
                                                })
                             })
        })
    }

    // MARK: - Navibar icons
    func updateAddIcon(using state: TokensViewControllerAddState) {
        func createNewsIcon() -> UIBarButtonItem {
//            let img: UIImage = {
//                presenter.hasUnreadNews ? Asset.navibarNewsIconBadge.image : Asset.navibarNewsIcon.image
//            }()
            
            let naviButton = DualImageButton()
//            naviButton.translatesAutoresizingMaskIntoConstraints = false
//            naviButton.setBackgroundImage(img, for: .normal)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showNotifications))

//            naviButton.target(forAction: #selector(showNotifications), withSender: self)
//            naviButton.accessibilityLabel = T.Commons.notifications

            let uiBarButtonItem = UIBarButtonItem(customView: naviButton)
            uiBarButtonItem.customView?.addGestureRecognizer(tapGestureRecognizer)
            if !presenter.hasUnreadNews {
                animate(uiBarButtonItem)
            }

            return uiBarButtonItem
        }
        
        func createAddButton(image: UIImage) -> UIBarButtonItem {
            let buttonAdd = UIBarButtonItem(
                image: image,
                style: .plain,
                target: self,
                action: #selector(addServiceAction)
            )
            buttonAdd.accessibilityLabel = T.Voiceover.addService
            return buttonAdd
        }
            
        switch state {
        case .firstTime:
            navigationItem.rightBarButtonItems = [
                createAddButton(image: Asset.naviIconAddFirst.image),
                createNewsIcon()
            ]
        case .normal:
            navigationItem.rightBarButtonItems = [
                createAddButton(image: Asset.naviIconAdd.image),
                createNewsIcon()
            ]
        case .none:
            let buttonSection = UIBarButtonItem(
                image: Asset.addCategory.image,
                style: .plain,
                target: self,
                action: #selector(addSectionAction)
            )
            buttonSection.accessibilityLabel = T.Voiceover.addGroup
            let buttonSort = UIBarButtonItem(
                image: Asset.naviSortIcon.image,
                style: .plain,
                target: self,
                action: #selector(showSortSelection)
            )
            buttonSort.accessibilityLabel = T.Voiceover.sortByTitle
            navigationItem.rightBarButtonItems = [buttonSection, buttonSort]
        }
    }
    
    func updateEditState(using state: TokensViewControllerEditState) {
        let button: UIBarButtonItem?
        
        switch state {
        case .edit:
            button = UIBarButtonItem(
                title: T.Commons.edit,
                style: .plain,
                target: self,
                action: #selector(enterEditMode)
            )
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
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    func removeSearchBar() {
        guard searchBarAdded else { return }
        searchBarAdded = false
        navigationItem.searchController?.isActive = false
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.searchController = nil
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
}
