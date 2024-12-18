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
import AppIntents
import Common
import CommonUIKit

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct ServiceAppEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Service")
    
    @Property(title: "Secret")
    var secret: String
    
    struct ServiceAppEntityQuery: EntityQuery {
        @MainActor
        func entities(for identifiers: [String]) async throws -> [ServiceAppEntity] {
            SelectedItems.list = identifiers
            return AccessManager.serviceHandler.listAll(search: nil, exclude: [])
                .flatMap({ $0.services })
                .filter({ identifiers.contains($0.serviceID) })
                .map({ service in
                    ServiceAppEntity(
                        id: service.serviceID,
                        displayString: service.serviceName,
                        secret: service.serviceID
                    )
                })
        }
        
        @MainActor
        func suggestedEntities() async throws -> ItemCollection<ServiceAppEntity> {
            guard AccessManager.protection.extensionsStorage.areWidgetsEnabled else {
                throw SelectServiceError.errorNotEnabled
            }
            guard AccessManager.serviceHandler.hasServices() else {
                throw SelectServiceError.errorNoServices
            }
                        
            let all: [WidgetCategory] = AccessManager.serviceHandler.listAll(search: nil, exclude: [])
            let sections = all.map({ category -> ItemSection<ServiceAppEntity> in
                let services: [Item] = category.services
                    .filter({ !SelectedItems.list.contains($0.serviceID) })
                    .map({ service in
                    let icon = service.icon.pngData()
                    let image: DisplayRepresentation.Image? = {
                        if let icon {
                            return DisplayRepresentation.Image(data: icon)
                        }
                        return nil
                    }()
                    let subtitle: LocalizedStringResource? = {
                        if let serviceInfo = service.serviceInfo {
                            return LocalizedStringResource(stringLiteral: serviceInfo)
                        }
                        return nil
                    }()
                    return Item(
                        ServiceAppEntity(
                            id: service.serviceID,
                            displayString: service.serviceName,
                            secret: service.serviceID
                        ),
                        title: LocalizedStringResource(stringLiteral: service.serviceName),
                        subtitle: subtitle,
                        image: image
                    )
                })
                let categoryName: LocalizedStringResource = {
                    if let categoryName = category.categoryName {
                        return LocalizedStringResource(stringLiteral: categoryName)
                    }
                    return LocalizedStringResource("tokens__my_tokens")
                }()
                return ItemSection(categoryName, items: services)
            })
            return ItemCollection(
                promptLabel: LocalizedStringResource("widget__select_service_intent_description"),
                sections: sections
            )
        }
    }
    static var defaultQuery = ServiceAppEntityQuery()
    
    var id: String
    var displayString: String
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayString)")
    }
    
    init(id: String, displayString: String, secret: String) {
        self.id = id
        self.displayString = displayString
        self.secret = secret
    }
}

enum SelectServiceError: Error, CustomLocalizedStringResourceConvertible {
    case errorNotEnabled
    case errorNotEnabledNoServices
    case errorNoServices
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .errorNotEnabled: LocalizedStringResource("widget__not_enabled")
        case .errorNotEnabledNoServices: LocalizedStringResource("widget__not_enabled_no_services")
        case .errorNoServices: LocalizedStringResource("widget__no_services")
        }
    }
}

enum SelectedItems {
    static var list: [String] = []
}
