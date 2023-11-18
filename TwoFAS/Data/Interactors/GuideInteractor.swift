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

import UIKit
import Common
import CommonUIKit

public struct GuideDescription: Identifiable, Hashable {
    public static func == (lhs: GuideDescription, rhs: GuideDescription) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public struct Page: Identifiable {
        public var id: Int {
            pageNumber
        }
        public enum CTA {
            case manually(title: String, data: String?)
            case scanner(title: String)
            case next
        }
        
        public let pageNumber: Int
        public let image: ServiceGuideImage
        public let content: AttributedString
        public let cta: CTA
    }
    
    public struct MenuPosition: Identifiable, Hashable {
        public static func == (lhs: GuideDescription.MenuPosition, rhs: GuideDescription.MenuPosition) -> Bool {
            lhs.title == rhs.title
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(title)
        }
        
        public var id: String { title }
        public let title: String
        public let serviceName: String
        public let pages: [Page]
    }
    
   public let serviceName: String
   public let serviceIcon: UIImage
   public let header: String
   public let menuTitle: String
   public let menuPositions: [MenuPosition]
   public let id: UUID
}

public protocol GuideInteracting: AnyObject {
    func listAllAvailableGuides() -> [GuideDescription]
}

final class GuideInteractor {
    private var parsedData: [GuideDescription]?
    
    private let mainRepository: MainRepository
    private let serviceDefinitionInteractor: ServiceDefinitionInteracting
    
    init(mainRepository: MainRepository, serviceDefinitionInteractor: ServiceDefinitionInteracting) {
        self.mainRepository = mainRepository
        self.serviceDefinitionInteractor = serviceDefinitionInteractor
    }
}

extension GuideInteractor: GuideInteracting {
    func listAllAvailableGuides() -> [GuideDescription] {
        guard parsedData == nil else {
            return parsedData ?? []
        }
        parsedData = mainRepository.listAllGuides()
            .compactMap(mainRepository.loadGuideData)
            .compactMap(parseGuide)
        return parsedData ?? []
    }
}

private extension GuideInteractor {
    func parseGuide(_ guide: ServiceGuideDescription) -> GuideDescription? {
        let serviceName = guide.serviceName
        guard let iconTypeID = serviceDefinitionInteractor
            .serviceDefinition(using: guide.serviceId)?.iconTypeID else { return nil }
        let serviceIcon = ServiceIcon.for(iconTypeID: iconTypeID)
        let header = guide.flow.header
        let menuTitle = guide.flow.menu.title
        let menuPositions: [GuideDescription.MenuPosition] = guide.flow.menu.items.map({ item in
            GuideDescription.MenuPosition(
                title: item.name,
                serviceName: serviceName,
                pages: item.steps.enumerated().map({ index, step in
                    GuideDescription.Page(
                        pageNumber: index,
                        image: step.image,
                        content: (try? AttributedString(markdown: step.content)) ?? AttributedString(step.content),
                        cta: step.cta.pageCta
                    )
                })
            )
        })
        
        return .init(
            serviceName: serviceName,
            serviceIcon: serviceIcon,
            header: header,
            menuTitle: menuTitle,
            menuPositions: menuPositions,
            id: guide.serviceId
        )
    }
}

private extension ServiceGuideDescription.CTA? {
    var pageCta: GuideDescription.Page.CTA {
        guard let self else {
            return .next
        }
        switch self.action {
        case .manually:
            return .manually(title: self.name, data: self.data)
        case .scanner:
            return .scanner(title: self.name)
        }
    }
}
