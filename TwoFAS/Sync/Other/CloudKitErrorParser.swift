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
import CloudKit
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

enum CloudKitAction: Equatable {
    enum Reason: Equatable {
        case iCloudProblem
        case quotaExceeded
        case userDisablediCloud
        case notLoggedIn
    }
    case retry(after: TimeInterval)
    case purgeAndRetry(after: TimeInterval)
    case resetAndRetry(after: TimeInterval)
    case stop(reason: Reason)
    
    var weight: Int {
        switch self {
        case .retry: return 1
        case .purgeAndRetry: return 2
        case .resetAndRetry: return 3
        case .stop: return 4
        }
    }
    
    var shoudStop: Bool {
        switch self {
        case .stop: true
        default: false
        }
    }
}

extension Collection where Element == CloudKitAction {
    var sortedByImportance: [CloudKitAction] {
        sorted(by: { $0.weight < $1.weight })
    }
}

// swiftlint:disable legacy_objc_type
final class CloudKitErrorParser {
    private let minSecondsToRetry: TimeInterval = 2
    private let maxSecondsToRetry: TimeInterval = 1800
    private let midSecondsToRetry: TimeInterval = 600
    
    fileprivate func parseErrorCode(_ errorCode: CKError.Code, retryIn: TimeInterval?) -> CloudKitAction? {
        switch errorCode {
        case .internalError, .zoneNotFound, .serverResponseLost:
            return .purgeAndRetry(after: minSecondsToRetry)
            
        case .networkUnavailable,
                .networkFailure,
                .serviceUnavailable,
                .requestRateLimited,
                .limitExceeded,
                .zoneBusy:
            let seconds = {
                if let retryIn {
                    return retryIn
                }
                return TimeInterval.random(in: minSecondsToRetry...maxSecondsToRetry)
            }()
            return .purgeAndRetry(after: seconds)
            
        case .operationCancelled:
            Log("Operation cancelled!", module: .cloudSync)
            return nil
            
        case .changeTokenExpired, .serverRecordChanged:
            return .purgeAndRetry(after: minSecondsToRetry)
            
        case .unknownItem, .constraintViolation, .invalidArguments:
            return .resetAndRetry(after: minSecondsToRetry)
            
        case .batchRequestFailed:
            return nil
            
        case .missingEntitlement,
                .serverRejectedRequest,
                .managedAccountRestricted,
                .badContainer,
                .incompatibleVersion,
                .badDatabase,
                .accountTemporarilyUnavailable:
            return .stop(reason: .iCloudProblem)
            
        case .quotaExceeded:
            return .stop(reason: .quotaExceeded)
            
        case .permissionFailure, .notAuthenticated:
            return .stop(reason: .notLoggedIn)
            
        case .userDeletedZone:
            return .stop(reason: .userDisablediCloud)
            
        default:
            Log("No handler for error code \(errorCode)", module: .cloudSync)
            return nil
        }
    }
    
    func handle(error: NSError) -> CloudKitAction? {
        let userInfo = error.userInfo
        
        Log("Handling error \(error)", module: .cloudSync)
        
        if error.isOffline {
            Log("iCloud is offline, retrying in \(midSecondsToRetry)s", module: .cloudSync)
            return .retry(after: midSecondsToRetry)
        }
        
        guard var errorCode = CKError.Code(rawValue: error.code) else {
            Log("Can't get error code from \(error). Purging and retrying", module: .cloudSync)
            return .purgeAndRetry(after: minSecondsToRetry)
        }
        
        let retryIn: TimeInterval? = {
            guard let retry = userInfo[CKErrorRetryAfterKey] as? NSNumber else { return nil }
            return TimeInterval(retry.doubleValue)
        }()
        
        Log("Error code: \(errorCode), retry in: \(String(describing: retryIn))", module: .cloudSync)
        
        if let ckError = error as? CKError,
           case .partialFailure = ckError.code,
           let partials = ckError.partialErrorsByItemID {
            if partials.values.contains(where: { ($0 as? CKError)?.code == .quotaExceeded }) {
                return .stop(reason: .quotaExceeded)
            }
            if let first = partials.values.first as? CKError  {
                errorCode = first.code
            }
        }
        
        return parseErrorCode(errorCode, retryIn: retryIn)
    }
}
// swiftlint:enable legacy_objc_type

private extension NSError {
    var isOffline: Bool {
        code == -1009
    }
}
