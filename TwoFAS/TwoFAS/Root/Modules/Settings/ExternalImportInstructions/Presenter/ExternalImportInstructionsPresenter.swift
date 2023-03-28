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
    private let service: ExternalImportInstructionsService
    
    init(flowController: ExternalImportInstructionsFlowControlling, service: ExternalImportInstructionsService) {
        self.flowController = flowController
        self.service = service
    }
}

extension ExternalImportInstructionsPresenter {
    var hasSecondaryAction: Bool {
        switch service {
        case .aegis, .raivo, .lastPass: return false
        case .googleAuth: return true
        }
    }
    
    var sourceLogo: Image {
        switch service {
        case .aegis: return Asset.externalImportAegis.swiftUIImage
        case .raivo: return Asset.externalImportRavio.swiftUIImage
        case .lastPass: return Asset.externalImportLastPass.swiftUIImage
        case .googleAuth: return Asset.externalImportGoogleAuth.swiftUIImage
        }
    }
    
    var sourceName: String {
        switch service {
        case .aegis: return T.externalimportAegis
        case .raivo: return T.externalimportRaivo
        case .lastPass: return T.externalimportLastpass
        case .googleAuth: return T.externalimportGoogleAuthenticator
        }
    }
    
    var info: String {
        switch service {
        case .aegis: return T.Externalimport.aegisMsg
        case .raivo: return T.Externalimport.raivoMsg
        case .lastPass: return T.Externalimport.lastpassMsg
        case .googleAuth: return T.Introduction.googleAuthenticatorImportProcess
        }
    }
    
    var actionName: String {
        switch service {
        case .aegis, .raivo, .lastPass: return  T.Externalimport.chooseJsonCta
        case .googleAuth: return T.Commons.scanQrCode
        }
    }
    
    var secondaryActionName: String? {
        switch service {
        case .aegis, .raivo, .lastPass: return nil
        case .googleAuth: return T.Introduction.chooseQrCode
        }
    }
    
    // MARK: - Handlers
    
    func handleAction() {
        switch service {
        case .aegis, .raivo, .lastPass: flowController.toOpenFile()
        case .googleAuth: flowController.toCamera()
        }
    }
    
    func handleCancel() {
        flowController.close()
    }
    
    func handleSecondaryAction() {
        switch service {
        case .aegis, .raivo, .lastPass: break
        case .googleAuth: flowController.toGallery()
        }
    }
}
