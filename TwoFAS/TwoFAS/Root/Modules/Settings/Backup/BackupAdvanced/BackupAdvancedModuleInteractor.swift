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

enum BackupAdvancedImportEncryptionType {
    case systemKey
    case customPassword
}

enum BackupAdvancedKeysExportError: Error {
    case noKeys
    case fileWriteError(Error)
}

enum BackupAdvancedKeysImportError: Error {
    case cannotOpenFile
    case cannotParseFile
}

protocol BackupAdvancedModuleInteracting: AnyObject {
    var isSyncing: Bool { get }
    var reload: Callback? { get set }
    func exportKeys(completion: @escaping (Result<URL, BackupAdvancedKeysExportError>) -> Void)
    func importKeys(
        url: URL,
        password: String?,
        completion: @escaping (Result<Void, BackupAdvancedKeysImportError>) -> Void
    )
}

final class BackupAdvancedModuleInteractor {
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

extension BackupAdvancedModuleInteractor: BackupAdvancedModuleInteracting {
    var isSyncing: Bool {
        syncMigrationInteractor.currentCloudState == .enabled(sync: .syncing)
    }

    func exportKeys(completion: @escaping (Result<URL, BackupAdvancedKeysExportError>) -> Void) {
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
            Log(
                "BackupAdvancedModuleInteractor: Failed to create temporary file \(filename): \(error)",
                module: .interactor,
                severity: .error
            )
            completion(.failure(.fileWriteError(error)))
            return
        }

        completion(.success(fileURL))
    }

    func importKeys(
        url: URL,
        password: String?,
        completion: @escaping (Result<Void, BackupAdvancedKeysImportError>) -> Void
    ) {
        let dataResult = readFileAt(url: url)
        guard case .success(let data) = dataResult else {
            if case .failure(let error) = dataResult {
                completion(.failure(error))
            }
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

private extension BackupAdvancedModuleInteractor {
    @objc
    func syncStateChanged() {
        reload?()
    }

    func readFileAt(url: URL) -> Result<Data, BackupAdvancedKeysImportError> {
        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() }
            var readData: Data?
            var readError: Error?
            let coordinator = NSFileCoordinator()
            coordinator.coordinate(readingItemAt: url, options: [.withoutChanges], error: nil) { coordinatedURL in
                do {
                    readData = try Data(contentsOf: coordinatedURL)
                } catch {
                    readError = error
                }
            }
            if let error = readError {
                Log(
                    "BackupAdvancedModuleInteractor: Cannot read file from iCloud/document provider: \(error)",
                    module: .interactor,
                    severity: .error
                )
                return .failure(.cannotOpenFile)
            }
            guard let data = readData else {
                return .failure(.cannotOpenFile)
            }
            return .success(data)
        }
        do {
            let data = try Data(contentsOf: url)
            return .success(data)
        } catch {
            Log("BackupAdvancedModuleInteractor: Cannot read file: \(error)", module: .interactor, severity: .error)
            return .failure(.cannotOpenFile)
        }
    }
}
