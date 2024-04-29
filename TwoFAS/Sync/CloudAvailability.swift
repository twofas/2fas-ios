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

enum CloudAvailabilityStatus {
    case available
    case notAvailable
    case accountChanged
    case error(NSError)
}

final class CloudAvailability {
    private let container: CKContainer
    
    typealias AvailabilityCheckResult = (CloudAvailabilityStatus) -> Void
    var availabilityCheckResult: AvailabilityCheckResult?
    
    init(container: CKContainer) {
        self.container = container
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(availabilityChanged),
            name: .CKAccountChanged,
            object: nil
        )
    }
    
    func checkAvailability() {
        Log("CloudAvailability - Checking availability", module: .cloudSync)
        container.accountStatus { [weak self] accountStatus, accountError in
            // swiftlint:disable line_length
            Log("CloudAvailability - Checking availability - status \(accountStatus), error \(String(describing: accountError))", module: .cloudSync)
            // swiftlint:enable line_length
            switch accountStatus {
            case .noAccount, .restricted: self?.notAvailable()
            case .couldNotDetermine:
                let error = accountError ?? NSError(
                    domain: CKErrorDomain, code: CKError.notAuthenticated.rawValue, userInfo: nil
                )
                DispatchQueue.main.async {
                    self?.availabilityCheckResult?(.error(error as NSError))
                }
            case .available:
                self?.checkUser()
            case .temporarilyUnavailable:
                let error = accountError ?? NSError(
                    domain: CKErrorDomain, code: CKError.accountTemporarilyUnavailable.rawValue, userInfo: nil
                )
                DispatchQueue.main.async {
                    self?.availabilityCheckResult?(.error(error as NSError))
                }
            @unknown default:
                Log(
                    "CloudAvailability - Unknown new case of iCloud Account Status \(accountStatus)",
                    module: .cloudSync
                )
            }
        }
    }
    
    func clear() {
        Log("CloudAvailability - Checking availability - clearing", module: .cloudSync)
        ConstStorage.username = nil
    }
    
    @objc
    private func availabilityChanged() {
        Log("CloudAvailability - Checking availability - notification received", module: .cloudSync)
        checkAvailability()
    }
    
    private func saveUser(_ user: String) {
        ConstStorage.username = user
    }
    
    private func savedUser() -> String? {
        ConstStorage.username
    }
    
    private func checkUser() {
        container.fetchUserRecordID { [weak self] recordID, error in
            guard error == nil, let recordID else {
                Log(
                    "CloudAvailability - Checking availability - can't fetch user \(String(describing: error))",
                    module: .cloudSync
                )
                if let error {
                    // swiftlint:disable line_length
                    Log("CloudAvailability - Checking availability - can't fetch user, error \(error)", module: .cloudSync)
                    // swiftlint:enable line_length
                    DispatchQueue.main.async {
                        self?.availabilityCheckResult?(.error(error as NSError))
                    }
                } else {
                    Log("CloudAvailability - Checking availability - .notAvailable", module: .cloudSync)
                    DispatchQueue.main.async {
                        self?.availabilityCheckResult?(.notAvailable)
                    }
                }
                return
            }
            let user = recordID.recordName
            if let currentUser = self?.savedUser() {
                if user == currentUser {
                    Log("CloudAvailability - Checking availability - current user, .available", module: .cloudSync)
                    DispatchQueue.main.async {
                        self?.availabilityCheckResult?(.available)
                    }
                } else {
                    Log(
                        "CloudAvailability - Checking availability - user changed, .available -> .accountChanged",
                        module: .cloudSync
                    )
                    self?.saveUser(user)
                    DispatchQueue.main.async {
                        self?.availabilityCheckResult?(.accountChanged)
                    }
                }
            } else {
                Log("CloudAvailability - Checking availability - new user, .available", module: .cloudSync)
                self?.saveUser(user)
                DispatchQueue.main.async {
                    self?.availabilityCheckResult?(.available)
                }
            }
        }
    }
    
    private func notAvailable() {
        Log("CloudAvailability - notAvailable()", module: .cloudSync)
        if savedUser() != nil {
            clear()
        }
        DispatchQueue.main.async {
            self.availabilityCheckResult?(.notAvailable)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
