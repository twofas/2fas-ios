//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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

import UIKit
import Common
import Data

final class SyncMigrationToNewestVersionPresenter: ObservableObject {
    @Published var isMigrating = true
    @Published var migrationFailureReason: CloudState.NotAvailableReason?
    
    lazy var callback: (SyncMigrationToNewestVersionFlowResult) -> Void = { [weak self] result in
        switch result {
        case .success: self?.toSuccess()
        case .error(let reason): self?.toFailure(reason)
        }
    }
    private let flowController: SyncMigrationToNewestVersionFlowControlling
    
    init(flowController: SyncMigrationToNewestVersionFlowControlling) {
        self.flowController = flowController
    }
}

extension SyncMigrationToNewestVersionPresenter {
    func close() {
        flowController.close()
    }
}

private extension SyncMigrationToNewestVersionPresenter {
    func toSuccess() {
        migrationFailureReason = nil
        isMigrating = false
    }
    
    func toFailure(_ reason: CloudState.NotAvailableReason) {
        migrationFailureReason = reason
        isMigrating = false
    }
}
