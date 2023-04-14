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

import Foundation

final class MainSplitPresenter {
    weak var view: MainSplitViewControlling?
    
    private let flowController: MainSplitFlowControlling
    private let interactor: MainSplitModuleInteracting
        
    private enum Kind {
        case collapsed
        case expanded
        case unspecified
    }
    
    private var calledKind: Kind = .unspecified
    
    init(flowController: MainSplitFlowControlling, interactor: MainSplitModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension MainSplitPresenter {
    func viewDidLoad() {
        flowController.toInitialConfiguration()
    }
    
    func viewWillAppear() {
        handleRestoreNavigation()
        interactor.fetchNews { [weak self] in
            self?.updateNewsBadge()
        }
    }
    
    func didBecomeActive() {
        handleMainVisible()
    }
    
    func handleCollapse() {
        guard calledKind != Kind.collapsed else { return }
        calledKind = .collapsed
        flowController.toCompact()
        
        handleRestoreNavigation()
    }
    
    func handleExpansion() {
        guard calledKind != Kind.expanded else { return }
        calledKind = .expanded
        flowController.toExpanded()

        handleRestoreNavigation()
    }
    
    func handlePathWasUpdated(to path: ViewPath) {
        guard interactor.restoreViewPath() != path else { return }
        savePath(path: path)
    }
    
    func handleNavigationUpdate(to path: ViewPath) {
        updateNavigation(to: path)
    }
    
    func handleRestoreNavigation() {
        handleMainVisible()
        updateNavigation(to: restoredPath)
    }
    
    func handleSettingsViewPath() -> ViewPath.Settings? {
        if let path = interactor.restoreViewPath(), case ViewPath.settings(let option) = path {
            if let option {
                return option
            }
        }
        if let savedOption = interactor.currentSettingsPath() {
            return savedOption
        }
        return nil
    }
}

private extension MainSplitPresenter {
    var restoredPath: ViewPath {
        if let path = interactor.restoreViewPath() {
            return path
        }
        return .main
    }
    
    func handleMainVisible() {
        if restoredPath == .main {
            view?.notifyTokensVisible()
        }
    }
    
    func updateNavigation(to path: ViewPath) {
        savePath(path: path)
        
        switch calledKind {
        case .collapsed: view?.updateTabBarPath(path)
        case .expanded: view?.updateMenuPath(path)
        case .unspecified: return
        }
    }
    
    func savePath(path: ViewPath) {
        checkNewsBadgeMark(oldPath: interactor.restoreViewPath(), newPath: path)

        interactor.setViewPath(path)
        if case ViewPath.settings(let option) = path {
            interactor.saveCurrentSettingsPath(option)
        }
    }
    
    func checkNewsBadgeMark(oldPath: ViewPath?, newPath: ViewPath) {
        guard interactor.hasUnreadNews else { return }
        if oldPath != nil && oldPath == .news && newPath != .news {
            interactor.markNewsAsRead()
            updateNewsBadge()
        }
    }
    
    func updateNewsBadge() {
        view?.updateNewsBadge()
    }
}
