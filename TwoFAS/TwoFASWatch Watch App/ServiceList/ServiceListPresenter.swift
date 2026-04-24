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

@Observable
final class ServiceListPresenter {
    var list: [Category] = []
    
    private let interactor: ServiceListInteracting
    private let notificationCenter: NotificationCenter
    
    init(interactor: ServiceListInteracting) {
        self.interactor = interactor
        self.notificationCenter = .default
        
        notificationCenter.addObserver(
            self,
            selector: #selector(notificationRefresh),
            name: .syncCompletedSuccessfuly,
            object: nil
        )
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}

extension ServiceListPresenter {
    func onAppear() {
        refresh()
        sync()
    }
    
    private func refresh() {
        list = interactor.listAllServices()
            .toCategories()
    }
    
    @objc
    private func notificationRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.refresh()
        }
    }
}
