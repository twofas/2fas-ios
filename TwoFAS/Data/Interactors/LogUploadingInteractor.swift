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
import Sync
import Storage
import Common

public enum LogUploadingInteractorError: Error {
    case notExists
    case expired
    case noInternet
    case server
}

public protocol LogUploadingInteracting: AnyObject {
    func upload(
        _ logs: String,
        auditID: String,
        completion: @escaping (Result<Void, LogUploadingInteractorError>) -> Void
    )
    func generateLogs() -> String
    func summarize() -> String
}

final class LogUploadingInteractor {
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension LogUploadingInteractor: LogUploadingInteracting {
    func upload(
        _ logs: String,
        auditID: String,
        completion: @escaping (Result<Void, LogUploadingInteractorError>) -> Void
    ) {
        mainRepository.uploadLogs(logs, auditID: auditID) { result in
            switch result {
            case .success:
                completion(.success(Void()))
            case .failure(let error):
                switch error {
                case .noInternet: completion(.failure(.noInternet))
                case .connection(let connectionError):
                    switch connectionError {
                    case .serverError, .parseError, .otherError: completion(.failure(.server))
                    case .serverHTTPError(let status, _):
                        if status == 404 {
                            completion(.failure(.notExists))
                            return
                        }
                        if status == 410 {
                            completion(.failure(.expired))
                            return
                        }
                        completion(.failure(.server))
                    }
                }
            }
        }
    }
    
    func generateLogs() -> String {
        summarize() + mainRepository.generateLogs()
    }
    
    // intentionaly not translated
    func summarize() -> String {
        var summary: [String] = []
        
        let formatter = ShortDateTimeFormatter.shared
        let date = formatter.string(from: Date()) ?? ""
        summary.append("\n\n\n-------------- Generated: \(date) ----------------")
        summary.append("iOS: \(mainRepository.systemVersion)")
        
        if let version = mainRepository.appVersion {
            summary.append("App version: \(version)")
        }
        
        let device = mainRepository.currentDevice
        summary.append("Device: \(device)")
        
        // swiftlint:disable line_length
        summary.append("Disk size: \(mainRepository.totalDiskSpace), used: \(mainRepository.usedDiskSpace), free: \(mainRepository.freeDiskSpace)")
        summary.append("Cloud sync state: \(mainRepository.cloudCurrentState.readableValue)")
        
        summary.append("PIN: \(mainRepository.isPINSet.readableValue)")
        summary.append("Biometry: \(mainRepository.isBiometryEnabled.readableValue)")
        
        summary.append("Tokens count: \(mainRepository.countServices())")
        
        return summary.joined(separator: "\n") + "\n\n\n------------------------------\n\n\n"
        // swiftlint:enable line_length
    }
}

private extension Bool {
    var readableValue: String {
        if self {
            return "yes"
        }
        return "no"
    }
}

private extension CloudState {
    var readableValue: String {
        switch self {
        case .unknown: return "unknown"
        case .disabledNotAvailable(let reason): return "off, not available, reason: \(reason.readableValue)"
        case .disabledAvailable: return "off, available"
        case .enabled(let sync): return "enabled, \(sync.readableValue)"
        }
    }
}

private extension CloudState.Sync {
    var readableValue: String {
        switch self {
        case .synced: return "synced"
        case .syncing: return "syncing"
        }
    }
}

private extension CloudState.NotAvailableReason {
    var readableValue: String {
        switch self {
        case .overQuota: return "over quota"
        case .disabledByUser: return "disabled by user"
        case .error(let error): return "error: \(String(describing: error))"
        case .other: return "other"
        case .incorrectService(let serviceName): return "incorrect service named: \(serviceName)"
        case .useriCloudProblem: return "User has iCloud problem"
        case .newerVersion: return "Newer version of cloud is available"
        case .cloudEncrypted: return "Cloud is encrypted"
        }
    }
}
