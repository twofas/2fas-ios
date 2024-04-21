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

final class ServicePresenter: ObservableObject {
    @Published var name = ""
    @Published var additionalInfo: String?
    @Published var service: Service
    @Published var isFavorite: Bool
    @Published var isHOTP: Bool
    
    private let interactor: ServiceInteracting
    
    init(interactor: ServiceInteracting) {
        self.interactor = interactor
        
        interactor.initialize()
        
        name = interactor.service.name
        additionalInfo = interactor.service.additionalInfo
        service = interactor.service
        isFavorite = interactor.isFavorite()
        isHOTP = interactor.isHOTP()
    }
}

extension ServicePresenter {
    func calculateToken(for date: Date) -> TokenValue {
        interactor.token(for: date)
    }
    
    func timelineEntries() -> [Date] {
        interactor.timelineEntries(for: Date())
    }
    
    func timeToNextDate(for date: Date) -> Date {
        interactor.timeToNextDate(for: date)
    }
    
    func toggleFavorite() {
        interactor.toogleFavorite()
        isFavorite = interactor.isFavorite()
    }
}
