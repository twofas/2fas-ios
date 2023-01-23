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

final class MainModuleInteractor {
    var secretSyncError: ((String) -> Void)?
    
    private let logUploadingInteractor: LogUploadingInteracting
    private let viewPathInteractor: ViewPathIteracting
    private let cloudBackupStateInteractor: CloudBackupStateInteracting
    private let fileInteractor: FileInteracting
    
    init(
        logUploadingInteractor: LogUploadingInteracting,
        viewPathInteractor: ViewPathIteracting,
        cloudBackupStateInteractor: CloudBackupStateInteracting,
        fileInteractor: FileInteracting
    ) {
        self.logUploadingInteractor = logUploadingInteractor
        self.viewPathInteractor = viewPathInteractor
        self.cloudBackupStateInteractor = cloudBackupStateInteractor
        self.fileInteractor = fileInteractor

        cloudBackupStateInteractor.secretSyncError = { [weak self] in self?.secretSyncError?($0) }
    }
    
    func initialize() {
        DebugLog(logUploadingInteractor.summarize())
    }
    
    func checkForImport() -> URL? {
        fileInteractor.url
    }
    
    func clearImportedFileURL() {
        fileInteractor.markAsHandled()
    }
    
    func restoreViewPath() -> ViewPath? {
        viewPathInteractor.viewPath()
    }
    
    func setViewPath(_ viewPath: ViewPath) {
        viewPathInteractor.setViewPath(viewPath)
    }
}
