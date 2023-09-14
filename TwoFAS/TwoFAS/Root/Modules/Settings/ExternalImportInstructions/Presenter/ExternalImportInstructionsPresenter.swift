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
import SwiftUI

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
        case .aegis, .raivo, .andOTP, .twofas: return false
        case .googleAuth, .lastPass: return true
        }
    }
    
    var sourceLogo: Image {
        switch service {
        case .aegis: return Asset.externalImportAegis.swiftUIImage
        case .raivo: return Asset.externalImportRavio.swiftUIImage
        case .andOTP: return Asset.externalImportAndOTP.swiftUIImage
        case .lastPass: return Asset.externalImportLastPass.swiftUIImage
        case .googleAuth: return Asset.externalImportGoogleAuth.swiftUIImage
        case .twofas: return Asset.externalImportGoogleAuth.swiftUIImage // Not used here
        }
    }
    
    var sourceName: String {
        switch service {
        case .aegis: return T.Externalimport.infoAegisTitle
        case .raivo: return T.Externalimport.infoRaivoTitle
        case .lastPass: return T.Externalimport.infoLastpassTitle
        case .googleAuth: return T.Externalimport.infoGoogleAuthenticatorTitle
        case .andOTP: return T.Externalimport.infoAndotpTitle
        case .twofas: return T.Commons._2fasToolbar // Not used here
        }
    }
    
    var info: String {
        switch service {
        case .aegis: return T.Externalimport.aegisMsg
        case .raivo: return T.Externalimport.raivoMsg
        case .lastPass: return T.Externalimport.lastpassMsg
        case .googleAuth: return T.Introduction.googleAuthenticatorImportProcess
        case .andOTP: return T.Externalimport.andotpMsg
        case .twofas: return ""  // Not used here
        }
    }
    
    var actionName: String {
        switch service {
        case .aegis, .raivo, .lastPass, .andOTP: return  T.Externalimport.chooseJsonCta
        case .googleAuth: return T.Commons.scanQrCode
        case .twofas: return "" // Not used here
        }
    }
    
    var secondaryActionName: String? {
        switch service {
        case .aegis, .raivo, .twofas, .andOTP: return nil
        case .lastPass: return T.Commons.scanQrCode
        case .googleAuth: return T.Introduction.chooseQrCode
        }
    }
    
    // MARK: - Handlers
    
    func handleAction() {
        switch service {
        case .aegis, .raivo, .lastPass, .twofas, .andOTP: flowController.toOpenFile()
        case .googleAuth: flowController.toCamera()
        }
    }
    
    func handleCancel() {
        flowController.close()
    }
    
    func handleSecondaryAction() {
        switch service {
        case .aegis, .raivo, .twofas, .andOTP: break
        case .lastPass: flowController.toCamera()
        case .googleAuth: flowController.toGallery()
        }
    }
}
