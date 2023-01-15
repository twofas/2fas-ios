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

protocol NewsModuleInteracting: AnyObject {
    var hasUnreadNews: Bool { get }
    
    func becameVisible()
    func becameInvisible()
    
    func localList() -> [ListNewsEntry]
    func fetchList(completion: @escaping ([ListNewsEntry]) -> Void)
    func markAsRead(newsEntry: ListNewsEntry)
}

final class NewsModuleInteractor {
    private let network: ListNewsNetworkInteracting
    private let storage: ListNewsStorageInteracting
    
    private var lastFetched: Date?
    private var isFetching = false
    
    private var isVisible = false
    
    init(network: ListNewsNetworkInteracting, storage: ListNewsStorageInteracting) {
        self.network = network
        self.storage = storage
    }
}

extension NewsModuleInteractor: NewsModuleInteracting {
    var hasUnreadNews: Bool {
        storage.hasNewsEntriesUnreadItems()
    }
    
    func becameVisible() {
        isVisible = true
    }
    
    func becameInvisible() {
        isVisible = false
        clearHasUnreadNews()
    }
    
    func localList() -> [ListNewsEntry] {
        storage.listAll()
    }
    
    func fetchList(completion: @escaping ([ListNewsEntry]) -> Void) {
        guard !isFetching && canFetchNow else { return }
        isFetching = true
        network.fetchNews { [weak self] result in
            switch result {
            case .success(let newList):
                self?.lastFetched = Date()
                self?.handleFetchedList(newList, completion: completion)
            case .failure:
                Log("NewsModuleInteractor: Can't fetch new News list", module: .moduleInteractor)
            }
            self?.isFetching = false
        }
    }
    
    func markAsRead(newsEntry: ListNewsEntry) {
        storage.markNewsEntryAsRead(with: newsEntry)
    }
}

private extension NewsModuleInteractor {
    var canFetchNow: Bool {
        guard let lastFetched else { return true }
        let hour: TimeInterval = 3600
        let now = Date()
        return (now.timeIntervalSince1970 - lastFetched.timeIntervalSince1970) >= hour
    }
    
    func clearHasUnreadNews() {
        Log("NewsModuleInteractor - clearHasUnreadNews", module: .moduleInteractor)
        guard storage.hasNewsEntriesUnreadItems() else { return }
        storage.markAllAsRead()
    }
    
    func handleFetchedList(_ newList: [ListNewsEntry], completion: @escaping ([ListNewsEntry]) -> Void) {
        let currentList = storage.listAll()
        guard currentList != newList else {
            Log(
                "NewsModuleInteractor - handleFetchedList. Fetched list is the same as local one. Exiting",
                module: .moduleInteractor
            )
            return
        }
        var added = [ListNewsEntry]()
        var modified = [ListNewsEntry]()
        var deleted = [ListNewsEntry]()
        
        for newItem in newList {
            if let currentItem = currentList.first(where: { $0.newsID == newItem.newsID }) {
                if currentItem != newItem {
                    modified.append(newItem)
                }
            } else {
                added.append(newItem)
            }
        }
        for currentItem in currentList {
            if newList.first(where: { $0.newsID == currentItem.newsID }) == nil {
                deleted.append(currentItem)
            }
        }
        
        guard !(added.isEmpty && modified.isEmpty && deleted.isEmpty) else {
            Log(
                "NewsModuleInteractor - handleFetchedList. No change needed. Exiting",
                module: .moduleInteractor
            )
            return
        }
        
        added.forEach { entry in
            storage.createNewsEntry(from: entry)
        }
        
        modified.forEach { entry in
            storage.updateNewsEntry(with: entry)
        }
        
        deleted.forEach { entry in
            storage.deleteNewsEntry(with: entry)
        }
        
        completion(storage.listAll())
    }
}
