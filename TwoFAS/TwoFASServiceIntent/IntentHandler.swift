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

import Intents
import IntentsUI
import UIKit
import Storage
import Protection
import Common
import CommonUIKit

final class IntentHandler: INExtension, SelectServiceIntentHandling {
    private let domain = "2FAS_Widget"
    
    private lazy var protection = Protection()
    private lazy var serviceHandler: WidgetServiceHandlerType = {
        EncryptionHolder.initialize(with: protection.localKeyEncryption)
        return Storage(readOnly: true, logError: nil).widgetService
    }()
    
    func provideServiceOptionsCollection(
        for intent: SelectServiceIntent,
        with completion: @escaping (INObjectCollection<Service>?, Error?) -> Void
    ) {
        switch (serviceHandler.hasServices(), protection.extensionsStorage.areWidgetsEnabled) {
        case (false, false):
            completion(nil, errorNotEnabledNoServices)
            return
        case (true, false):
            completion(nil, errorNotEnabled)
            return
        case (false, true):
            completion(nil, errorNoServices)
            return
        default: break
        }
        
        let current: [String] = intent.service?.compactMap({ $0.secret }) ?? []
        let all: [WidgetCategory] = serviceHandler.listAll(search: nil, exclude: current)
        let sections = all.map({ category -> INObjectSection<Service> in
            let services: [Service] = category.services.map({
                let icon = $0.icon
                let id = "\($0.serviceID)\(UUID().uuidString)" // in case user selects twice the same service
                let service = Service(
                    identifier: id,
                    display: $0.serviceName,
                    subtitle: $0.serviceInfo,
                    image: INImage(uiImage: icon)
                )
                service.secret = $0.serviceID
                return service
            })
            return INObjectSection(title: category.categoryName, items: services)
        })
        let collection = INObjectCollection(sections: sections)
        completion(collection, nil)
    }
}

private extension IntentHandler {
    var errorNotEnabled: NSError {
        NSError(
            domain: domain,
            code: 601,
            userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("widget_not_enabled", comment: "")]
        )
    }
    
    var errorNotEnabledNoServices: NSError {
        NSError(
            domain: domain,
            code: 602,
            userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("widget_not_enabled_no_services", comment: "")]
        )
    }
    
    var errorNoServices: NSError {
        NSError(
            domain: domain,
            code: 603,
            userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("widget_no_services", comment: "")]
        )
    }
}
