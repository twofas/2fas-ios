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
import Common

public protocol LocalNotificationStateInteracting: AnyObject {
    func activate()
}

final class LocalNotificationStateInteractor {
    private let mainRepository: MainRepository
    private let serviceListingInteractor: ServiceListingInteracting
    private let cloudBackup: CloudBackupStateInteracting
    private let pairingDeviceInteractor: PairingWebExtensionInteracting
    private let mdmInteractor: MDMInteracting
    
    private let notificationCenter = NotificationCenter.default
    
    private let cycleDays: Int = 30
    private let firstNotificationDays: Int = 2
    
    private var backupStateKnown = false
    
    private var lastActivationDate: Date?
    
    private var awaitsBackupStateChange: Callback?
    
    init(
        mainRepository: MainRepository,
        serviceListingInteractor: ServiceListingInteracting,
        cloudBackup: CloudBackupStateInteracting,
        pairingDeviceInteractor: PairingWebExtensionInteracting,
        mdmInteractor: MDMInteracting
    ) {
        self.mainRepository = mainRepository
        self.serviceListingInteractor = serviceListingInteractor
        self.cloudBackup = cloudBackup
        self.pairingDeviceInteractor = pairingDeviceInteractor
        self.mdmInteractor = mdmInteractor
        
        cloudBackup.stateChanged = { [weak self] in
            guard self?.backupStateKnown == false else { return }
            self?.backupStateKnown = true
            self?.awaitsBackupStateChange?()
            self?.awaitsBackupStateChange = nil
        }
    }
}

extension LocalNotificationStateInteractor: LocalNotificationStateInteracting {
    func activate() {
        if let lastActivationDate {
            guard lastActivationDate.days(from: .now) >= 1 else { return }
        }
        lastActivationDate = .now
        
        if runCount == 0 { // First run
            saveCycle(-2)
        }
        increaseRunCount()
        
        if runCount >= 2 && cycle == -2 {
            startNotification(-1)
        }
        
        guard isTimeForNext else {
            markLocalNotificationsAsHandled()
            return
        }
        
        clearNotification()
        
        let next = nextCycle()
        
        switch next {
        case 0: canDisplayBackup { [weak self] value in
            if value {
                self?.startNotification(next)
            } else {
                self?.setInactiveNotification(next)
            }
        }
        case 1: if canDisplayBrowserExtension() {
            startNotification(next)
        } else {
            setInactiveNotification(next)
        }
        case 2: if canDisplayDonation() {
            startNotification(3)
        } else {
            setInactiveNotification(next)
        }
        default: break
        }
        
        markLocalNotificationsAsHandled()
    }
}

private extension LocalNotificationStateInteractor {
    func markLocalNotificationsAsHandled() {
        mainRepository.markLocalNotificationsAsHandled()
        notificationCenter.post(name: .localNotificationsHandled, object: nil)
    }
    
    var isTimeForNext: Bool {
        guard let publicationDate = mainRepository.localNotificationPublicationDate else {
            return false
        }
        let days = publicationDate.days(from: .now)
        return days >= cycleDays
    }
    
    func saveNotificationPublicationDate() {
        mainRepository.saveLocalNotificationPublicationDate(.now)
    }
    
    func clearNotificationPublicationDate() {
        mainRepository.saveLocalNotificationPublicationDate(nil)
    }
    
    func saveCycle(_ cycle: Int) {
        mainRepository.saveLocalNotificationCycle(cycle)
    }
    
    func increaseRunCount() {
        mainRepository.saveRunCount(runCount + 1)
    }
    
    var runCount: Int {
        mainRepository.runCount
    }
    
    var cycle: Int {
        mainRepository.localNotificationCycle
    }
    
    func startNotification(_ cycle: Int) {
        saveNotificationPublicationDate()
        saveCycle(cycle)
        setIsPublished(true)
    }
    
    func setInactiveNotification(_ cycle: Int) {
        saveNotificationPublicationDate()
        saveCycle(cycle)
        setIsPublished(false)
    }
    
    func increaseCycle() {
        saveCycle(nextCycle())
    }
    
    func clearNotification() {
        setIsPublished(false)
        clearNotificationPublicationDate()
        setWasRead(false)
    }
    
    func setWasRead(_ wasRead: Bool) {
        mainRepository.saveLocalNotificationWasRead(wasRead)
    }
    
    var hasServices: Bool {
        serviceListingInteractor.hasServices
    }
    
    var isBrowserExtensionActive: Bool {
        pairingDeviceInteractor.hasActiveBrowserExtension
    }
    
    func setIsPublished(_ isPublished: Bool) {
        if isPublished {
            mainRepository.saveLocalNotificationPublicationID(UUID().uuidString)
        } else {
            mainRepository.saveLocalNotificationPublicationID(nil)
        }
    }
    
    func nextCycle() -> Int {
        switch cycle {
        case -2: -1
        case -1: 0
        case 0: 1
        case 1: 2
        case 2: 0
        default: 0
        }
    }
    
    func canDisplayBackup(completion: @escaping (Bool) -> Void) {
        if backupStateKnown {
            completion(isBackupPossible())
            return
        }
        awaitsBackupStateChange = { [weak self] in
            guard let self else { return }
            completion(isBackupPossible())
        }
    }
    
    func isBackupPossible() -> Bool {
        !cloudBackup.isBackupEnabled && cloudBackup.isBackupAvailable && hasServices && !mdmInteractor.isBackupBlocked
    }
    
    func canDisplayBrowserExtension() -> Bool {
        !isBrowserExtensionActive && hasServices && !mdmInteractor.isBrowserExtensionBlocked
    }
    
    func canDisplayDonation() -> Bool {
        hasServices
    }
}
