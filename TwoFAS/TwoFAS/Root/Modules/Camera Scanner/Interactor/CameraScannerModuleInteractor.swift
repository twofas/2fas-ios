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
import CodeSupport
import Common
import Data

protocol CameraScannerModuleInteracting: AnyObject {
    var serviceWasCreated: ((ServiceData) -> Void)? { get set }
    var shouldRename: ((String, String) -> Void)? { get set }
    var wasUserAskedAboutPush: Bool { get }
    
    func addCode(_ code: Code)
    func codeExists(_ code: Code) -> Bool
    func filterImportableCodes(_ codes: [Code]) -> [Code] 
    func addCodes(_ codes: [Code])
    func serviceDescription(for code: Code) -> String?
    func renameService(newName: String, secret: String)
    func cancelRenaming(secret: String)
}

final class CameraScannerModuleInteractor {
    private let newCodeInteractor: NewCodeInteracting
    private let pushNotificationPermission: PushNotificationRegistrationInteracting
    
    var serviceWasCreated: ((ServiceData) -> Void)?
    var shouldRename: ((String, String) -> Void)?
    
    init(newCodeInteractor: NewCodeInteracting, pushNotificationPermission: PushNotificationRegistrationInteracting) {
        self.newCodeInteractor = newCodeInteractor
        self.pushNotificationPermission = pushNotificationPermission
        newCodeInteractor.serviceWasCreated = { [weak self] in self?.serviceWasCreated?($0) }
        newCodeInteractor.shouldRename = { [weak self] in self?.shouldRename?($0, $1) }
    }
}

extension CameraScannerModuleInteractor: CameraScannerModuleInteracting {
    var wasUserAskedAboutPush: Bool {
        pushNotificationPermission.wasUserAsked
    }
    
    func addCode(_ code: Code) {
        newCodeInteractor.addCode(code)
    }
    
    func codeExists(_ code: Code) -> Bool {
        newCodeInteractor.codeExists(code)
    }
    
    func filterImportableCodes(_ codes: [Code]) -> [Code] {
        newCodeInteractor.filterImportableCodes(codes)
    }
    
    func addCodes(_ codes: [Code]) {
        newCodeInteractor.addCodes(codes)
    }
    
    func serviceDescription(for code: Code) -> String? {
        newCodeInteractor.service(for: code.secret)?.summarizeDescription
    }
    
    func renameService(newName: String, secret: String) {
        newCodeInteractor.renameService(newName: newName, secret: secret)
    }
    
    func cancelRenaming(secret: String) {
        newCodeInteractor.cancelRenaming(secret: secret)
    }
}
