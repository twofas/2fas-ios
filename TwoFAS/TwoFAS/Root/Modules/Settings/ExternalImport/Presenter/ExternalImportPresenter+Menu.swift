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

struct ExternalImportSection: TableViewSection {
    let title: String
    var cells: [ExternalImportCell]
    let footer: String
}

struct ExternalImportCell: Hashable {
    enum ExternalImportAction: Hashable {
        case aegis
        case raivo
        case lastPass
        case googleAuth
        case andOTP
        case authenticatorPro
    }
    
    let icon: UIImage
    let title: String
    let action: ExternalImportAction
}

extension ExternalImportPresenter {
    func buildMenu() -> [ExternalImportSection] {
        [
            ExternalImportSection(
                title: T.externalimportSelectApp,
                cells: [
                    .init(
                        icon: Asset.externalImportIconAegis.image,
                        title: T.externalimportAegis,
                        action: .aegis
                    ),
                    .init(
                        icon: Asset.externalImportIconRaivo.image,
                        title: T.externalimportRaivo,
                        action: .raivo
                    ),
                    .init(
                        icon: Asset.externalImportIconLastPass.image,
                        title: T.externalimportLastpass,
                        action: .lastPass
                    ),
                    .init(
                        icon: Asset.externalmportIconGoogleAuth.image,
                        title: T.externalimportGoogleAuthenticator,
                        action: .googleAuth
                    ),
                    .init(
                        icon: Asset.externalImportIconAndOTP.image,
                        title: T.externalimportAndotp,
                        action: .andOTP
                    ),
                    .init(
                        icon: Asset.externalImportIconAuthenticatorPro.image,
                        title: T.Externalimport.authenticatorpro,
                        action: .authenticatorPro
                    )
                ],
                footer: T.externalimportDescription
            )
        ]
    }
}
