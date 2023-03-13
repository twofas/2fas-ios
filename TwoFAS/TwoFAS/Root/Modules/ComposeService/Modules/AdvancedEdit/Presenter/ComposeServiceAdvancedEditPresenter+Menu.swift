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

struct ComposeServiceAdvancedEditMenuSection: TableViewSection {
    let title: String
    var cells: [ComposeServiceAdvancedEditMenuCell]
    let footer: String
}

struct ComposeServiceAdvancedEditMenuCell: Hashable {
    enum TokenType: Hashable {
        case totp
        case hotp
    }
    enum Kind: Hashable {
        case tokenType(TokenType)
        case algorithm(String)
        case refreshTime(String)
        case numberOfDigits(String)
        case initialCounter(String)
    }
    let kind: Kind
}

extension ComposeServiceAdvancedEditPresenter {
    func buildMenu() -> ComposeServiceAdvancedEditMenuSection {
        var cells: [ComposeServiceAdvancedEditMenuCell] = []
        if interactor.tokenType == .totp {
            cells.append(.init(kind: .tokenType(.totp)))
            cells.append(.init(kind: .algorithm(interactor.algorithm.rawValue)))
            cells.append(.init(kind: .refreshTime(T.Tokens.second(interactor.refreshTime.rawValue))))
            cells.append(.init(kind: .numberOfDigits(String(interactor.numberOfDigits.rawValue))))
        } else {
            cells.append(.init(kind: .tokenType(.hotp)))
            cells.append(.init(kind: .initialCounter(String(interactor.counter))))
            cells.append(.init(kind: .numberOfDigits(String(interactor.numberOfDigits.rawValue))))
        }
        
        return .init(
            title: T.Tokens.tokenSettings,
            cells: cells,
            footer: T.Tokens.advancedSettingsFooterTitle
        )
    }
}

extension ComposeServiceAdvancedEditMenuCell.Kind {
    var localizedString: String {
        switch self {
        case .tokenType: return ""
        case .algorithm: return T.Tokens.algorithm
        case .refreshTime: return T.Tokens.refreshTime
        case .numberOfDigits: return T.Tokens.numberOfDigits
        case .initialCounter: return T.Tokens.initialCounter
        }
    }
    
    var value: String {
        switch self {
        case .tokenType: return ""
        case .algorithm(let value): return value
        case .refreshTime(let value): return value
        case .numberOfDigits(let value): return value
        case .initialCounter(let value): return value
        }
    }
}
