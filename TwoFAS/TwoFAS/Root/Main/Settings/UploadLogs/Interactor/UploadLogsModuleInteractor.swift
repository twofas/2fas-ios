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

protocol UploadLogsModuleInteracting: AnyObject {
    var passedUUID: UUID? { get }
    func sendLogs(for uuid: UUID, completion: @escaping ((Result<Void, UploadLogsModuleInteractorError>) -> Void))
}

enum UploadLogsModuleInteractorError: Error {
    case notExists
    case expired
    case noInternet
    case server
}

final class UploadLogsModuleInteractor {
    private let logUploadingInteractor: LogUploadingInteracting
    let passedUUID: UUID?
    
    init(logUploadingInteractor: LogUploadingInteracting, passedUUID: UUID? = nil) {
        self.logUploadingInteractor = logUploadingInteractor
        self.passedUUID = passedUUID
    }
}

extension UploadLogsModuleInteractor: UploadLogsModuleInteracting {
    func sendLogs(for uuid: UUID, completion: @escaping ((Result<Void, UploadLogsModuleInteractorError>) -> Void)) {
        let auditID = uuid.uuidString.lowercased()
        let logs = logUploadingInteractor.generateLogs()

        logUploadingInteractor.upload(logs, auditID: auditID) { result in
            switch result {
            case .success: completion(.success(Void()))
            case .failure(let failure):
                switch failure {
                case .expired:
                    completion(.failure(.expired))
                case .noInternet:
                    completion(.failure(.noInternet))
                case .notExists:
                    completion(.failure(.notExists))
                case .server:
                    completion(.failure(.server))
                }
            }
        }
    }
}
