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

public enum CloudCurrentState {
    public enum NotAvailableReason {
        case overQuota
        case disabledByUser
        case other
    }
    
    public enum Sync {
        case syncing // in progress
        case synced // all done
        case resyncing // cleanup was needed
        case changesAwaiting
        case error(error: NSError)
    }
    
    case unknown
    case disabledNotAvailable(reason: NotAvailableReason)
    case disabledAvailable
    case enabled(sync: Sync)
}

public final class CloudHandler {
    public typealias StateChange = (CloudCurrentState) -> Void
    public var stateChange: StateChange?
    
    private let cloudAvailbility: CloudAvailbility
    
    private var currentCloudState: CloudCurrentState = .unknown {
        didSet {
            stateChange?(currentCloudState)
        }
    }
    
    init(cloudAvailbility: CloudAvailbility) {
        self.cloudAvailbility = cloudAvailbility
        cloudAvailbility.availbilityCheckResult = { [weak self] resultStatus in
            self?.availbilityCheckResult(resultStatus)
        }
    }
    
    public var currentState: CloudCurrentState { currentCloudState }
    
    public func checkState() {
        cloudAvailbility.checkAvailbility()
    }
    
    public func synchronize() {}
    
    public func enable() {}
    
    public func disable() {}
    
    // MARK: - Private
    
    private func availbilityCheckResult(_ resultStatus: CloudAvailbilityStatus) {}
    
    private func setEnabled() {}
    
    private func setDisabled() {}
    
    private var isEnabled: Bool {
        false
    }
}
