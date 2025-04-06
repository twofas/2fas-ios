//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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
import CommonWatch
import SwiftUI

final class MainPresenter: ObservableObject {
    @Published var favoriteList: [Service] = []
    @Published var showPairQRCode: Bool = false
    @Published var showSystemKeyError: Bool = false
    
    private let interactor: MainInteracting
    
    init(interactor: MainInteracting) {
        self.interactor = interactor
        interactor.showPairQRCode = { [weak self] in
            self?.showPairQRCode = $0
        }
        interactor.showSystemKeyError = { [weak self] in
            self?.showSystemKeyError = $0
        }
    }
    
    func onAppear() {
        refresh()
    }
    
    private func refresh() {
        favoriteList = interactor
            .listFavoriteServices()
            .map { $0.toService() }
    }
}
