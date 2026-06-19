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

@Observable
final class NewsPresenter {
    var list: [NewsCell] = []

    private let flowController: NewsPlainFlowControlling
    private let interactor: NewsModuleInteracting
    private let notificationCenter: NotificationCenter
    private let dateFormatter = RelativeDateTimeFormatter()

    init(flowController: NewsPlainFlowControlling, interactor: NewsModuleInteracting) {
        self.interactor = interactor
        self.flowController = flowController
        self.notificationCenter = .default
        notificationCenter.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    func viewDidAppear() {
        refreshView()
    }

    func handleSelection(at row: Int) {
        guard var entry = list[safe: row] else { return }
        entry.markAsRead()
        list[row] = entry

        interactor.markAsRead(newsEntry: entry.newsItem)
        if let type = entry.newsItem.localNotificationType {
            AppEventLog(.localNotificationRead(type))
        } else {
            AppEventLog(.articleRead(entry.id))
        }

        if let internalLink = entry.newsItem.internalLink {
            flowController.toInternalLink(internalLink)
        } else if let link = entry.newsItem.link {
            flowController.openWeb(with: link)
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
        let now = Date()
        interactor.fetchList { [weak self] news in
            let sortedNews = news.sorted { $0.createdAt > $1.createdAt }
            let cells = sortedNews.map { entry in
                NewsCell(
                    icon: entry.icon.image,
                    title: entry.message ?? entry.link?.absoluteString ?? "",
                    wasRead: entry.wasRead,
                    publishedAgo: self?.dateFormatter.localizedString(for: entry.createdAt, relativeTo: now) ?? "",
                    hasURL: entry.link != nil,
                    newsItem: entry
                )
            }

            self?.list = cells
        }
    }
}
