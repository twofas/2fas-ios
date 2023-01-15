// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
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

// swiftlint:disable all

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

@testable import TwoFAS
@testable import Common














internal final class CloudBackupStateInteractingMock: CloudBackupStateInteracting {
    internal var isBackupEnabled: Bool {
        get { return underlyingIsBackupEnabled }
        set(value) { underlyingIsBackupEnabled = value }
    }
    internal var underlyingIsBackupEnabled: Bool!
    internal var isBackupAvailable: Bool {
        get { return underlyingIsBackupAvailable }
        set(value) { underlyingIsBackupAvailable = value }
    }
    internal var underlyingIsBackupAvailable: Bool!
    internal var error: CloudState.NotAvailableReason?
    internal var stateChanged: Callback?

    //MARK: - startMonitoring

    internal var startMonitoringCallsCount = 0
    internal var startMonitoringCalled: Bool {
        return startMonitoringCallsCount > 0
    }
    internal var startMonitoringClosure: (() -> Void)?

    internal func startMonitoring() {
        startMonitoringCallsCount += 1
        startMonitoringClosure?()
    }

    //MARK: - stopMonitoring

    internal var stopMonitoringCallsCount = 0
    internal var stopMonitoringCalled: Bool {
        return stopMonitoringCallsCount > 0
    }
    internal var stopMonitoringClosure: (() -> Void)?

    internal func stopMonitoring() {
        stopMonitoringCallsCount += 1
        stopMonitoringClosure?()
    }

    //MARK: - toggleBackup

    internal var toggleBackupCallsCount = 0
    internal var toggleBackupCalled: Bool {
        return toggleBackupCallsCount > 0
    }
    internal var toggleBackupClosure: (() -> Void)?

    internal func toggleBackup() {
        toggleBackupCallsCount += 1
        toggleBackupClosure?()
    }

    //MARK: - enableBackup

    internal var enableBackupCallsCount = 0
    internal var enableBackupCalled: Bool {
        return enableBackupCallsCount > 0
    }
    internal var enableBackupClosure: (() -> Void)?

    internal func enableBackup() {
        enableBackupCallsCount += 1
        enableBackupClosure?()
    }

    //MARK: - disableBackup

    internal var disableBackupCallsCount = 0
    internal var disableBackupCalled: Bool {
        return disableBackupCallsCount > 0
    }
    internal var disableBackupClosure: (() -> Void)?

    internal func disableBackup() {
        disableBackupCallsCount += 1
        disableBackupClosure?()
    }

    //MARK: - clearBackup

    internal var clearBackupCallsCount = 0
    internal var clearBackupCalled: Bool {
        return clearBackupCallsCount > 0
    }
    internal var clearBackupClosure: (() -> Void)?

    internal func clearBackup() {
        clearBackupCallsCount += 1
        clearBackupClosure?()
    }

    //MARK: - synchronizeBackup

    internal var synchronizeBackupCallsCount = 0
    internal var synchronizeBackupCalled: Bool {
        return synchronizeBackupCallsCount > 0
    }
    internal var synchronizeBackupClosure: (() -> Void)?

    internal func synchronizeBackup() {
        synchronizeBackupCallsCount += 1
        synchronizeBackupClosure?()
    }


   internal init() {}
}
