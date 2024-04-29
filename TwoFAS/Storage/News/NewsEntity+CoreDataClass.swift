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
import CoreData
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

@objc(NewsEntity)
final class NewsEntity: NSManagedObject {
    @nonobjc private static let entityName = "NewsEntity"
    
    @nonobjc static func create(
        on context: NSManagedObjectContext,
        newsID: String,
        icon: String,
        link: URL?,
        message: String?,
        publishedAt: Date,
        createdAt: Date?
    ) {
        let news = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! NewsEntity
        news.newsID = newsID
        news.icon = icon
        news.link = link
        news.message = message
        news.publishedAt = publishedAt
        news.createdAt = createdAt
        news.wasRead = false
    }
    
    @nonobjc static func delete(on context: NSManagedObjectContext, identifiedByID newsID: String) {
        let news = listAll(on: context)
        guard
            let newsForDeletition = news.first(where: { $0.newsID == newsID })
        else {
            Log("Can't find news entry for deletition in local storage", module: .storage)
            return
        }
        delete(on: context, newsEntity: newsForDeletition)
    }
    
    @nonobjc static func update(
        on context: NSManagedObjectContext,
        identifiedByID newsID: String,
        link: URL?,
        message: String?,
        publishedAt: Date,
        createdAt: Date?
    ) {
        let news = listAll(on: context)
        guard
            let newsForUpdate = news.first(where: { $0.newsID == newsID })
        else {
            Log("Can't find news entry for updating on local storage", module: .storage)
            return
        }
        
        newsForUpdate.link = link
        newsForUpdate.message = message
        newsForUpdate.publishedAt = publishedAt
        newsForUpdate.createdAt = createdAt
    }
    
    @nonobjc static func removeAll(on context: NSManagedObjectContext) {
        let all = listAll(on: context)
        all.forEach { context.delete($0) }
    }
    
    @nonobjc static func markAsRead(on context: NSManagedObjectContext, identifiedByID newsID: String) {
        let news = listAll(on: context)
        guard
            let newsForUpdate = news.first(where: { $0.newsID == newsID })
        else {
            Log("Can't find news entry for updating on local storage", module: .storage)
            return
        }
        
        newsForUpdate.wasRead = true
    }
    
    @nonobjc static func markAllAsRead(on context: NSManagedObjectContext) {
        listAll(on: context)
            .filter({ $0.wasRead == false })
            .forEach({ $0.wasRead = true })
    }
    
    @nonobjc static func news(on context: NSManagedObjectContext, for newsID: String) -> NewsEntity? {
        listAll(on: context)
            .first(where: { $0.newsID == newsID })
    }
    
    @nonobjc static func listAll(
        on context: NSManagedObjectContext,
        includesPendingChanges: Bool = false
    ) -> [NewsEntity] {
        let fetchRequest = NewsEntity.request()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
        fetchRequest.includesPendingChanges = includesPendingChanges
        var list: [NewsEntity] = []
        
        do {
            
            list = try context.fetch(fetchRequest)
        } catch {
            
            let err = error as NSError
            Log("NewsEntity in Storage listAll(): \(err.localizedDescription)", module: .storage)
            return []
        }
        
        return list
    }
    
    @nonobjc static func countUnreadItems(on context: NSManagedObjectContext) -> Int {
        listAll(on: context)
            .filter { !$0.wasRead }
            .count
    }
    
    // MARK: - Private
    
    @nonobjc private static func delete(on context: NSManagedObjectContext, newsEntity: NewsEntity) {
        context.delete(newsEntity)
    }
}
