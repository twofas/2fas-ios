//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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
import CommonWatch
import SwiftUI

@Observable
final class MainPresenter {
    var favoriteList: [Service] = []
    var showPairQRCode = false
    var showSystemKeyError = false
    /// What stopped the backup, when it has to be told – shown once
    var syncProblem: String?
    var showSyncProblem = false
    
    private let interactor: MainInteracting
    private var syncObserver: NSObjectProtocol?
    
    init(interactor: MainInteracting) {
        self.interactor = interactor
        interactor.showPairQRCode = { [weak self] in
            self?.showPairQRCode = $0
        }
        interactor.showSystemKeyError = { [weak self] in
            self?.showSystemKeyError = $0
        }
        interactor.showSyncProblem = { [weak self] problem in
            self?.syncProblem = problem
            self?.showSyncProblem = problem != nil
        }
        // What was added to or removed from the favorites elsewhere shows without leaving the screen
        syncObserver = NotificationCenter.default.addObserver(
            forName: .syncCompletedSuccessfuly,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refresh()
        }
    }
    
    deinit {
        if let syncObserver {
            NotificationCenter.default.removeObserver(syncObserver)
        }
    }
    
    func onAppear() {
        refresh()
        sync()
    }
    
    func sync() {
        interactor.sync()
    }
    
    private func refresh() {
        favoriteList = interactor
            .listFavoriteServices()
            .map { $0.toService() }
    }
}
