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

public protocol NetworkStackRepository {
    func registerDevice(
        for name: String,
        gcmToken: String?,
        completion: @escaping (Result<RegisterDevice.ResultData, NetworkError>) -> Void
    )
    func pairWithWebExtension(
        for deviceID: String,
        extensionID: String,
        deviceName: String,
        devicePublicKey: String,
        completion: @escaping (Result<PairWithWebExtension.ResultData, NetworkError>) -> Void
    )
    func listAllPairings(
        for deviceID: String,
        completion: @escaping (Result<[ListAllPairings.BrowserPairing], NetworkError>) -> Void
    )
    func getPairing(
        for deviceID: String,
        extensionID: String,
        completion: @escaping (Result<GetPairing.ResultData, NetworkError>) -> Void
    )
    func deletePairing(
        for deviceID: String,
        extensionID: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
    func deleteAllPairings(
        for deviceID: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
    func updateDeviceNameToken(
        _ deviceName: String,
        gcmToken: String,
        for deviceID: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
    func listAll2FARequests(
        for deviceID: String,
        completion: @escaping (Result<ListAll2FARequests.ResultData, NetworkError>) -> Void
    )
    func send2FAToken(
        for deviceID: String,
        extensionID: String,
        tokenRequestID: String,
        token: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
    func listAllNews(
        publishedAfter: String,
        lang: String,
        group: String,
        noCompanionAppFrom: String?,
        completion: @escaping (Result<[ListNews.NewsEntry], NetworkError>) -> Void
    )
    func uploadLogs(
        _ logs: String,
        auditID: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
}
