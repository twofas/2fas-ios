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

final class BrowserExtensionEditNamePresenter {
    weak var view: BrowserExtensionEditNameViewControlling?
    
    let minLength = 3
    let maxLength = 60
    
    private let flowController: BrowserExtensionEditNameFlowControlling
    private(set) var currentName: String
    
    init(flowController: BrowserExtensionEditNameFlowControlling, currentName: String) {
        self.flowController = flowController
        self.currentName = currentName
    }
    
    func viewWillAppear() {
        reload()
    }
    
    func viewDidAppear() {
        view?.showKeyboard()
    }
    
    func handleNewValue(_ newValue: String?) {
        guard let newValue = newValue?.trim(), newValue.count >= minLength, newValue.count <= maxLength else {
            view?.disableSave()
            return
        }
        
        view?.enableSave()
        currentName = newValue
    }
    
    func handleSave() {
        flowController.toChangeName(currentName)
    }
}

private extension BrowserExtensionEditNamePresenter {
    func reload() {
        let menu = buildMenu()
        view?.reload(with: menu)
    }
}
