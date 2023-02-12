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
import Common

final class MainMenuPresenter {
    weak var view: MainMenuViewControlling?
    
    private(set) var selectedIndexPath: IndexPath?
    
    private let flowController: MainMenuFlowControlling
    
    init(flowController: MainMenuFlowControlling) {
        self.flowController = flowController
    }
}

extension MainMenuPresenter {
    func viewWillAppear() {
        refresh()
    }
    
    func handleSelection(at indexPath: IndexPath) {
        switch indexPath.section {
        case MainContent.main.rawValue:
            flowController.toMain()
        case MainContent.settings.rawValue:
            flowController.toSettings()
        case MainContent.news.rawValue:
            flowController.toNews()
        default:
            Log("MainMenuPresenter: Can't change to \(indexPath)", severity: .error)
        }
    }
    
    func handleChangeViewPath(_ viewPath: ViewPath) {
        let indexPath = {
            switch viewPath {
            case .main: return IndexPath(row: 0, section: 0)
            case .settings: return IndexPath(row: 0, section: 1)
            case .news: return IndexPath(row: 0, section: 2)
            }
        }()
        handleSelection(at: indexPath)
        refresh()
        // view?.select at index ...
    }
}

private extension MainMenuPresenter {
    func refresh() {
        view?.reload(with: menu)
    }
}
