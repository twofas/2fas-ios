//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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

import SwiftUI
import Common

final class ManageWatchPresenter: ObservableObject {
    @Published
    var isListAvailable = true
    @Published
    var list: [PairedWatch] = []
    
    private let flowController: ManageWatchFlowControlling
    private let interactor: ManageWatchModuleInteracting
    
    init(flowController: ManageWatchFlowControlling, interactor: ManageWatchModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
        interactor.stateDidChange = { [weak self] in
            self?.reload()
        }
    }
}

extension ManageWatchPresenter {
    func onAppear() {
        reload()
    }
    
    func handleReloadList() {
        reload()
    }
    
    func onPairWatch() {
        flowController.toCamera()
    }
    
    func onClose() {
        flowController.close()
    }
    
    func onDelete(_ pairedWatch: PairedWatch) {
        interactor.unpair(pairedWatch)
    }
    
    func onRename(_ pairedWatch: PairedWatch) {
        flowController.toRename(pairedWatch)
    }
    
    func handleRename(_ newName: String, _ pairedWatch: PairedWatch) {
        interactor.rename(pairedWatch, newName: newName)
    }
}

private extension ManageWatchPresenter {
    func reload() {
        isListAvailable = interactor.canAccessList
        list = interactor.list()
    }
}
