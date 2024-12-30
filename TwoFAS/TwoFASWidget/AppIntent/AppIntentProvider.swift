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
    private let defaults = UserDefaults(suiteName: "group.twofas.com")
    private let calendar = Calendar.current
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
        let digits: Digits
        let period: Period
        let algorithm: Algorithm
        let tokenType: TokenType
        let iconType: IconType
        let labelTitle: String
        let labelColor: TintColor
        let isValidSecret: Bool
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
        
        let slots = context.family.servicesCount
        guard protection.extensionsStorage.areWidgetsEnabled else {
            return Timeline<CodeEntry>(entries: [CodeEntry.placeholder(with: slots)], policy: .never)
        }
        
        let isClickable = context.family.isClickable
        let (validSecret, secondsLeft) = handleClickableWidgets()
        let currentServices = AccessManager
            .serviceHandler
            .listServices(with: configuration.service?.compactMap { $0.secret } ?? [])
        let services = listServices(
            slots: slots,
            validSecret: validSecret,
            configuration: configuration,
            currentServices: currentServices,
            isClickable: isClickable
        )
        let currentDate = Date()
        let correctedDate = currentDate + Double(TimeOffsetStorage.offset ?? 0)
        let seconds = calendar.component(.second, from: correctedDate)
        let smallestIncrement: Int = {
            if isClickable {
                return Period.period10.rawValue
            }
            
            return currentServices.min(by: {
                $0.period.rawValue < $1.period.rawValue
            })?.period.rawValue ?? Period.period30.rawValue
        }()
        let offset: Int = {
            let rest = seconds % smallestIncrement
            return smallestIncrement - rest
        }()
        
        let upTo: Int = {
            if isClickable {
                return Int(ceil(Double(secondsLeft) / Double(smallestIncrement))) + 1
            } else {
                let timeSlots = 186
                return timeSlots / services.count
            }
        }()
        
        var entries: [CodeEntry] = []
        
        for i in 0 ..< upTo {
            let isLast = upTo - i == 1
            
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
            
            let entriesList: [CodeEntry.Entry] = services.compactMap { value in
                guard case Values.entry(let entryDescription) = value
                else { return CodeEntry.Entry.placeholder() }
                
                let showWithCode = !isLast
                let secondsToNewOne: Int = {
                    let period = entryDescription.period.rawValue
                    let currentSeconds: Int = calendar.component(.second, from: tokenDate)
                    if currentSeconds >= period {
                        let times = (currentSeconds / period) + 1
                        return times * period - currentSeconds
                    }
                    return period - currentSeconds
                }()
                
                let formattedCode: String = {
                    if showWithCode {
                        let token = TokenGenerator.generateTOTP(
                            secret: entryDescription.secret,
                            time: tokenDate,
                            period: entryDescription.period,
                            digits: entryDescription.digits,
                            algoritm: entryDescription.algorithm,
                            tokenType: entryDescription.tokenType
                        )
                        return token.formattedValue(for: entryDescription.tokenType)
                    } else {
                        return TokenValue.emptyOfLength(entryDescription.digits.rawValue)
                            .formattedValue(for: entryDescription.tokenType)
                    }
                }()
                var entryData = CodeEntry.EntryData(
                    id: entryDescription.identifier,
                    secret: entryDescription.secret,
                    name: entryDescription.title,
                    info: entryDescription.subtitle,
                    iconType: {
                        switch entryDescription.iconType {
                        case .brand: return .brand
                        case .label: return .label
                        }
                    }(),
                    labelTitle: entryDescription.labelTitle,
                    labelColor: entryDescription.labelColor,
                    iconTypeID: entryDescription.iconTypeID,
                    code: formattedCode,
                    countdownTo: nil,
                    rawEntry: nil
                )
                if showWithCode {
                    entryData.countdownTo = calendar.date(byAdding: .second, value: secondsToNewOne, to: entryDate)
                    entryData.rawEntry = .init(
                        secret: entryDescription.secret,
                        period: entryDescription.period.rawValue,
                        digits: entryDescription.digits.rawValue,
                        algorithm: entryDescription.algorithm.rawValue,
                        tokenType: entryDescription.tokenType.rawValue
                    )
                }
                let kind: Entry.Kind = {
                    if isClickable {
                        return showWithCode ? .singleEntry : .singleEntryHidden
                    }
                    return .singleEntry
                }()
                return .init(kind: kind, data: entryData)
            }
            
            let entry = CodeEntry(date: entryDate, entries: entriesList)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: isClickable ? .never : .atEnd)
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
extension AppIntentProvider {
    private func clearDefaults() {
        defaults?.removeObject(forKey: CommonKeys.tapDate)
        defaults?.removeObject(forKey: CommonKeys.tapSecret)
        defaults?.synchronize()
    }
    
    private func handleClickableWidgets() -> (validSecret: Secret?, secondsLeft: Int) {
        let validSecret: Secret?
        let secondsLeft: Int
        
        if  let dateValue = defaults?.double(forKey: "tapDate"), !dateValue.isZero {
            let duration = Date().timeIntervalSince1970 - dateValue
            if duration < 60.0, let storedSecret = defaults?.string(forKey: "tapSecret") {
                secondsLeft = 60 - Int(duration)
                validSecret = storedSecret
            } else {
                clearDefaults()
                validSecret = nil
                secondsLeft = 0
            }
        } else {
            clearDefaults()
            validSecret = nil
            secondsLeft = 0
        }
        
        return (validSecret: validSecret, secondsLeft: secondsLeft)
    }
    
    @MainActor
    private func listServices(
        slots: Int,
        validSecret: Secret?,
        configuration: SelectService,
        currentServices: [WidgetService],
        isClickable: Bool
    ) -> [Values] {
        var result: [Values] = Array(repeating: Values.placeholder, count: slots)
        for i in 0..<slots {
            guard let service = configuration.service?[safe: i],
                  let widgetService = currentServices.first(where: { $0.serviceID == service.secret }) else {
                continue
            }
            let entryDescription = EntryDescription(
                identifier: "\(service.secret)\(UUID().uuidString)",
                secret: service.secret,
                title: widgetService.serviceName,
                subtitle: widgetService.serviceInfo,
                iconTypeID: widgetService.iconTypeID,
                digits: widgetService.digits,
                period: widgetService.period,
                algorithm: widgetService.algorithm,
                tokenType: widgetService.tokenType,
                iconType: widgetService.iconType,
                labelTitle: widgetService.labelTitle,
                labelColor: widgetService.labelColor,
                isValidSecret: isClickable ? service.secret == validSecret : true
            )
            
            result[i] = .entry(entryDescription)
        }
        return result
    }
}
