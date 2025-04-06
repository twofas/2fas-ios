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

protocol MainInteracting: AnyObject {
    var showPairQRCode: ((Bool) -> Void)? { get set }
    var showSystemKeyError: ((Bool) -> Void)? { get set }
    func listFavoriteServices() -> [ServiceData]
}

final class MainInteractor {
    private let mainRepository: MainRepository
    private let notificationCenter: NotificationCenter
    
    var showPairQRCode: ((Bool) -> Void)?
    var showSystemKeyError: ((Bool) -> Void)?
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
        notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(syncStateChanged), name: .syncStateChanged, object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}

extension MainInteractor: MainInteracting {
    func listFavoriteServices() -> [ServiceData] {
        mainRepository.listFavoriteServices()
    }
}

private extension MainInteractor {
    @objc
    func syncStateChanged() {
        switch mainRepository.currentCloudState {
        case .disabledNotAvailable(let reason):
            switch reason {
            case .cloudEncryptedUser:
                showPairQRCode?(true)
            case .cloudEncryptedSystem:
                showSystemKeyError?(true)
            default: break
            }
        case .enabled(let sync):
            switch sync {
            case .synced:
                showPairQRCode?(false)
                showSystemKeyError?(false)
            default: break
            }
        default: break
        }
    }
}
