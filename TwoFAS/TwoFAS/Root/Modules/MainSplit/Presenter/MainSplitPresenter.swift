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
    }
    
    func handleCollapse() {
        guard calledKind != Kind.collapsed else { return }
        calledKind = .collapsed
        
        handleRestoreNavigation()
    }
    
    func handleExpansion() {
        guard calledKind != Kind.expanded else { return }
        calledKind = .expanded

        handleRestoreNavigation()
    }
    
    func handlePathWasUpdated(to path: ViewPath) {
        guard interactor.restoreViewPath() != path else { return }
        interactor.setViewPath(path)
    }
    
    func handleNavigationUpdate(to path: ViewPath) {
        updateNavigation(to: path)
    }
    
    func handleRestoreNavigation() {
        let path: ViewPath = {
            if let path = interactor.restoreViewPath() {
                return path
            }
            return .main
        }()
        updateNavigation(to: path)
    }
    
    func handleSettingsViewPath() -> ViewPath.Settings {
        let firstValue: ViewPath.Settings = .backup
        guard let path = interactor.restoreViewPath() else { return firstValue }
        if case ViewPath.settings(let option) = path {
            return option ?? firstValue
        }
        return firstValue
    }
}

private extension MainSplitPresenter {
    func updateNavigation(to path: ViewPath) {
        interactor.setViewPath(path)
        
        switch calledKind {
        case .collapsed: view?.updateTabBarPath(path)
        case .expanded: view?.updateMenuPath(path)
        case .unspecified: return
        }
    }
}
