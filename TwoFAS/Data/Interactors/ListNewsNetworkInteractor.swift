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
        let publishedAfter = dateFormatter.string(from: installDate)
        let lang = Locale.current.identifier
        guard let groupID = mainRepository.notificationGroupID else { return }
        let noCompanionAppFrom: String? = {
            if let date = mainRepository.dateOfNoCompanionApp {
                return dateFormatter.string(from: date)
            }
            return nil
        }()
        
        mainRepository
            .listAllNews(
                publishedAfter: publishedAfter,
                lang: lang,
                group: groupID,
                noCompanionAppFrom: noCompanionAppFrom
            ) { [weak self] result in
            switch result {
            case .success(let list):
                Log("ListNewsNetworkInteractor - fetchNews. Success", module: .interactor)
                let parsed = self?.parsedList(list) ?? []
                completion(.success(parsed))
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
                  let createdAtValue = entry.createdAt,
                  let createdAt = dateFormatter.date(from: createdAtValue)
            else { return nil }
            return ListNewsEntry(
                newsID: entry.id,
                icon: icon,
                link: {
                    guard let link = entry.link else { return nil }
                    return URL(string: link)
                }(),
                message: entry.message,
                createdAt: createdAt,
                wasRead: false,
                internalLink: nil
            )
        }
        .sorted(by: { $0.createdAt > $1.createdAt })
    }
}
