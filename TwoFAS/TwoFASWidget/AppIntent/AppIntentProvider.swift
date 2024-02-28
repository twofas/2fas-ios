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

import WidgetKit
import Data
import Intents
import Common
import CommonUIKit
import IntentsUI
import Protection
import Storage
import TimeVerification

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
struct AppIntentProvider: AppIntentTimelineProvider {
    typealias Intent = SelectService
    
    private enum Values {
        case placeholder
        case entry(EntryDescription)
    }
    
    struct EntryDescription {
        let identifier: String
        let secret: String
        let title: String
        let subtitle: String?
        let iconTypeID: IconTypeID
        let serviceTypeID: ServiceTypeID?
        let digits: Digits
        let period: Period
        let algorithm: Algorithm
        let tokenType: TokenType
        let iconType: IconType
        let labelTitle: String
        let labelColor: TintColor
    }
    
    func placeholder(in context: Context) -> CodeEntry {
        CodeEntry.placeholder(with: context.family.servicesCount)
    }
    
    func snapshot(for configuration: SelectService, in context: Context) async -> CodeEntry {
        CodeEntry.snapshot(with: context.family.servicesCount)
    }
    
    @MainActor
    func timeline(for configuration: SelectService, in context: Context) async -> Timeline<CodeEntry> {
        let protection = AccessManager.protection
        let serviceHandler = AccessManager.serviceHandler
        
        let slots = context.family.servicesCount
        
        guard protection.extensionsStorage.areWidgetsEnabled else {
            return Timeline<CodeEntry>(entries: [CodeEntry.placeholder(with: slots)], policy: .never)
        }
        
        let selectedServices = configuration.service
        let currentServices = serviceHandler.listServices(with: selectedServices.compactMap { $0.secret })
        
        var entries: [CodeEntry] = []
        
        let services: [Values] = {
            let list = selectedServices
            var result: [Values] = Array(repeating: Values.placeholder, count: slots)
            for i in 0..<slots {
                if let service = list[safe: i],
                   let widgetService = currentServices.first(where: { $0.serviceID == service.secret }) {
                    let entryDescription = EntryDescription(
                        identifier: "\(service.secret)\(UUID().uuidString)",
                        secret: service.secret,
                        title: widgetService.serviceName,
                        subtitle: widgetService.serviceInfo,
                        iconTypeID: widgetService.iconTypeID,
                        serviceTypeID: widgetService.serviceTypeID,
                        digits: widgetService.digits,
                        period: widgetService.period,
                        algorithm: widgetService.algorithm,
                        tokenType: widgetService.tokenType,
                        iconType: widgetService.iconType,
                        labelTitle: widgetService.labelTitle,
                        labelColor: widgetService.labelColor
                    )
                    
                    result[i] = .entry(entryDescription)
                }
            }
            return result
        }()
        
        let calendar = Calendar.current
        let smallestIncrement: Int = 10
        
        let currentDate = Date()
        let correctedDate = currentDate + Double(TimeOffsetStorage.offset ?? 0)
        let seconds = calendar.component(.second, from: correctedDate)
        let offset: Int = {
            let rest = seconds % smallestIncrement
            return smallestIncrement - rest
        }()
        let slotsCount = context.family.servicesCount
        let divider: Int = {
            if slotsCount > 3 {
                return 27
            }
            let value = slotsCount / 2
            if value == 0 {
                return 1
            }
            return value
        }()
        let upTo = 256 / divider
        
        for i in 0 ..< upTo {
            let currentOffset: Int = {
                if i == 0 {
                    return 0
                } else if i == 1 {
                    return offset
                }
                return offset + smallestIncrement * (i - 1)
            }()
            let entryDate = calendar.date(byAdding: .second, value: currentOffset, to: currentDate)!
            let tokenDate = calendar.date(byAdding: .second, value: currentOffset, to: correctedDate)!
            let entriesList: [CodeEntry.Entry] = services.map { value in
                guard case Values.entry(let entryDescription) = value
                else { return CodeEntry.Entry.placeholder() }
                
                let secondsToNewOne: Int = {
                    let period = entryDescription.period.rawValue
                    let currentSeconds: Int = calendar.component(.second, from: tokenDate)
                    if currentSeconds >= period {
                        let times = (currentSeconds / period) + 1
                        return times * period - currentSeconds
                    }
                    return period - currentSeconds
                }()
                
                let countdownTo = calendar.date(byAdding: .second, value: secondsToNewOne, to: entryDate)!
                
                let token = TokenGenerator.generateTOTP(
                    secret: entryDescription.secret,
                    time: tokenDate,
                    period: entryDescription.period,
                    digits: entryDescription.digits,
                    algoritm: entryDescription.algorithm,
                    tokenType: entryDescription.tokenType
                )
                let entryData = CodeEntry.EntryData(
                    id: entryDescription.identifier,
                    name: entryDescription.title,
                    info: entryDescription.subtitle,
                    code: token.formattedValue(for: entryDescription.tokenType),
                    iconType: {
                        switch entryDescription.iconType {
                        case .brand: return .brand
                        case .label: return .label
                        }
                    }(),
                    labelTitle: entryDescription.labelTitle,
                    labelColor: entryDescription.labelColor,
                    iconTypeID: entryDescription.iconTypeID,
                    serviceTypeID: entryDescription.serviceTypeID,
                    countdownTo: countdownTo,
                    rawEntry: .init(
                        secret: entryDescription.secret,
                        period: entryDescription.period.rawValue,
                        digits: entryDescription.digits.rawValue,
                        algorithm: entryDescription.algorithm.rawValue,
                        tokenType: entryDescription.tokenType.rawValue
                    )
                )
                return .init(kind: .singleEntry, data: entryData)
            }
            
            let entry = CodeEntry(date: entryDate, entries: entriesList)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

extension Period {
    var isShort: Bool {
        rawValue < 30
    }
}
