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

protocol NewsInteracting: AnyObject {
    var hasUnreadNews: Bool { get }
    func clearHasUnreadNews()
    
    func localList() -> [ListNewsEntry]
    func fetchList(completion: @escaping () -> Void)
    func markAsRead(newsEntry: ListNewsEntry)
}

final class NewsInteractor {
    private let network: ListNewsNetworkInteracting
    private let storage: ListNewsStorageInteracting
    private let mainRepository: MainRepository
    
    init(network: ListNewsNetworkInteracting, storage: ListNewsStorageInteracting, mainRepository: MainRepository) {
        self.network = network
        self.storage = storage
        self.mainRepository = mainRepository
    }
}

extension NewsInteractor: NewsInteracting {
    var hasUnreadNews: Bool {
        storage.hasNewsEntriesUnreadItems()
    }
    
    func localList() -> [ListNewsEntry] {
        storage.listAll()
    }
    
    func clearHasUnreadNews() {
        Log("NewsInteractor - clearHasUnreadNews", module: .moduleInteractor)
        guard storage.hasNewsEntriesUnreadItems() else { return }
        storage.markAllAsRead()
    }
    
    func fetchList(completion: @escaping () -> Void) {
        guard canFetchNow else {
            completion()
            return
        }
        
        mainRepository.storeNewsCompletions(completion)
        
        guard !mainRepository.isFetchingNews() else {
            return
        }
        
        mainRepository.setIsFetchingNews(true)
        network.fetchNews { [weak self] result in
            switch result {
            case .success(let newList):
                self?.mainRepository.saveLastNewsFetch(Date())
                self?.handleFetchedList(newList)
            case .failure:
                Log("NewsInteractor: Can't fetch new News list", module: .moduleInteractor)
                self?.handleCompletions()
            }
            self?.mainRepository.setIsFetchingNews(false)
        }
    }
    
    func markAsRead(newsEntry: ListNewsEntry) {
        storage.markNewsEntryAsRead(with: newsEntry)
    }
}

private extension NewsInteractor {
    func handleCompletions() {
        mainRepository.callAndClearNewsCompletions()
    }
    
    var canFetchNow: Bool {
        guard let lastFetched = mainRepository.lastNewsFetch() else { return true }
        let hour: TimeInterval = 3600
        let now = Date()
        return (now.timeIntervalSince1970 - lastFetched.timeIntervalSince1970) >= hour
    }
    
    func handleFetchedList(_ newList: [ListNewsEntry]) {
        let currentList = storage.listAll()
        guard currentList != newList else {
            Log(
                "NewsInteractor - handleFetchedList. Fetched list is the same as local one. Exiting",
                module: .moduleInteractor
            )
            handleCompletions()
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
                "NewsInteractor - handleFetchedList. No change needed. Exiting",
                module: .moduleInteractor
            )
            handleCompletions()
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
        
        handleCompletions()
    }
}
