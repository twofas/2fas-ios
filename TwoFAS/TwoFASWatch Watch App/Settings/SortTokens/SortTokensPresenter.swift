//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
//  Contributed by Grzegorz Machnio. All rights reserved.
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

import CommonWatch
import SwiftUI

protocol SortTokensPresenting: ObservableObject {
    var currentSortType: SortType { get }
    var sortTypes: [SortType] { get }

    func onAppear()
    func set(_ sortType: SortType)
}

final class SortTokensPresenter: SortTokensPresenting {
    @Published
    var currentSortType: SortType = .manual

    var sortTypes: [SortType] {
        SortType.allCases
    }

    private let interactor: SortTokensInteracting

    init(interactor: SortTokensInteracting) {
        self.interactor = interactor
    }

    func onAppear() {
        currentSortType = interactor.currentSortType
    }

    func set(_ sortType: SortType) {
        interactor.set(sortType)
        currentSortType = sortType
    }
}

extension SortType {
    var localized: String {
        switch self {
        case .az: return T.Tokens.sortByAToZ
        case .za: return T.Tokens.sortByZToA
        case .manual: return T.Tokens.sortByManual
        }
    }

    func image(forSelectedOption option: Self, configuration: UIImage.SymbolConfiguration) -> UIImage {
        var image: UIImage?
        switch self {
        case .az: image = UIImage(systemName: "arrow.down")
        case .za: image = UIImage(systemName: "arrow.up")
        case .manual: image = UIImage(systemName: "line.3.horizontal")
        }

        if self == option {
            image = image?.withConfiguration(configuration)
        }
        return image?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    }
}
