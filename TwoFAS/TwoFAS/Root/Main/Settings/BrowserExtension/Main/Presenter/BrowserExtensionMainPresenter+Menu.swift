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

struct BrowserExtensionMainMenuSection: TableViewSection {
    let title: String
    var cells: [BrowserExtensionMainMenuCell]
    let footer: String?
}

struct BrowserExtensionMainMenuCell: Hashable {
    enum Kind: Hashable {
        case service(name: String, date: String, id: String)
        case addNew
        case nickname(String)
    }
    let kind: Kind
}

extension BrowserExtensionMainPresenter {
    func buildMenu() -> [BrowserExtensionMainMenuSection] {
        var cells: [BrowserExtensionMainMenuSection] = []
        
        var services: [BrowserExtensionMainMenuCell] = interactor.listPairedServices().map { service in
            BrowserExtensionMainMenuCell(
                kind: .service(name: service.name, date: service.pairingDateFormatted, id: service.extensionID)
            )
        }
        services.append(.init(kind: .addNew))
        let servicesSection = BrowserExtensionMainMenuSection(
            title: T.Browser.pairedDevicesBrowserTitle,
            cells: services,
            footer: nil
        )
        
        cells.append(servicesSection)
        
        let nickname = interactor.deviceNickname
        let deviceNameSection = BrowserExtensionMainMenuSection(
            title: T.Browser.thisDeviceName,
            cells: [.init(kind: .nickname(nickname))],
            footer: T.Browser.thisDeviceFooter
        )
        
        cells.append(deviceNameSection)
        
        return cells
    }
}
