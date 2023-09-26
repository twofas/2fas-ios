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

protocol MainModuleInteracting: AnyObject {
    var secretSyncError: ((String) -> Void)? { get set }
    
    func initialize()
    func checkForImport() -> URL?
    func clearImportedFileURL()
    
    // MARK: - New app version
    func checkForNewAppVersion(completion: @escaping (URL?) -> Void)
    func skipAppVersion()
}

final class MainModuleInteractor {
    var secretSyncError: ((String) -> Void)?
    
    private let logUploadingInteractor: LogUploadingInteracting
    private let cloudBackupStateInteractor: CloudBackupStateInteracting
    private let fileInteractor: FileInteracting
    private let newVersionInteractor: NewVersionInteracting
    private let networkStatusInteractor: NetworkStatusInteracting
    private let appInfoInteractor: AppInfoInteracting
    
    init(
        logUploadingInteractor: LogUploadingInteracting,
        viewPathInteractor: ViewPathIteracting,
        cloudBackupStateInteractor: CloudBackupStateInteracting,
        fileInteractor: FileInteracting,
        newVersionInteractor: NewVersionInteracting,
        networkStatusInteractor: NetworkStatusInteracting,
        appInfoInteractor: AppInfoInteracting
    ) {
        self.logUploadingInteractor = logUploadingInteractor
        self.cloudBackupStateInteractor = cloudBackupStateInteractor
        self.fileInteractor = fileInteractor
        self.newVersionInteractor = newVersionInteractor
        self.networkStatusInteractor = networkStatusInteractor
        self.appInfoInteractor = appInfoInteractor

        cloudBackupStateInteractor.secretSyncError = { [weak self] in self?.secretSyncError?($0) }
    }
}

extension MainModuleInteractor: MainModuleInteracting {
    func initialize() {
        networkStatusInteractor.installListeners()
        DebugLog(logUploadingInteractor.summarize())
        appInfoInteractor.markDateOfFirstRunIfNeeded()
    }
    
    func checkForImport() -> URL? {
        fileInteractor.url
    }
    
    func clearImportedFileURL() {
        fileInteractor.markAsHandled()
    }
    
    // MARK: - New app version
    
    func checkForNewAppVersion(completion: @escaping (URL?) -> Void) {
        newVersionInteractor.checkForNewVersion { [weak self] newVersionAvailable in
            guard let appStoreURL = self?.newVersionInteractor.appStoreURL, newVersionAvailable else {
                completion(nil)
                return
            }
            completion(appStoreURL)
        }
    }
    
    func skipAppVersion() {
        newVersionInteractor.userSkippedVersion()
    }
}
