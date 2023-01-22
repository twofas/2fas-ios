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

final class ComposeServiceAdvancedEditPresenter {
    weak var view: ComposeServiceAdvancedEditViewControlling?
    
    private let flowController: ComposeServiceAdvancedEditFlowControlling
    let interactor: ComposeServiceAdvancedEditModuleInteracting
    
    init(
        flowController: ComposeServiceAdvancedEditFlowControlling,
        interactor: ComposeServiceAdvancedEditModuleInteracting
    ) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension ComposeServiceAdvancedEditPresenter {
    func viewWillAppear() {
        reload()
    }
    
    func handleSelection(at indexPath: IndexPath) {
        let menu = buildMenu()
        guard let cell = menu.cells[safe: indexPath.row] else { return }
        switch cell.kind {
        case .algorithm:
            flowController.toAlgorithm(interactor.valueAlgorithm)
        case .refreshTime:
            flowController.toRefreshTime(interactor.valueRefreshTime)
        case .numberOfDigits:
            flowController.toNumberOfDigits(interactor.valueNumberOfDigits)
        case .initialCounter:
            flowController.toCounter(interactor.valueCounter)
        default:
            break
        }
    }
    
    func handleTokenTypeChange(_ tokenType: TokenType) {
        interactor.setTokenType(tokenType)
        updateDataState()
    }
    
    func handleAlgorithm(_ algorithm: Algorithm) {
        interactor.setAlgorithm(algorithm)
        updateDataState()
    }
    
    func handleRefreshTime(_ refreshTime: Period) {
        interactor.setRefreshTime(refreshTime)
        updateDataState()
    }
    
    func handleNumberOfDigits(_ numberOfDigits: Digits) {
        interactor.setNumberOfDigits(numberOfDigits)
        updateDataState()
    }
    
    func handleCounter(_ counter: Int) {
        interactor.setCounter(counter)
        updateDataState()
    }
}

private extension ComposeServiceAdvancedEditPresenter {
    func updateDataState() {
        flowController.toSettingsUpdate(interactor.settings)
        reload()
    }
    
    func reload() {
        let menu = buildMenu()
        view?.reload(with: menu)
    }
}
