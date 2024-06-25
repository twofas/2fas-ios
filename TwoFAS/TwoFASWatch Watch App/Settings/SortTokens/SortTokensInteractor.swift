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

protocol SortTokensInteracting {
    var currentSortType: SortType { get }

    func set(_ sortType: SortType)
}

final class SortTokensInteractor: SortTokensInteracting {
    var currentSortType: SortType {
        mainRepository.sortType ?? .manual
    }

    private let mainRepository: MainRepository

    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }

    func set(_ sortType: SortType) {
        Log("SortInteractor - saving new sort type \(sortType)", module: .interactor)
        mainRepository.setSortType(sortType)
    }
}
