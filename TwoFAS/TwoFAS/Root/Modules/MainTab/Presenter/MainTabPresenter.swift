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

final class MainTabPresenter {
    weak var view: MainTabViewControlling?
    
    private var areNewsPreloaded = false
    private var previousSelectedViewPath: ViewPath?
    private let flowController: MainTabFlowControlling
    
    init(flowController: MainTabFlowControlling) {
        self.flowController = flowController
    }
}

extension MainTabPresenter {
    func viewDidLoad() {
        flowController.toTabIsReady()
        if !areNewsPreloaded {
            areNewsPreloaded = true
            view?.preloadNews()
        }
    }
    
    func handleDidSelectViewPath(_ viewPath: ViewPath) {
        if previousSelectedViewPath != viewPath {
            flowController.toMainChangedViewPath(viewPath)
            handleChangeViewPath(viewPath)
        } else {
            switch viewPath {
            case .main:
                view?.scrollToTokensTop()
            case .settings:
                view?.setSettingsView(nil)
            case .news:
                view?.scrollToNewsTop()
            }
        }
    }
    
    func handleChangeViewPath(_ viewPath: ViewPath) {
        guard viewPath != previousSelectedViewPath else { return }
        view?.setView(viewPath)
        switch viewPath {
        case .settings(let option):
            view?.setSettingsView(option)
        default: break
        }
        previousSelectedViewPath = viewPath
    }
    
    func handleSettingsChangedViewPath(_ viewPath: ViewPath.Settings) {
        flowController.toMainChangedViewPath(.settings(option: viewPath))
    }
}
