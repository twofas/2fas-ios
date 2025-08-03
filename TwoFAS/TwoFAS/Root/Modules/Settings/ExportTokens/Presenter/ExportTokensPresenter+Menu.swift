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

struct ExportTokensSection: TableViewSection {
    let title: String
    var cells: [ExportTokensCell]
    let footer: String
}

struct ExportTokensCell: Hashable {
    enum Action: Hashable {
        case copyToClipboard
        case saveOTPAuthFile
        case exportQRCodes
    }
    
    let icon: UIImage?
    let title: String
    let action: Action
}

extension ExportTokensPresenter {
    func buildMenu() -> [ExportTokensSection] {
        [
            ExportTokensSection(
                title: "Export Options",
                cells: [
                    .init(
                        icon: UIImage(systemName: "doc.on.clipboard.fill")!,
                        title: "Copy to clipboard",
                        action: .copyToClipboard
                    ),
                    .init(
                        icon: UIImage(systemName: "doc.fill")!,
                        title: "Save OTPAuth file",
                        action: .saveOTPAuthFile
                    ),
                    .init(
                        icon: UIImage(systemName: "qrcode")!,
                        title: "Export QR Codes",
                        action: .exportQRCodes
                    )
                ],
                footer: "Choose how you would like to export your tokens. You can copy them to clipboard, save as an OTPAuth file, or export as QR codes."
            )
        ]
    }
}
