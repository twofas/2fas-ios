//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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
import Common

enum BackupManageEncryptionExportError: Error {
    case noKeys
    case fileWriteError(Error)
}

enum BackupManageEncryptionImportError: Error {
    case cannotOpenFile
    case cannotParseFile
}


protocol BackupManageEncryptionModuleInteracting: AnyObject {
    var isSyncing: Bool { get }
    var reload: Callback? { get set }
    var canDelete: Bool { get }
    var isCloudBackupSynced: Bool { get }
    var encryptionTypeIsUser: Bool { get }
    func exportKeys(completion: @escaping (Result<URL, BackupManageEncryptionExportError>) -> Void)
    func importKeys(
        url: URL,
        password: String?,
        completion: @escaping (Result<Void, BackupManageEncryptionImportError>) -> Void
    )
}

final class BackupManageEncryptionModuleInteractor {
    private let syncMigrationInteractor: SyncMigrationInteracting
    private let cloudBackup: CloudBackupStateInteracting
    private let notificationCenter: NotificationCenter
    private let filenameKeys = "twofas_keys_"
    
    var reload: Callback?
    
    init(syncMigrationInteractor: SyncMigrationInteracting, cloudBackup: CloudBackupStateInteracting) {
        self.syncMigrationInteractor = syncMigrationInteractor
        self.cloudBackup = cloudBackup
        notificationCenter = .default
        notificationCenter.addObserver(
            self,
            selector: #selector(syncStateChanged),
            name: .syncStateChanged,
            object: nil
        )
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}

extension BackupManageEncryptionModuleInteractor: BackupManageEncryptionModuleInteracting {
    var isSyncing: Bool {
        syncMigrationInteractor.currentCloudState == .enabled(sync: .syncing)
    }
    
    var canDelete: Bool {
        cloudBackup.canDelete
    }
    
    var isCloudBackupSynced: Bool {
        cloudBackup.isCloudBackupSynced
    }
    
    var encryptionTypeIsUser: Bool {
        cloudBackup.encryptionTypeIsUser
    }
    
    func exportKeys(completion: @escaping (Result<URL, BackupManageEncryptionExportError>) -> Void) {
        guard let keys = cloudBackup.exportKeys(),
              let fileContents = cloudBackup.packKeys(salt: keys.salt, systemKey: keys.systemKey)
        else {
            completion(.failure(.noKeys))
            return
        }
        
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let filename = "\(filenameKeys)\(Date.timeIntervalSinceReferenceDate)"
        let fileURL = URL(fileURLWithPath: tempDirectory.appendingPathComponent(filename).path())
        
        do {
            try fileContents.write(to: fileURL, options: .atomic)
        } catch {
            Log("BackupManageEncryptionModuleInteractor: Failed to create temporary file \(filename): \(error)")
            let errorCode = (error as NSError).code
            let domain = (error as NSError).domain
            Log("BackupManageEncryptionModuleInteractor: Error details - code: \(errorCode), domain: \(domain)")
            completion(.failure(.fileWriteError(error)))
            return
        }
        
        completion(.success(fileURL))
    }
    
    func importKeys(
        url: URL,
        password: String?,
        completion: @escaping (Result<Void, BackupManageEncryptionImportError>) -> Void
    ) {
        guard let data = try? Data(contentsOf: url) else {
            completion(.failure(.cannotOpenFile))
            return
        }
        guard let keys = cloudBackup.unpackKeys(from: data) else {
            completion(.failure(.cannotParseFile))
            return
        }
        cloudBackup.importKeys(salt: keys.salt, systemKey: keys.systemKey, password: password)
        completion(.success(()))
    }
}

private extension BackupManageEncryptionModuleInteractor {
    @objc
    func syncStateChanged() {
        reload?()
    }
}
