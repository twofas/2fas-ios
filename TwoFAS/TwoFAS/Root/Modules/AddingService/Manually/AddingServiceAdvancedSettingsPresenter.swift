//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

protocol AddingServiceAdvancedSettingsFlowControlling: AnyObject {
    func toUpdate(_ settings: AddingServiceAdvancedSettings)
}

final class AddingServiceAdvancedSettingsPresenter: ObservableObject {
    @Published var selectedTokenType: TokenType {
        didSet { notifyChange() }
    }
    @Published var selectedAlgorithm: Algorithm {
        didSet { notifyChange() }
    }
    @Published var selectedRefreshTime: Period {
        didSet { notifyChange() }
    }
    @Published var selectedDigits: Digits {
        didSet { notifyChange() }
    }
    @Published var initialCounter: Int {
        didSet { notifyChange() }
    }
    @Published var isInitialCounterAlertPresented: Bool = false
    @Published var initialCounterInput: String = ""

    private weak var flowController: AddingServiceAdvancedSettingsFlowControlling?

    init(
        flowController: AddingServiceAdvancedSettingsFlowControlling,
        settings: AddingServiceAdvancedSettings
    ) {
        self.flowController = flowController
        self.selectedTokenType = settings.tokenType
        self.selectedAlgorithm = settings.algorithm
        self.selectedRefreshTime = settings.refreshTime
        self.selectedDigits = settings.digits
        self.initialCounter = settings.initialCounter
    }
}

extension AddingServiceAdvancedSettingsPresenter {
    func handleShowInitialCounterAlert() {
        initialCounterInput = "\(initialCounter)"
        isInitialCounterAlertPresented = true
    }

    func handleSaveInitialCounterFromAlert() {
        if let value = Int(initialCounterInput), value >= 0 {
            initialCounter = value
        }
    }
}

private extension AddingServiceAdvancedSettingsPresenter {
    var settings: AddingServiceAdvancedSettings {
        AddingServiceAdvancedSettings(
            tokenType: selectedTokenType,
            algorithm: selectedAlgorithm,
            refreshTime: selectedRefreshTime,
            digits: selectedDigits,
            initialCounter: initialCounter
        )
    }

    func notifyChange() {
        flowController?.toUpdate(settings)
    }
}
