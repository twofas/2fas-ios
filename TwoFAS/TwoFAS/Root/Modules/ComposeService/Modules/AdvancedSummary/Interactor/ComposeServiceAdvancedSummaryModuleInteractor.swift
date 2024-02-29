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
import Data

protocol ComposeServiceAdvancedSummaryModuleInteracting: AnyObject {
    var tokenType: TokenType { get }
    var algorithm: Algorithm { get }
    var refreshTime: Period { get }
    var numberOfDigits: Digits { get }
    var counter: Int { get }
        
    func copyCounter()
}

final class ComposeServiceAdvancedSummaryModuleInteractor {
    private var isCounterAuthorized = false
    
    private let notificationInteractor: NotificationInteracting
    private let settings: ComposeServiceAdvancedSettings
    
    init(notificationInteractor: NotificationInteracting, settings: ComposeServiceAdvancedSettings) {
        self.notificationInteractor = notificationInteractor
        self.settings = settings
    }
}

extension ComposeServiceAdvancedSummaryModuleInteractor: ComposeServiceAdvancedSummaryModuleInteracting {
    var tokenType: TokenType {
        settings.tokenType ?? .defaultValue
    }
    
    var algorithm: Algorithm {
        settings.algorithm ?? .defaultValue
    }
    
    var refreshTime: Period {
        settings.period ?? .defaultValue
    }
    
    var numberOfDigits: Digits {
        settings.digits ?? .defaultValue
    }
    
    var counter: Int {
        settings.counter ?? TokenType.hotpDefaultValue
    }
    
    func copyCounter() {
        notificationInteractor.copyWithSuccess(value: String(counter))
    }
}
