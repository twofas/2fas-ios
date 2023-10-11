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

enum ServiceGuide: CaseIterable {
    case amazon
    case discord
    case epicGame
    case facebook
    case linkedin
    case rockstarGames
    case twitter
    case universal
    
    var fileName: String {
        switch self {
        case .amazon: "amazon"
        case .discord: "discord"
        case .epicGame: "epic_games"
        case .facebook: "facebook"
        case .linkedin: "linkedin"
        case .rockstarGames: "rockstar_games"
        case .twitter: "twitter"
        case .universal: "universal"
        }
    }
}

enum ServiceGuideImage: String, Decodable {
    case webMenu = "web_menu"
    case gears = "gears"
    case webUrl = "web_url"
    case twoFasType = "2fas_type"
    case appButton = "app_button"
    case pushNotification = "push_notification"
    case account = "account"
    case retype = "retype"
    case webAccount1 = "web_account_1"
    case webPhone = "web_phone"
    case phoneQR = "phone_qr"
    case webButton = "web_button"
    case secretKey = "secret_key"
}

struct ServiceGuideDescription: Decodable {
    enum Action: String, Decodable {
        case manually = "open_manually"
        case scanner = "open_scanner"
    }
    
    struct CTA: Decodable {
        let name: String
        let action: Action
        let data: String?
    }
    
    struct Step: Decodable {
        let image: ServiceGuideImage
        let content: String
        let cta: CTA?
    }
    
    struct Item: Decodable {
        let name: String
        let steps: [Step]
    }
    
    struct Menu: Decodable {
        let title: String
        let items: [Item]
    }
    
    struct Flow: Decodable {
        let header: String
        let menu: Menu
    }
    
    let serviceName: String
    let serviceId: UUID
    let flow: Flow
}
