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

protocol ServiceInteracting: AnyObject {
    var service: Service { get }
    
    func initialize()
    func token(for date: Date) -> TokenValue
    func timelineEntries(for date: Date) -> [Date]
    func timeToNextDate(for date: Date) -> Date
    
    func isFavorite() -> Bool
    func toogleFavorite()
    
    func isHOTP() -> Bool
}

final class ServiceInteractor {
    private let mainRepository: MainRepository
    let service: Service
    
    private let calendar = Calendar.current
    
    private var serviceData: ServiceData?
    
    init(mainRepository: MainRepository, service: Service) {
        self.mainRepository = mainRepository
        self.service = service
    }
}

extension ServiceInteractor: ServiceInteracting {
    func initialize() {
        serviceData = mainRepository.service(for: service.id)
    }
    
    func token(for date: Date) -> TokenValue {
        guard let serviceData else { return "" }
        return mainRepository.token(
            secret: serviceData.secret,
            time: date,
            digits: Digits.create(serviceData.digits),
            period: Period.create(serviceData.period),
            algorithm: serviceData.algorithm,
            counter: 0,
            tokenType: serviceData.tokenType
        )
        .formattedValue(for: serviceData.tokenType)
    }
    
    func timeToNextDate(for date: Date) -> Date {
        guard let serviceData else { return Date.now }
        
        let secondsToNewOne: Int = {
            let period = serviceData.period
            let currentSeconds: Int = calendar.component(.second, from: date)
            if currentSeconds >= period {
                let times = (currentSeconds / period) + 1
                return times * period - currentSeconds
            }
            return period - currentSeconds
        }()
        
        return calendar.date(byAdding: .second, value: secondsToNewOne, to: date)!
    }
    
    func timelineEntries(for date: Date) -> [Date] {
        guard let serviceData else { return [] }
        var entries: [Date] = []
        
        let smallestIncrement = serviceData.period
        
        let seconds = calendar.component(.second, from: date)
        let offset: Int = {
            let rest = seconds % smallestIncrement
            return smallestIncrement - rest
        }()
        let upTo = 256
        
        for i in 0 ..< upTo {
            let currentOffset: Int = {
                if i == 0 {
                    return 0
                } else if i == 1 {
                    return offset
                }
                return offset + smallestIncrement * (i - 1)
            }()
            let entryDate = calendar.date(byAdding: .second, value: currentOffset, to: date)!
                        
            entries.append(entryDate)
        }
        
        return entries
    }
    
    func isFavorite() -> Bool {
        mainRepository.listFavoriteServices().contains(where: { $0.secret == service.id })
    }
    
    func isHOTP() -> Bool {
        guard let serviceData else { return false }
        return serviceData.tokenType == .hotp
    }
    
    func toogleFavorite() {
        if isFavorite() {
            mainRepository.removeFavoriteService(service.id)
        } else {
            mainRepository.addFavoriteService(service.id)
        }
    }
}
