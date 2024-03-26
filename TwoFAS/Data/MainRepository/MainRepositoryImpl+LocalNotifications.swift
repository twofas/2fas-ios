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

extension MainRepositoryImpl {
    var localNotificationPublicationDate: Date? {
        userDefaultsRepository.localNotificationPublicationDate
    }
    
    func saveLocalNotificationPublicationDate(_ date: Date?) {
        userDefaultsRepository.saveLocalNotificationPublicationDate(date)
    }
    
    var localNotificationPublicationID: String? {
        userDefaultsRepository.localNotificationPublicationID
    }
    
    func saveLocalNotificationPublicationID(_ ID: String?) {
        userDefaultsRepository.saveLocalNotificationPublicationID(ID)
    }
    
    var localNotificationWasRead: Bool {
        userDefaultsRepository.localNotificationWasRead
    }
    
    func saveLocalNotificationWasRead(_ wasRead: Bool) {
        userDefaultsRepository.saveLocalNotificationWasRead(wasRead)
    }
    
    var localNotificationCycle: Int {
        userDefaultsRepository.localNotificationCycle
    }
    
    func saveLocalNotificationCycle(_ cycle: Int) {
        userDefaultsRepository.saveLocalNotificationCycle(cycle)
    }
    
    var runCount: Int {
        userDefaultsRepository.runCount
    }
    
    func saveRunCount(_ count: Int) {
        userDefaultsRepository.saveRunCount(count)
    }
    
    var localNotificationsHandled: Bool {
        _areLocalNotificationsHandled
    }
    
    func markLocalNotificationsAsHandled() {
        _areLocalNotificationsHandled = true
    }
}
