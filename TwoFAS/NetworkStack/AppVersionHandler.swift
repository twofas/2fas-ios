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

public enum CheckNewVersionError: Error {
    case invalidBundleInfo
    case networkError(error: Error)
    case invalidResponse
    case aleadyChecking
}

public struct CheckNewVersionAppInfo {
    public let version: String
    public let appStoreURL: URL
}

public protocol AppVersionHandling: AnyObject {
    func checkVersion(
        for identifier: String,
        completion: @escaping (Result<CheckNewVersionAppInfo, CheckNewVersionError>) -> Void
    )
}

final class AppVersionHandler {
    private var task: URLSessionTask?
}

extension AppVersionHandler: AppVersionHandling {
    func checkVersion(
        for identifier: String,
        completion: @escaping (Result<CheckNewVersionAppInfo, CheckNewVersionError>) -> Void
    ) {
        guard task == nil else { completion(.failure(.aleadyChecking)); return }
        
        guard let url = URL(string: "https://itunes.apple.com/us/lookup?bundleId=\(identifier)") else {
            completion(.failure(CheckNewVersionError.invalidBundleInfo))
            return
        }
        
        self.task = checkVersionRequest(for: url) { [weak self] reqResult in
            DispatchQueue.main.async {
                switch reqResult {
                case .success(let appInfo):
                    completion(.success(appInfo))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            self?.task = nil
        }
        task?.resume()
    }
}

private extension AppVersionHandler {
    func checkVersionRequest(
        for url: URL,
        completion: @escaping (Result<CheckNewVersionAppInfo, CheckNewVersionError>) -> Void
    ) -> URLSessionDataTask {
        URLSession.shared.dataTask(with: url) { data, _, error in
            do {
                if let error { throw CheckNewVersionError.networkError(error: error) }
                guard let data else { throw CheckNewVersionError.invalidResponse }
                guard
                    let lookupResult = try? JSONDecoder().decode(LookupResult.self, from: data),
                    let result = lookupResult.results.first,
                    let url = URL(string: result.trackViewUrl)
                else { throw CheckNewVersionError.invalidResponse }
                completion(.success(
                    .init(version: result.version, appStoreURL: url)
                ))
            } catch {
                let err = error as? CheckNewVersionError
                completion(.failure(err ?? .invalidResponse))
            }
        }
    }
    
    struct LookupResult: Decodable {
        struct AppInfo: Decodable {
            let version: String
            let trackViewUrl: String
        }
        
        let results: [AppInfo]
    }
}
