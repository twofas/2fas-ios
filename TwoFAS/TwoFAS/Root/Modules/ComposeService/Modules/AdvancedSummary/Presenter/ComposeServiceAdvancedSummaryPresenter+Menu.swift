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

struct ComposeServiceAdvancedSummaryMenuSection: TableViewSection {
    let title: String
    var cells: [ComposeServiceAdvancedSummaryMenuCell]
}

struct ComposeServiceAdvancedSummaryMenuCell: Hashable {
    let title: String
    let info: String?
    let isLocked: Bool
    let copyValue: Bool
}

extension ComposeServiceAdvancedSummaryPresenter {
    func buildMenu() -> ComposeServiceAdvancedSummaryMenuSection {
        var cells: [ComposeServiceAdvancedSummaryMenuCell] = []
        cells.append(
            .init(
                title: T.Tokens.otpAuthentication,
                info: interactor.tokenType.rawValue,
                isLocked: false,
                copyValue: false
            )
        )
        cells.append(
            .init(
                title: T.Tokens.algorithm,
                info: interactor.algorithm.rawValue,
                isLocked: false,
                copyValue: false
            )
        )
        
        if interactor.tokenType == .totp {
            cells.append(
                .init(
                    title: T.Tokens.refreshTime,
                    info: T.Tokens.second(interactor.refreshTime.rawValue),
                    isLocked: false,
                    copyValue: false
                )
            )
            cells.append(
                .init(
                    title: T.Tokens.numberOfDigits,
                    info: String(interactor.numberOfDigits.rawValue),
                    isLocked: false,
                    copyValue: false
                )
            )
        } else {
            cells.append(
                .init(
                    title: T.Tokens.numberOfDigits,
                    info: String(interactor.numberOfDigits.rawValue),
                    isLocked: false,
                    copyValue: false
                )
            )
            cells.append(
                .init(
                    title: T.Tokens.counter,
                    info: String(interactor.counter),
                    isLocked: false,
                    copyValue: true
                )
            )
        }
        
        return .init(
            title: T.Tokens.tokenSettings,
            cells: cells
        )
    }
}
