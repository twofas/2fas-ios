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

import SwiftUI
import Common
import Data

final class LabelComposePresenter: ObservableObject {
    @Published var title: String
    @Published var color: TintColor

    var isSaveEnabled: Bool {
        !title.isEmpty && (title != initialTitle || color != initialColor)
    }

    private let initialTitle: String
    private let initialColor: TintColor
    private let flowController: LabelComposeFlowControlling

    init(flowController: LabelComposeFlowControlling, title: String, color: TintColor) {
        self.flowController = flowController
        self.title = title
        self.color = color
        self.initialTitle = title
        self.initialColor = color
    }
}

extension LabelComposePresenter {
    func handleSave() {
        AppEventLog(.codeDetailsLabelSet)
        flowController.toSave(title: title, color: color)
    }

    func handleBack() {
        flowController.close()
    }

    func sanitize(_ value: String) -> String {
        let filtered = value.filter { char in
            char.isASCII || char.isLetter || char.isNumber || char.isSymbol || char.isEmoji
        }
        return String(filtered.prefix(ServiceRules.labelMaxLength))
            .uppercased()
    }
}
