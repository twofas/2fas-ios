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
import Common

public enum LogGenerationInteractorError: Error {
    case fileWriteFailed
    case zipFailed
}

public protocol LogGenerationInteracting: AnyObject {
    func generateLogs() -> String
    func summarize() -> String
    func generateLogsFile() async -> Result<URL, LogGenerationInteractorError>
    func removeLogsFile(at url: URL)
}

final class LogGenerationInteractor {
    private let mainRepository: MainRepository
    private let compressionInteractor: CompressionInteracting
    private let fileManager = FileManager.default

    init(mainRepository: MainRepository, compressionInteractor: CompressionInteracting) {
        self.mainRepository = mainRepository
        self.compressionInteractor = compressionInteractor
    }
}

extension LogGenerationInteractor: LogGenerationInteracting {
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

    func generateLogsFile() async -> Result<URL, LogGenerationInteractorError> {
        let logs = generateLogs()

        let baseName = "2fas_logs_\(fileNameTimestamp())"
        let logFileURL = fileManager.temporaryDirectory.appendingPathComponent("\(baseName).log")

        do {
            try logs.write(to: logFileURL, atomically: true, encoding: .utf8)
        } catch {
            Log("LogGenerationInteractor: Can't write logs file. Error: \(error)")
            return .failure(.fileWriteFailed)
        }

        guard let zipURL = await compressionInteractor.zipFiles([logFileURL], into: baseName) else {
            try? fileManager.removeItem(at: logFileURL)
            return .failure(.zipFailed)
        }

        try? fileManager.removeItem(at: logFileURL)

        return .success(zipURL)
    }

    func removeLogsFile(at url: URL) {
        try? fileManager.removeItem(at: url)
    }
}

private extension LogGenerationInteractor {
    func fileNameTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: Date())
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
        case .cloudEncryptedUser: return "Cloud is encrypted using user password"
        case .cloudEncryptedSystem: return "Cloud is encrypted using system password"
        }
    }
}
