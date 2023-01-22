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
import Storage
import Protection
import Token
import Sync
import TimeVerification

struct MainCoordinatorDependencies {
    let service: ServiceHandler
    let codeStorage: CodeStorage
    let biometricAuth: BiometricAuth
    let timerHandler: TimerHandler
    let security: SecurityProtocol
    let rootViewController: ContainerViewController
    let timeVerificationController: TimeVerificationControllerDifference
    let accessTokenStorage: TokenStorageVerify
    let viewPath: ViewPathType
    let sync: CloudHandlerType
    let fileHandler: FileOpenHandler
    let initializeSyncOnFirstRun: InitializeSyncOnFirstRun
    let categoryHandler: CategoryHandler
    let sectionHandler: SectionHandler
    let extensionStorage: ExtensionsStorage
}
