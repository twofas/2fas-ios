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
import NetworkStack
import Common

enum ListNewsError: Error {
    case noInternet
    case serverError
}

protocol ListNewsNetworkInteracting: AnyObject {
    func setIsFetching(_ isFetching: Bool)
    func isFetching() -> Bool
    func fetchNews(completion: @escaping (Result<[ListNewsEntry], ListNewsError>) -> Void)
}

final class ListNewsNetworkInteractor {
    private let dateFormatter = ISO8601DateFormatter()
    private let calendar = Calendar.current
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension ListNewsNetworkInteractor: ListNewsNetworkInteracting {
    func setIsFetching(_ isFetching: Bool) {
        mainRepository.setIsFetchingNews(isFetching)
    }
    
    func isFetching() -> Bool {
        mainRepository.isFetchingNews()
    }

    func fetchNews(completion: @escaping (Result<[ListNewsEntry], ListNewsError>) -> Void) {
        Log("ListNewsNetworkInteractor - fetchNews", module: .interactor)
        let installDate = mainRepository.dateOfFirstRun ?? Date.now
        mainRepository.listAllNews(publishedAfter: dateFormatter.string(from: installDate)) { [weak self] result in
            switch result {
            case .success(let list):
                Log("ListNewsNetworkInteractor - fetchNews. Success", module: .interactor)
                let parsed = self?.parsedList(list) ?? []
                // Temporary taking last 10 entries
                let lastTen = Array((parsed).suffix(10))
                completion(.success(lastTen))
            case .failure(let error):
                Log("ListNewsNetworkInteractor - fetchNews. Failure: \(error)", module: .interactor)
                switch error {
                case .noInternet: completion(.failure(.noInternet))
                case .connection: completion(.failure(.serverError))
                }
            }
        }
    }
}

private extension ListNewsNetworkInteractor {
    func parsedList(_ list: [ListNews.NewsEntry]) -> [ListNewsEntry] {
        list.compactMap { entry -> ListNewsEntry? in
            guard let icon = ListNewsEntry.Icon(rawValue: entry.icon),
                  let publishedAt = dateFormatter.date(from: entry.publishedAt)
            else { return nil }
            return ListNewsEntry(
                newsID: entry.id,
                icon: icon,
                link: {
                    guard let link = entry.link else { return nil }
                    return URL(string: link)
                }(),
                message: entry.message,
                publishedAt: publishedAt,
                createdAt: {
                    guard let createdAt = entry.createdAt else { return nil }
                    return dateFormatter.date(from: createdAt)
                }(),
                wasRead: false,
                internalLink: nil
            )
        }
        .sorted(by: { $0.publishedAt > $1.publishedAt })
    }
}
