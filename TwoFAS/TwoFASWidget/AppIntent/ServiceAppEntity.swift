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
@preconcurrency import Storage
@preconcurrency import Protection
@preconcurrency import Common
@preconcurrency import CommonUIKit
//import SwiftUI

//struct ServiceAppEntityOptionsProvider: DynamicOptionsProvider {
//    private let protection = Protection()
//    private var serviceHandler: WidgetServiceHandlerType = {
//        EncryptionHolder.initialize(with: Protection().localKeyEncryption)
//        return Storage(readOnly: true, logError: nil).widgetService
//    }()
//    
//    func results() async throws -> ItemCollection<ServiceAppEntity> {
//        switch (serviceHandler.hasServices(), protection.extensionsStorage.areWidgetsEnabled) {
//        case (false, false):
//            throw SelectServiceError.errorNotEnabledNoServices
//        case (true, false):
//            throw SelectServiceError.errorNotEnabled
//        case (false, true):
//            throw SelectServiceError.errorNoServices
//        default: break
//        }
//        
//        let all: [WidgetCategory] = serviceHandler.listAll(search: nil, exclude: [])
//        let sections = all.map({ category -> ItemSection<ServiceAppEntity> in
//            let services: [Item] = category.services.map({ service in
//                let icon = service.icon.pngData()
//                let image: DisplayRepresentation.Image? = {
//                    if let icon {
//                        return DisplayRepresentation.Image(data: icon)
//                    }
//                    return nil
//                }()
//                let subtitle: LocalizedStringResource? = {
//                    if let serviceInfo = service.serviceInfo {
//                        return LocalizedStringResource(stringLiteral: serviceInfo)
//                    }
//                    return nil
//                }()
//                let id = service.serviceID
//                return Item(
//                    ServiceAppEntity(id: id, displayString: service.serviceName, secret: id),
//                    title: LocalizedStringResource(stringLiteral: service.serviceName),
//                    subtitle: subtitle,
//                    image: image
//                )
//            })
//            let categoryName: LocalizedStringResource = {
//                if let categoryName = category.categoryName {
//                    return LocalizedStringResource(stringLiteral: categoryName)
//                }
//                return LocalizedStringResource(stringLiteral: "Main category") // TODO: Add proper string
//            }()
//            return ItemSection(categoryName, items: services)
//        })
//        return ItemCollection(promptLabel: "This is promp!", sections: sections)
//        //
//        //
//        //            ItemCollection {
//        //                ItemSection("Nazwa grupy") {
//        //                    Item(ServiceAppEntity(id: "test", displayString: "SoneOther44", secret: "test"), title: "SoneOther44-77", subtitle: "This is account name")
//        //                    Item(ServiceAppEntity(id: "test2", displayString: "SoneOther55", secret: "test2"), title: "SoneOther55-77", subtitle: "This is account name2")
//        //                }
//        //            }
//    }
//}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct ServiceAppEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Service")
    
    private let protection = Protection()
    private var serviceHandler: WidgetServiceHandlerType = {
        EncryptionHolder.initialize(with: Protection().localKeyEncryption)
        return Storage(readOnly: true, logError: nil).widgetService
    }()
    
    @Property(title: "Secret")
    var secret: String
    
    struct ServiceAppEntityQuery: EntityQuery {
        private let protection = Protection()
        private var serviceHandler: WidgetServiceHandlerType = {
            EncryptionHolder.initialize(with: Protection().localKeyEncryption)
            return Storage(readOnly: true, logError: nil).widgetService
        }()
        
        func defaultResult() async -> ServiceAppEntity? {
            nil
        }
        
        func entities(for identifiers: [String]) async throws -> [ServiceAppEntity] {
            let ids = identifiers.compactMap({ $0.split(separator: "#").first })
                .map({ String($0) })
            var identifiers = identifiers
            return serviceHandler.listAll(search: nil, exclude: [])
                .flatMap({ $0.services })
                .filter({ ids.contains($0.serviceID) })
                .compactMap({ service in
                    guard let index = identifiers.firstIndex(where: { $0.contains(service.serviceID) }) else { return nil }
                    let id = identifiers[index]
                    identifiers.remove(at: index)
                    return ServiceAppEntity(
                        id: id,
                        displayString: service.serviceName,
                        secret: service.serviceID
                    )
                })
        }
        
//        func entities(for identifiers: [ServiceAppEntity.ID]) async throws -> ItemCollection<ServiceAppEntity> {
//            let current: [String] = identifiers
//            return [.init(id: "test", displayString: "SoneOther", secret: "test"), .init(id: "test2", displayString: "SoneOther2", secret: "test2")]
//            //                    let all: [WidgetCategory] = serviceHandler.listAll(search: nil, exclude: current)
//            //                    let sections = all.map({ category -> INObjectSection<Service> in
//            //                        let services: [Service] = category.services.map({
//            //                            let icon = $0.icon
//            //                            let id = "\($0.serviceID)\(UUID().uuidString)" // in case user selects twice the same service
//            //                            let service = Service(
//            //                                identifier: id,
//            //                                display: $0.serviceName,
//            //                                subtitle: $0.serviceInfo,
//            //                                image: INImage(uiImage: icon)
//            //                            )
//            //                            service.secret = $0.serviceID
//            //                            return service
//            //                        })
//            //                        return INObjectSection(title: category.categoryName, items: services)
//            //                    })
//            //                    let collection = INObjectCollection(sections: sections)
//            //                    completion(collection, nil)
//            //            return []
//        }
        
        func suggestedEntities() async throws -> ItemCollection<ServiceAppEntity> {
            switch (serviceHandler.hasServices(), protection.extensionsStorage.areWidgetsEnabled) {
            case (false, false):
                throw SelectServiceError.errorNotEnabledNoServices
            case (true, false):
                throw SelectServiceError.errorNotEnabled
            case (false, true):
                throw SelectServiceError.errorNoServices
            default: break
            }
            
            let all: [WidgetCategory] = serviceHandler.listAll(search: nil, exclude: [])
            let sections = all.map({ category -> ItemSection<ServiceAppEntity> in
                let services: [Item] = category.services.map({ service in
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
                    let id = "\(service.serviceID)#\(UUID().uuidString)"
                    return Item(
                        ServiceAppEntity(id: id, displayString: service.serviceName, secret: service.serviceID),
                        title: LocalizedStringResource(stringLiteral: service.serviceName),
                        subtitle: subtitle,
                        image: image
                    )
                })
                let categoryName: LocalizedStringResource = {
                    if let categoryName = category.categoryName {
                        return LocalizedStringResource(stringLiteral: categoryName)
                    }
                    return LocalizedStringResource(stringLiteral: "Main category") // TODO: Add proper string
                }()
                return ItemSection(categoryName, items: services)
            })
            return ItemCollection(promptLabel: LocalizedStringResource("widget_select_service"), sections: sections)
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
    
    //    private func provideServiceOptionsCollection(
    //        for intent: SelectServiceIntent,
    //        with completion: @escaping (INObjectCollection<Service>?, Error?) -> Void
    //    ) {
    //        switch (serviceHandler.hasServices(), protection.extensionsStorage.areWidgetsEnabled) {
    //        case (false, false):
    //            completion(nil, errorNotEnabledNoServices)
    //            return
    //        case (true, false):
    //            completion(nil, errorNotEnabled)
    //            return
    //        case (false, true):
    //            completion(nil, errorNoServices)
    //            return
    //        default: break
    //        }
    //
    //        let current: [String] = intent.service?.compactMap({ $0.secret }) ?? []
    //        let all: [WidgetCategory] = serviceHandler.listAll(search: nil, exclude: current)
    //        let sections = all.map({ category -> INObjectSection<Service> in
    //            let services: [Service] = category.services.map({
    //                let icon = $0.icon
    //                let id = "\($0.serviceID)\(UUID().uuidString)" // in case user selects twice the same service
    //                let service = Service(
    //                    identifier: id,
    //                    display: $0.serviceName,
    //                    subtitle: $0.serviceInfo,
    //                    image: INImage(uiImage: icon)
    //                )
    //                service.secret = $0.serviceID
    //                return service
    //            })
    //            return INObjectSection(title: category.categoryName, items: services)
    //        })
    //        let collection = INObjectCollection(sections: sections)
    //        completion(collection, nil)
    //    }
}


//struct CreateBookIntent: AppIntent {
//    @Parameter(title: "Author Name", optionsProvider: AuthorNamesOptionsProvider())
//    var authorName: String
//
//
//    struct AuthorNamesOptionsProvider: DynamicOptionsProvider {
//        func results() async throws -> ItemCollection<Int> {
//            ItemCollection {
//                ItemSection("Italian Authors") {
//                    "Dante Alighieri"
//                    "Alessandro Manzoni"
//                }
//                ItemSection("Russian Authors") {
//                    "Anton Chekhov"
//                    "Fyodor Dostoevsky"
//                }
//            }
//        }
//    }
//}


enum SelectServiceError: Error, CustomLocalizedStringResourceConvertible {
    case errorNotEnabled
    case errorNotEnabledNoServices
    case errorNoServices
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .errorNotEnabled: LocalizedStringResource("widget_not_enabled")
        case .errorNotEnabledNoServices: LocalizedStringResource("widget_not_enabled_no_services")
        case .errorNoServices: LocalizedStringResource("widget_no_services")
        }
    }
}
