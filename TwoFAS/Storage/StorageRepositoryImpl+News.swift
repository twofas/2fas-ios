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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

extension StorageRepositoryImpl {
    func createNewsEntry(from newsEntry: ListNewsEntry) {
        NewsEntity.create(
            on: context,
            newsID: newsEntry.newsID,
            icon: newsEntry.icon.rawValue,
            link: newsEntry.link,
            message: newsEntry.message,
            publishedAt: newsEntry.publishedAt,
            createdAt: newsEntry.createdAt
        )
        save()
    }
    
    func deleteNewsEntry(with newsEntry: ListNewsEntry) {
        NewsEntity.delete(on: context, identifiedByID: newsEntry.newsID)
        save()
    }
    
    func updateNewsEntry(with newsEntry: ListNewsEntry) {
        NewsEntity.update(
            on: context,
            identifiedByID: newsEntry.newsID,
            link: newsEntry.link,
            message: newsEntry.message,
            publishedAt: newsEntry.publishedAt,
            createdAt: newsEntry.createdAt
        )
        save()
    }
    
    func markNewsEntryAsRead(with newsEntry: ListNewsEntry) {
        NewsEntity.markAsRead(on: context, identifiedByID: newsEntry.newsID)
        save()
    }
    
    func listAllNews() -> [ListNewsEntry] {
        listAllNews(includesPendingChanges: false)
    }
    
    func listAllFreshlyAddedNews() -> [ListNewsEntry] {
        listAllNews(includesPendingChanges: true)
    }
    
    func hasNewsEntriesUnreadItems() -> Bool {
        NewsEntity.countUnreadItems(on: context) > 0
    }
    
    func markAllAsRead() {
        NewsEntity.markAllAsRead(on: context)
        save()
    }
}

private extension StorageRepositoryImpl {
    func listAllNews(includesPendingChanges: Bool) -> [ListNewsEntry] {
        NewsEntity.listAll(on: context, includesPendingChanges: includesPendingChanges)
            .map({ entity in
                ListNewsEntry(
                    newsID: entity.newsID,
                    icon: .init(rawValue: entity.icon) ?? .news,
                    link: entity.link,
                    message: entity.message,
                    publishedAt: entity.publishedAt,
                    createdAt: entity.createdAt,
                    wasRead: entity.wasRead,
                    internalLink: nil
                )
            })
    }
}
