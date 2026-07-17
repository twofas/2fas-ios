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
import Data

protocol AboutModuleInteracting: AnyObject {
    var currentAppVersion: String { get }
    var isCrashlyticsDisabled: Bool { get }
    func setCrashlyticsDisabled(_ disabled: Bool)
    func generateLogsFile() async -> URL?
    func removeLogsFile(at url: URL)
}

final class AboutModuleInteractor {
    private let appInfoInteractor: AppInfoInteracting
    private let registerDeviceInteractor: RegisterDeviceInteracting
    private let logGenerationInteractor: LogGenerationInteracting

    init(
        appInfoInteractor: AppInfoInteracting,
        registerDeviceInteractor: RegisterDeviceInteracting,
        logGenerationInteractor: LogGenerationInteracting
    ) {
        self.appInfoInteractor = appInfoInteractor
        self.registerDeviceInteractor = registerDeviceInteractor
        self.logGenerationInteractor = logGenerationInteractor
    }
}

extension AboutModuleInteractor: AboutModuleInteracting {
    var currentAppVersion: String {
        appInfoInteractor.currentAppVersion
    }
    
    var isCrashlyticsDisabled: Bool {
        registerDeviceInteractor.isCrashlyticsDisabled
    }
    
    func setCrashlyticsDisabled(_ disabled: Bool) {
        registerDeviceInteractor.setCrashlyticsDisabled(disabled)
    }

    func generateLogsFile() async -> URL? {
        switch await logGenerationInteractor.generateLogsFile() {
        case .success(let url): return url
        case .failure: return nil
        }
    }

    func removeLogsFile(at url: URL) {
        logGenerationInteractor.removeLogsFile(at: url)
    }
}
