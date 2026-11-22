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
    var showSyncProblem: ((String?) -> Void)? { get set }
    func listFavoriteServices() -> [ServiceData]
    func sync()
}

final class MainInteractor {
    private let mainRepository: MainRepository
    private let notificationCenter: NotificationCenter
    
    var showPairQRCode: ((Bool) -> Void)?
    var showSystemKeyError: ((Bool) -> Void)?
    var showSyncProblem: ((String?) -> Void)?
    private var shownSyncProblem: String?
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
        notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(syncStateChanged),
            name: .syncStateChanged,
            object: nil
        )
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}

extension MainInteractor: MainInteracting {
    func listFavoriteServices() -> [ServiceData] {
        mainRepository.listFavoriteServices()
    }
    
    func sync() {
        mainRepository.synchronizeCloudBackup()
    }
}

private extension MainInteractor {
    func reportSyncProblem(_ description: String) {
        guard shownSyncProblem != description else { return }
        shownSyncProblem = description
        showSyncProblem?(description)
    }
    
    @objc
    func syncStateChanged() {
        switch mainRepository.currentCloudState {
        case .disabledNotAvailable(let reason):
            switch reason {
            case .cloudEncryptedUser:
                showPairQRCode?(true)
            case .cloudEncryptedSystem:
                showSystemKeyError?(true)
            case .newerVersion:
                reportSyncProblem(T.Error.cloudBackupNewerVersion)
            case .useriCloudProblem:
                reportSyncProblem(T.Backup.icloudProblem)
            case .other:
                reportSyncProblem(T.Backup.icloudNotAvailable)
            case .error(let error):
                reportSyncProblem(error?.localizedDescription ?? T.Commons.unknownError)
            case .encryptionError(let encryptionError):
                switch encryptionError {
                case .missingSystemKey: reportSyncProblem(T.Backup.errorMissingSystemKey)
                case .missingUserKey: reportSyncProblem(T.Backup.errorMissingUserKey)
                case .cantCreateEncryptionElements: reportSyncProblem(T.Backup.errorCantCreateKeys)
                case .missingAllKeys: reportSyncProblem(T.Backup.errorMissingAllKeys)
                case .unreadableRecords: reportSyncProblem(T.Backup.errorUnreadableRecords)
                }
            case .disabledByUser, .overQuota, .incorrectService: break
            }
        case .enabled(let sync):
            switch sync {
            case .synced:
                showPairQRCode?(false)
                showSystemKeyError?(false)
                shownSyncProblem = nil
                showSyncProblem?(nil)
            default: break
            }
        default: break
        }
    }
}
