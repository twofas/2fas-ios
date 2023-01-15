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

public typealias ServiceID = String

public struct WidgetCategory {
    public let categoryName: String?
    public let services: [WidgetService]
    
    public init(categoryName: String?, services: [WidgetService]) {
        self.categoryName = categoryName
        self.services = services
    }
}

public struct WidgetService {
    public let serviceID: ServiceID
    public let serviceName: String
    public let serviceTypeID: ServiceTypeID?
    public let iconType: IconType
    public let iconTypeID: IconTypeID
    public let labelTitle: String
    public let labelColor: TintColor
    public let serviceInfo: String?
    public let period: Period
    public let digits: Digits
    public let algorithm: Algorithm
    
    public init(
        serviceID: ServiceID,
        serviceName: String,
        serviceTypeID: ServiceTypeID?,
        iconType: IconType,
        iconTypeID: IconTypeID,
        labelTitle: String,
        labelColor: TintColor,
        serviceInfo: String?,
        period: Period,
        digits: Digits,
        algorithm: Algorithm
    ) {
        self.serviceID = serviceID
        self.serviceName = serviceName
        self.serviceTypeID = serviceTypeID
        self.iconType = iconType
        self.iconTypeID = iconTypeID
        self.labelTitle = labelTitle
        self.labelColor = labelColor
        self.serviceInfo = serviceInfo
        self.period = period
        self.digits = digits
        self.algorithm = algorithm
    }
}

public protocol WidgetServiceHandlerType: AnyObject {
    func listAll(search: String?, exclude: [ServiceID]) -> [WidgetCategory]
    func hasServices() -> Bool
    func listServices(with ids: [ServiceID]) -> [WidgetService]
}

extension WidgetService: ServiceIconDefinition {}
