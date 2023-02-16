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
import UIKit

final class NewsPresenter {
    weak var view: NewsViewControlling?
    
    private let flowController: NewsFlowControlling
    private let interactor: NewsModuleInteracting
    private let dateFormatter = RelativeDateTimeFormatter()
    
    private var viewIsLoaded = false
    
    init(flowController: NewsFlowControlling, interactor: NewsModuleInteracting) {
        self.interactor = interactor
        self.flowController = flowController
    }
    
    func viewDidLoad() {
        viewIsLoaded = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        refreshView()
    }
    
    func viewWillAppear() {
        refreshView()
    }
        
    func handleRefreshView() {
        refreshView()
    }
    
    func handleSelection(at row: Int) {
        guard let entry = interactor.localList()[safe: row], let link = entry.link else { return }
        interactor.markAsRead(newsEntry: entry)
        AnalyticsLog(.articleRead(entry.newsID))
        flowController.openWeb(with: link)
    }
}

private extension NewsPresenter {
    @objc func willEnterForeground() {
        refreshView()
    }
    
    func refreshView() {
        reload()
        interactor.fetchList { [weak self] _ in
            self?.reload()
        }
    }
    
    func reload() {
        let now = Date()
        let cells = interactor
            .localList()
            .map { entry in
                NewsCell(
                    icon: entry.icon.image,
                    title: entry.message ?? entry.link?.absoluteString ?? "",
                    wasRead: entry.wasRead,
                    publishedAgo: dateFormatter.localizedString(for: entry.publishedAt, relativeTo: now),
                    hasURL: entry.link != nil,
                    newsItem: entry
                )
            }
        
        guard viewIsLoaded else { return }
        
        if cells.isEmpty {
            view?.showEmptyScreen()
        } else {
            view?.reload(with: NewsSection(cells: cells))
        }
    }
}
