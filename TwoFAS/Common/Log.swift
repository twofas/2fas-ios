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

public enum LogModule: Int, CaseIterable {
    case unknown = 0
    case storage = 1
    case cloudSync = 2
    case network = 3
    case counter = 4
    case serviceQueue = 5
    case camera = 6
    case protection = 7
    case ui = 8
    case appEvent = 9
    case interactor = 10
    case moduleInteractor = 11
}

public enum LogSeverity: Int, CaseIterable {
    case unknown = 0
    case error = 1
    case warning = 2
    case info = 3
    case trace = 4
}

var focusOn: [LogModule]?

public func Log(_ content: String, module: LogModule = .unknown, severity: LogSeverity = .unknown, save: Bool = true) {
    if let focusOn {
        guard focusOn.contains(module) else { return }
    }
    let date = Date()
    if save {
        LogStorage.store(content: content, timestamp: date, module: module, severity: severity)
    }
#if DEBUG
    LogPrinter.printLog(content: content, timestamp: date, module: module, severity: severity)
#endif
}

public func LogZoneStart() {
    LogStorage.markZoneStart()
}

public func LogZoneEnd() {
    LogStorage.markZoneEnd()
}

private extension LogModule {
    var suffix: String {
        switch self {
        case .unknown: return "💡"
        case .storage: return "💾"
        case .cloudSync: return "☁️"
        case .network: return "📡"
        case .counter: return "⏲"
        case .serviceQueue: return "🚦"
        case .camera: return "📷"
        case .protection: return "🔒"
        case .ui: return "🖼"
        case .appEvent: return "🧬"
        case .interactor: return "🔌"
        case .moduleInteractor: return "🌀"
        }
    }
}

private extension LogSeverity {
    var suffix: String {
        switch self {
        case .unknown: return "❔"
        case .error: return "❌"
        case .warning: return "⚠️"
        case .info: return "ℹ️"
        case .trace: return "💬"
        }
    }
}

public protocol LogStorageHandling: AnyObject {
    func store(content: String, timestamp: Date, module: Int, severity: Int)
    func markZoneStart()
    func markZoneEnd()
}

public enum LogPrinter {
    private static var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withFullDate, .withSpaceBetweenDateAndTime, .withTime, .withColonSeparatorInTime
        ]
        return formatter
    }()
    static func printLog(content: String, timestamp: Date, module: LogModule, severity: LogSeverity) {
        let formatted = format(content: content, timestamp: timestamp, module: module, severity: severity)
        print(formatted)
    }
    public static func format(content: String, timestamp: Date, module: LogModule, severity: LogSeverity) -> String {
        "\(dateFormatter.string(from: timestamp))\t\(severity.suffix)\(module.suffix)\t\(content)"
    }
}

public enum LogStorage {
    private static var storage: LogStorageHandling?
    
    public static func setStorage(_ logStorage: LogStorageHandling) {
        storage = logStorage
    }
    
    public static func markZoneStart() {
        storage?.markZoneStart()
    }
    
    public static func markZoneEnd() {
        storage?.markZoneEnd()
    }
    
    static func store(content: String, timestamp: Date, module: LogModule, severity: LogSeverity) {
        storage?.store(content: content, timestamp: timestamp, module: module.rawValue, severity: severity.rawValue)
    }
}
