//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//

import Foundation
import Data
import Common

enum BackupManageKeysExportError: Error {
    case noKeys
    case fileWriteError(Error)
}

enum BackupManageKeysImportError: Error {
    case cannotOpenFile
    case cannotParseFile
}

protocol BackupManageKeysModuleInteracting: AnyObject {
    func exportKeys(completion: @escaping (Result<URL, BackupManageKeysExportError>) -> Void)
    func importKeys(
        url: URL,
        password: String?,
        completion: @escaping (Result<Void, BackupManageKeysImportError>) -> Void
    )
}

final class BackupManageKeysModuleInteractor {
    private let cloudBackup: CloudBackupStateInteracting
    private let filenameKeys = "twofas_keys_"
    
    init(cloudBackup: CloudBackupStateInteracting) {
        self.cloudBackup = cloudBackup
    }
}

extension BackupManageKeysModuleInteractor: BackupManageKeysModuleInteracting {
    func exportKeys(completion: @escaping (Result<URL, BackupManageKeysExportError>) -> Void) {
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
            Log("BackupManageKeysModuleInteractor: Failed to create temporary file \(filename): \(error)", module: .interactor, severity: .error)
            completion(.failure(.fileWriteError(error)))
            return
        }
        
        completion(.success(fileURL))
    }
    
    func importKeys(
        url: URL,
        password: String?,
        completion: @escaping (Result<Void, BackupManageKeysImportError>) -> Void
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

private extension BackupManageKeysModuleInteractor {
    func readFileAt(url: URL) -> Result<Data, BackupManageKeysImportError> {
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
                Log("BackupManageKeysModuleInteractor: Cannot read file from iCloud/document provider: \(error)", module: .interactor, severity: .error)
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
            Log("BackupManageKeysModuleInteractor: Cannot read file: \(error)", module: .interactor, severity: .error)
            return .failure(.cannotOpenFile)
        }
    }
}
