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

import UIKit
import Data

final class NewsPresenter {
    weak var view: NewsViewControlling?
    
    private let flowController: NewsPlainFlowControlling
    private let interactor: NewsModuleInteracting
    private let dateFormatter = RelativeDateTimeFormatter()
    
    private var viewIsLoaded = false
    
    init(flowController: NewsPlainFlowControlling, interactor: NewsModuleInteracting) {
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
    }
    
    func viewWillAppear() {
        refreshView()
    }
    
    func handleRefreshView() {
        refreshView()
    }
    
    func handleSelection(at row: Int) {
        interactor.fetchList { [weak self] list in
            guard let entry = list[safe: row] else { return }
            self?.interactor.markAsRead(newsEntry: entry)
            if let type = entry.localNotificationType {
                AppEventLog(.localNotificationRead(type))
            } else {
                AppEventLog(.articleRead(entry.newsID))
            }
            
            if let internalLink = entry.internalLink {
                self?.flowController.toInternalLink(internalLink)
            } else if let link = entry.link {
                self?.flowController.openWeb(with: link)
            }
        }
    }
    
    func close() {
        interactor.markAllAsRead()
        flowController.toClose()
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
        interactor.fetchList { [weak self] news in
            let cells = news.map { entry in
                NewsCell(
                    icon: entry.icon.image,
                    title: entry.message ?? entry.link?.absoluteString ?? "",
                    wasRead: entry.wasRead,
                    publishedAgo: self?.dateFormatter.localizedString(for: entry.publishedAt, relativeTo: now) ?? "",
                    hasURL: entry.link != nil,
                    newsItem: entry
                )
            }
            
            guard self?.viewIsLoaded == true else { return }
            
            if cells.isEmpty {
                self?.view?.showEmptyScreen()
            } else {
                self?.view?.reload(with: NewsSection(cells: cells))
            }
        }
    }
}
