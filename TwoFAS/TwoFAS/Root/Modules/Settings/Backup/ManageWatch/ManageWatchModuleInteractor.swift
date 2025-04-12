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

import Foundation
import Data
import Common

protocol ManageWatchModuleInteracting: AnyObject {
    var stateDidChange: Callback? { get set }
    var canAccessList: Bool { get }
    func list() -> [PairedWatch]
    func unpair(_ pairedWatch: PairedWatch)
    func rename(_ pairedWatch: PairedWatch, newName: String)
}

final class ManageWatchModuleInteractor {
    var stateDidChange: Callback?
    
    private let manageWatch: WatchPairingInteracting
    private let notificationCenter: NotificationCenter
    
    init(manageWatch: WatchPairingInteracting) {
        self.manageWatch = manageWatch
        self.notificationCenter = .default
        notificationCenter.addObserver(self, selector: #selector(syncStateDidChange), name: .syncStateChanged, object: nil)
    }
    
    @objc
    private func syncStateDidChange() {
        stateDidChange?()
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}

extension ManageWatchModuleInteractor: ManageWatchModuleInteracting {
    var canAccessList: Bool { manageWatch.canModify }
    
    func list() -> [PairedWatch] {
        manageWatch.list()
    }
    
    func unpair(_ pairedWatch: PairedWatch) {
        manageWatch.unpair(pairedWatch)
    }
    
    func rename(_ pairedWatch: PairedWatch, newName: String) {
        manageWatch.rename(pairedWatch, newName: newName)
    }
}
