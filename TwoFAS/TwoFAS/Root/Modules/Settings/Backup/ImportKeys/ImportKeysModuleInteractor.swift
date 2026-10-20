//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

enum ImportKeysEncryptionType {
    case systemKey
    case customPassword
}

enum ImportKeysError: Error {
    case cannotOpenFile
    case cannotParseFile
}

protocol ImportKeysModuleInteracting: AnyObject {
    func importKeys(
        url: URL,
        password: String?,
        completion: @escaping (Result<Void, ImportKeysError>) -> Void
    )
}

final class ImportKeysModuleInteractor {
    private let cloudBackup: CloudBackupStateInteracting

    init(cloudBackup: CloudBackupStateInteracting) {
        self.cloudBackup = cloudBackup
    }
}

extension ImportKeysModuleInteractor: ImportKeysModuleInteracting {
    func importKeys(
        url: URL,
        password: String?,
        completion: @escaping (Result<Void, ImportKeysError>) -> Void
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

private extension ImportKeysModuleInteractor {
    func readFileAt(url: URL) -> Result<Data, ImportKeysError> {
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
                    "ImportKeysModuleInteractor: Cannot read file from iCloud/document provider: \(error)",
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
            Log("ImportKeysModuleInteractor: Cannot read file: \(error)", module: .interactor, severity: .error)
            return .failure(.cannotOpenFile)
        }
    }
}
