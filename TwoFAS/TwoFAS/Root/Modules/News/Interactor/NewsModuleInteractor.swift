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
import Common
import Data

protocol NewsModuleInteracting: AnyObject {
    var hasUnreadNews: Bool { get }
    
    func fetchList(completion: @escaping ([ListNewsEntry]) -> Void)
    func markAsRead(newsEntry: ListNewsEntry)
    func markAllAsRead()
}

final class NewsModuleInteractor {
    private let newsInteractor: NewsInteracting
    private let localNotificationFetchInteractor: LocalNotificationFetchInteracting
        
    init(newsInteractor: NewsInteracting, localNotificationFetchInteractor: LocalNotificationFetchInteracting) {
        self.newsInteractor = newsInteractor
        self.localNotificationFetchInteractor = localNotificationFetchInteractor
    }
}

extension NewsModuleInteractor: NewsModuleInteracting {
    var hasUnreadNews: Bool {
        newsInteractor.hasUnreadNews
    }
    
    func fetchList(completion: @escaping ([ListNewsEntry]) -> Void) {
        newsInteractor.fetchList { [weak self] in
            self?.localNotificationFetchInteractor.getNotification { [weak self] notification in
                guard let self else { return }
                let list = self.prepareList(news: self.newsInteractor.localList(), notification: notification)
                completion(list)
            }
        }
    }
    
    func markAsRead(newsEntry: ListNewsEntry) {
        let localList = newsInteractor.localList()
        if localList.contains(newsEntry) {
            newsInteractor.markAsRead(newsEntry: newsEntry)
        } else {
            localNotificationFetchInteractor.markNotificationAsRead()
        }
    }
    
    func markAllAsRead() {
        localNotificationFetchInteractor.markNotificationAsRead()
        newsInteractor.clearHasUnreadNews()
    }
}

private extension NewsModuleInteractor {
    func prepareList(news: [ListNewsEntry], notification: LocalNotification?) -> [ListNewsEntry] {
        guard let notification else {
            return news.sorted
        }
        let notificationNewsEntry = notification.toNewsEntry()
        var completeList = news
        completeList.append(notificationNewsEntry)
        return completeList.sorted
    }
}

extension LocalNotification {
    func toNewsEntry() -> ListNewsEntry {
        let icon: ListNewsEntry.Icon
        let link: URL?
        let message: String
        let internalLink: ListNewsEntry.InternalLink?
        switch self.kind {
        case .tipsNTricks:
            icon = .tips
            link = URL(string: "https://2fas.com/2fasauth-tutorial")
            message = T.periodicNotificationTips
            internalLink = nil
        case .backup:
            icon = .updates
            link = nil
            message = T.periodicNotificationBackup
            internalLink = .backup
        case .browserExtension:
            icon = .news
            link = URL(string: "https://2fas.com/browser-extension/")
            message = T.periodicNotificationBrowserExtension
            internalLink = nil
        case .donation:
            icon = .features
            link = URL(string: "https://2fas.com/donate/")
            message = T.periodicNotificationDonate
            internalLink = nil
        }
        
        return .init(
            newsID: self.id,
            icon: icon,
            link: link,
            message: message,
            publishedAt: self.publishedAt,
            createdAt: nil,
            wasRead: self.wasRead,
            internalLink: internalLink,
            localNotificationType: kind.rawValue
        )
    }
}

extension Array where Element == ListNewsEntry {
    var sorted: Self {
        sorted(by: { $0.publishedAt <= $1.publishedAt })
    }
}
