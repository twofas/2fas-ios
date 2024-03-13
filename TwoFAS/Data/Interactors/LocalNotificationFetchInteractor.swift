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

public struct LocalNotification: Hashable {
    public enum NotificationKind: String, Decodable, Hashable {
        case tipsNTricks
        case backup
        case browserExtension
        case donation
        
        static func kindFromCycle(_ cycle: Int) -> NotificationKind {
            switch cycle {
            case -1: .tipsNTricks
            case 0: .backup
            case 1: .browserExtension
            default: .donation
            }
        }
    }
    
    public let id: String
    public let kind: NotificationKind
    public let publishedAt: Date
    public let wasRead: Bool
}

protocol LocalNotificationFetchInteracting: AnyObject {
    func getNotification(completion: @escaping (LocalNotification?) -> Void)
    func markNotificationAsRead()
}

final class LocalNotificationFetchInteractor {
    private let mainRepository: MainRepository
    private let notificationCenter = NotificationCenter.default
    private var fetched = false
    private var notificationCallback: ((LocalNotification?) -> Void)?
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
        notificationCenter.addObserver(
            self,
            selector: #selector(notificationsHandled),
            name: .localNotificationsHandled,
            object: nil
        )
    }
}

extension LocalNotificationFetchInteractor {
    func getNotification(completion: @escaping (LocalNotification?) -> Void) {
        if mainRepository.localNotificationsHandled {
            fetched = true
            completion(currentNotification())
        } else {
            notificationCallback = completion
        }
    }
    
    func markNotificationAsRead() {
       setWasRead(true)
    }
}

private  extension LocalNotificationFetchInteractor {
    @objc
    private func notificationsHandled() {
        guard !fetched else { return }
        fetched = true
        notificationCallback?(currentNotification())
    }
    
    var wasRead: Bool {
        mainRepository.localNotificationWasRead
    }
    
    func setWasRead(_ wasRead: Bool) {
        mainRepository.saveLocalNotificationWasRead(wasRead)
    }
    
    var publishedID: String? {
        mainRepository.localNotificationPublicationID
    }
    
    var cycle: Int {
        mainRepository.localNotificationCycle
    }
    
    func currentNotification() -> LocalNotification? {
        guard let publishedID, let notificationPublishedDate else { return nil }
        return LocalNotification(
            id: publishedID,
            kind: .kindFromCycle(cycle),
            publishedAt: notificationPublishedDate,
            wasRead: wasRead
        )
    }
    
    var isPublished: Bool {
        mainRepository.localNotificationPublicationID != nil
    }
    
    var notificationPublishedDate: Date? {
        mainRepository.localNotificationPublicationDate
    }
}
