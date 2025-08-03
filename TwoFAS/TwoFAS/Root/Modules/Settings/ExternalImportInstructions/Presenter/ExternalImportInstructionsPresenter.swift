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

import SwiftUI
import Common

final class ExternalImportInstructionsPresenter {
    private let flowController: ExternalImportInstructionsFlowControlling
    private let service: ExternalImportService
    
    init(flowController: ExternalImportInstructionsFlowControlling, service: ExternalImportService) {
        self.flowController = flowController
        self.service = service
    }
}

extension ExternalImportInstructionsPresenter {
    var hasSecondaryAction: Bool {
        switch service {
        case .aegis, .raivo, .andOTP, .twofas, .authenticatorPro, .otpAuthFile, .clipboard: false
        case .googleAuth, .lastPass: true
        }
    }
    
    var sourceLogo: some View {
        switch service {
        case .aegis: AnyView(Asset.externalImportAegis.swiftUIImage)
        case .raivo: AnyView(Asset.externalImportRavio.swiftUIImage)
        case .andOTP: AnyView(Asset.externalImportAndOTP.swiftUIImage)
        case .lastPass: AnyView(Asset.externalImportLastPass.swiftUIImage)
        case .googleAuth: AnyView(Asset.externalImportGoogleAuth.swiftUIImage)
        case .authenticatorPro: AnyView(Asset.externalImportAuthenticatorPro.swiftUIImage)
        case .twofas: AnyView(Asset.externalImportGoogleAuth.swiftUIImage) // Not used here
        case .otpAuthFile:
                AnyView(
                    Image(systemName: "doc.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color(ThemeColor.theme))
                        .frame(width: 60, height: 60)
                )
        case .clipboard:
            AnyView(
                Image(systemName: "list.clipboard.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color(ThemeColor.theme))
                    .frame(width: 60, height: 60)
            )
        }
    }
    
    var sourceName: String {
        switch service {
        case .aegis: T.Externalimport.infoAegisTitle
        case .raivo: T.Externalimport.infoRaivoTitle
        case .lastPass: T.Externalimport.infoLastpassTitle
        case .googleAuth: T.Externalimport.infoGoogleAuthenticatorTitle
        case .andOTP: T.Externalimport.infoAndotpTitle
        case .authenticatorPro: T.Externalimport.infoAuthenticatorproTitle
        case .otpAuthFile: "Import tokens from text file"
        case .clipboard: "Import tokens from clipboard"
        case .twofas: T.Commons._2fasToolbar // Not used here
        }
    }
    
    var info: String {
        switch service {
        case .aegis: T.Externalimport.aegisMsg
        case .raivo: T.Externalimport.raivoMsg
        case .lastPass: T.Externalimport.lastpassMsg
        case .googleAuth: T.Introduction.googleAuthenticatorImportProcess
        case .andOTP: T.Externalimport.andotpMsg
        case .authenticatorPro: T.Externalimport.authenticatorproMsg
        case .otpAuthFile: "Text file should contain a list of links starting with 'otpauth://'."
        case .clipboard: "Clipboard should contain a list of links starting with 'otpauth://'."
        case .twofas: ""  // Not used here
        }
    }
    
    var actionName: String {
        switch service {
        case .aegis, .raivo, .lastPass, .andOTP:  T.Externalimport.chooseJsonCta
        case .authenticatorPro, .otpAuthFile: T.Externalimport.chooseTxtCta
        case .googleAuth: T.Commons.scanQrCode
        case .twofas: "" // Not used here
        case .clipboard: "Read from Clipboard"
        }
    }
    
    var secondaryActionName: String? {
        switch service {
        case .aegis, .raivo, .twofas, .andOTP, .authenticatorPro, .otpAuthFile, .clipboard: nil
        case .lastPass: T.Commons.scanQrCode
        case .googleAuth: T.Introduction.chooseQrCode
        }
    }
    
    // MARK: - Handlers
    
    func handleAction() {
        switch service {
        case .aegis, .raivo, .lastPass, .twofas, .andOTP, .authenticatorPro, .otpAuthFile:
            flowController.toOpenFile(service: service)
        case .googleAuth: flowController.toCamera()
        case .clipboard: flowController.toFromClipboard()
        }
    }
    
    func handleCancel() {
        flowController.close()
    }
    
    func handleSecondaryAction() {
        switch service {
        case .aegis, .raivo, .twofas, .andOTP, .authenticatorPro, .otpAuthFile, .clipboard: break
        case .lastPass: flowController.toCamera()
        case .googleAuth: flowController.toGallery()
        }
    }
}
