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
import NetworkStack

struct FetchNewVersionAppInfo {
    let version: String
    let appStoreURL: URL
}

extension MainRepositoryImpl {
    var newVersionCounter: Int {
        userDefaultsRepository.newVersionCounter
    }
    
    func setNewVersionCounter(_ counter: Int) {
        userDefaultsRepository.setNewVersionCounter(counter)
    }
    
    var newVersionTracked: String? {
        userDefaultsRepository.newVersionTracked
    }
    
    func setNewVersionTracked(_ version: String) {
        userDefaultsRepository.setNewVersionTracked(version)
    }
    
    var newVersionIgnored: String? {
        userDefaultsRepository.newVersionIgnored
    }
    
    func setNewVersionIgnored(_ version: String) {
        userDefaultsRepository.setNewVersionIgnored(version)
    }
    
    var newVersionCheckDisabled: Bool {
        userDefaultsRepository.newVersionCheckDisabled
    }
    
    func setNewVersionCheckDisabled(_ disabled: Bool) {
        userDefaultsRepository.setNewVersionCheckDisabled(disabled)
    }
    
    func fetchNewVersion(completion: @escaping (Result<FetchNewVersionAppInfo, Error>) -> Void) {
        networkStack.appVersion.checkVersion(for: "com.twofas.org") { result in
            switch result {
            case .success(let appInfo):
                completion(.success(
                    .init(version: appInfo.version, appStoreURL: appInfo.appStoreURL)
                ))
            case .failure(let error):
                completion(.failure(error))
                Log("Can't get current version from App Store. Error: \(error)")
            }
        }
    }
}
