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
    
    func localList() -> [ListNewsEntry]
    func fetchList(completion: @escaping ([ListNewsEntry]) -> Void)
    func markAsRead(newsEntry: ListNewsEntry)
    func markAllAsRead()
}

final class NewsModuleInteractor {
    private let newsInteractor: NewsInteracting
    
    init(newsInteractor: NewsInteracting) {
        self.newsInteractor = newsInteractor
    }
}

extension NewsModuleInteractor: NewsModuleInteracting {
    var hasUnreadNews: Bool {
        newsInteractor.hasUnreadNews
    }
    
    func localList() -> [ListNewsEntry] {
        newsInteractor.localList()
    }
    
    func fetchList(completion: @escaping ([ListNewsEntry]) -> Void) {
        newsInteractor.fetchList(completion: { [weak self] in
            guard let self else { return }
            completion(self.newsInteractor.localList())
        })
    }
    
    func markAsRead(newsEntry: ListNewsEntry) {
        newsInteractor.markAsRead(newsEntry: newsEntry)
    }
    
    func markAllAsRead() {
        newsInteractor.clearHasUnreadNews()
    }
}
