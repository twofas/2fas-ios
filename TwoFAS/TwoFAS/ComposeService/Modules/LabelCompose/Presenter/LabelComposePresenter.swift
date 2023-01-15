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

final class LabelComposePresenter {
    weak var view: LabelComposeViewControlling?
    
    private let flowController: LabelComposeFlowControlling
    
    private var activeSet = false
    
    private var title: String
    private var color: TintColor
    
    init(flowController: LabelComposeFlowControlling, title: String, color: TintColor) {
        self.flowController = flowController
        self.title = title
        self.color = color
    }
}

extension LabelComposePresenter {
    func viewWillAppear() {
        view?.setTitle(title)
        view?.setColor(color)
        view?.setInitialColor(color)
        updateSaveButtonState()
    }
    
    func viewDidLayoutSubviews() {
        guard !activeSet else { return }
        activeSet = true
        view?.scrollToActiveColor()
    }
    
    func handleSave() {
        AnalyticsLog(.codeDetailsLabelSet)
        flowController.toSave(title: title, color: color)
    }
    
    func handleSetColor(_ color: TintColor) {
        self.color = color
        view?.setColor(color)
    }
    
    func handleSetTitle(_ title: String) {
        self.title = title
        updateSaveButtonState()
        view?.updateTitle(title)
    }
}

private extension LabelComposePresenter {
    func updateSaveButtonState() {
        if title.isEmpty {
            view?.disableSaveButton()
        } else {
            view?.enableSaveButton()
        }
    }
}
