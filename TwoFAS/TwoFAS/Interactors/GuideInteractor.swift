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

struct GuideDescription: Identifiable, Hashable {
    static func == (lhs: GuideDescription, rhs: GuideDescription) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    struct Page {
        enum CTA {
            case manually(title: String, data: String?)
            case scanner(title: String)
            case next
        }
        
        let image: UIImage
        let content: AttributedString
        let cta: CTA
    }
    
    struct MenuPosition {
        let title: String
        let pages: [Page]
    }
    
    let serviceName: String
    let serviceIcon: UIImage
    let header: String
    let menuTitle: String
    let menuPositions: [MenuPosition]
    let id: UUID
}

protocol GuideInteracting: AnyObject {
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
        guard let serviceIconTypeID = serviceDefinitionInteractor
            .serviceDefinition(using: guide.serviceId)?.iconTypeID else { return nil }
        let serviceIcon = serviceDefinitionInteractor.iconTypeID(for: serviceIconTypeID)
        let header = guide.flow.header
        let menuTitle = guide.flow.menu.title
        let menuPositions: [GuideDescription.MenuPosition] = guide.flow.menu.items.map({ item in
            GuideDescription.MenuPosition(
                title: item.name,
                pages: item.steps.map({ step in
                    GuideDescription.Page(
                        image: step.image.icon,
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

private extension ServiceGuideImage {
    var icon: UIImage {
        switch self {
        case .webMenu: Asset.guideWebMenu.image
        case .gears: Asset.guideGears.image
        case .webUrl: Asset.guideWebUrl.image
        case .twoFasType: Asset.guide2fasType.image
        case .appButton: Asset.guideAppButton.image
        case .pushNotification: Asset.guidePushNotification.image
        case .account: Asset.guideAccount.image
        case .retype: Asset.guideRetype.image
        case .webAccount1: Asset.guideWebAccount1.image
        case .webPhone: Asset.guideWebPhone.image
        case .phoneQR: Asset.guidePhoneQr.image
        case .webButton: Asset.guideWebButton.image
        case .secretKey: Asset.guideSecretKey.image
        }
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

//struct ServiceGuideDescription: Decodable {
//    enum Action: String, Decodable {
//        case manually = "open_manually"
//        case scanner = "open_scanner"
//    }
//    
//    struct CTA: Decodable {
//        let name: String
//        let action: Action
//        let data: String?
//    }
//    
//    struct Step: Decodable {
//        let image: ServiceGuideImage
//        let content: String
//        let cta: CTA?
//    }
//    
//    struct Item: Decodable {
//        let name: String
//        let steps: [Step]
//    }
//    
//    struct Menu: Decodable {
//        let title: String
//        let items: [Item]
//    }
//    
//    struct Flow: Decodable {
//        let header: String
//        let menu: Menu
//      //menu.title
        // menu.items
//    }
//    
//    let serviceName: String
//    let serviceId: UUID
//    let flow: Flow
//}
