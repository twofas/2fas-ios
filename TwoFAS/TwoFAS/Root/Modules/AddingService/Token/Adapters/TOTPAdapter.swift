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
import Token

final class TOTPAdapter: NSObject, TokenTimerConsumer {
    var didTapUnlock: ((TokenTimerConsumer) -> Void)? // not used
    
    private weak var presenter: AddingServiceTokenPresenter?
    private(set) var secret: String = ""
    let autoManagable = false
    
    func configure(presenter: AddingServiceTokenPresenter) {
        self.presenter = presenter
        self.secret = presenter.serviceSecret
    }
    
    func setInitial(_ state: TokenTimerInitialConsumerState) {
        switch state {
        case .locked:
            break // not supported here
        case .unlocked(let progress, let period, let currentToken, _, let willChangeSoon):
            presenter?.handleTOTPInital(
                progress: progress,
                period: period,
                token: currentToken,
                willChangeSoon: willChangeSoon
            )
        }
    }
    
    func setUpdate(_ state: TokenTimerUpdateConsumerState) {
        switch state {
        case .locked:
            break // not supported here
        case .unlocked(let progress, _, let currentToken, _, let willChangeSoon):
            presenter?.handleTOTPUpdate(
                progress: progress,
                token: currentToken,
                willChangeSoon: willChangeSoon
            )
        }
    }
}
