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

enum ExchangeDataFormat {
    case twoFAS(ExchangeData)
    case twoFASV34(ExchangeData2)
}

enum ExchangeDataServices {
    case twoFAS([ExchangeData.Service])
    case twoFASV34([ExchangeData2.Service])
}

extension ExchangeDataFormat {
    var schemaVersion: Int {
        switch self {
        case .twoFAS(let exchangeData):
            return exchangeData.schemaVersion
        case .twoFASV34(let exchangeData):
            return exchangeData.schemaVersion
        }
    }
    
    var isEncrypted: Bool {
        switch self {
        case .twoFAS(let exchangeData):
            return exchangeData.servicesEncrypted != nil && exchangeData.reference != nil
        case .twoFASV34(let exchangeData):
            return exchangeData.servicesEncrypted != nil && exchangeData.reference != nil
        }
    }
    
    var reference: String? {
        switch self {
        case .twoFAS(let exchangeData):
            return exchangeData.reference
        case .twoFASV34(let exchangeData):
            return exchangeData.reference
        }
    }
    
    var servicesEncrypted: String? {
        switch self {
        case .twoFAS(let exchangeData):
            return exchangeData.servicesEncrypted
        case .twoFASV34(let exchangeData):
            return exchangeData.servicesEncrypted
        }
    }
    
    var services: ExchangeDataServices {
        switch self {
        case .twoFAS(let exchangeData):
            return .twoFAS(exchangeData.services)
        case .twoFASV34(let exchangeData2):
            return .twoFASV34(exchangeData2.services)
        }
    }
    
    func parse(data: Data, using jsonDecoder: JSONDecoder) -> ExchangeDataServices? {
        switch self {
        case .twoFAS:
            guard let services = try? jsonDecoder.decode([ExchangeData.Service].self, from: data) else {
                return nil
            }
            return .twoFAS(services)
        case .twoFASV34:
            guard let services = try? jsonDecoder.decode([ExchangeData2.Service].self, from: data) else {
                return nil
            }
            return .twoFASV34(services)
        }
    }
    
    func parseGroups() -> [CommonSectionData] {
        switch self {
        case .twoFAS(let exchangeData):
            return exchangeData.groups?
                .compactMap({ item in
                    guard let id = UUID(uuidString: item.id) else { return nil }
                    return .init(
                        name: item.name,
                        sectionID: id.uuidString,
                        creationDate: Date(),
                        modificationDate: nil,
                        isCollapsed: !item.isExpanded
                    )
                }) ?? []
        case .twoFASV34(let exchangeData):
            return exchangeData.groups?
                .compactMap({ item in
                    guard let id = UUID(uuidString: item.id) else { return nil }
                    return .init(
                        name: item.name,
                        sectionID: id.uuidString,
                        creationDate: Date(),
                        modificationDate: nil,
                        isCollapsed: !item.isExpanded
                    )
                }) ?? []
        }
    }
}
