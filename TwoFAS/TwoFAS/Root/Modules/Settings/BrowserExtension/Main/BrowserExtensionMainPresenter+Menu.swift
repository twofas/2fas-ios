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

struct BrowserExtensionMainSection: Identifiable {
    let id = UUID()
    let title: String
    var cells: [BrowserExtensionMainCell]
    let footer: String?
}

struct BrowserExtensionMainCell: Identifiable {
    enum Kind {
        case service(name: String, date: String, id: String)
        case addNew
        case nickname(String)
    }
    let id = UUID()
    let kind: Kind
}

extension BrowserExtensionMainPresenter {
    func buildMenu() -> [BrowserExtensionMainSection] {
        var sections: [BrowserExtensionMainSection] = []

        var services: [BrowserExtensionMainCell] = interactor.listPairedServices().map { service in
            BrowserExtensionMainCell(
                kind: .service(name: service.name, date: service.pairingDateFormatted, id: service.extensionID)
            )
        }
        services.append(.init(kind: .addNew))
        let servicesSection = BrowserExtensionMainSection(
            title: T.Browser.pairedDevicesBrowserTitle,
            cells: services,
            footer: nil
        )

        sections.append(servicesSection)

        let nickname = interactor.deviceNickname
        let deviceNameSection = BrowserExtensionMainSection(
            title: T.Browser.thisDeviceName,
            cells: [.init(kind: .nickname(nickname))],
            footer: T.Browser.thisDeviceFooter
        )

        sections.append(deviceNameSection)

        return sections
    }
}
