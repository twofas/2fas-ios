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

public enum NetworkCallError: Error {
    case noInternet
    case serverError
    case notPaired
}

extension MainRepositoryImpl {
    var hasSSLNetworkError: Bool {
        sslNetworkError
    }
    
    func markSSLNetworkError() {
        sslNetworkError = true
    }
    
    func clearSSLNetworkError() {
        sslNetworkError = false
    }
    
    func registerDevice(
        for name: String,
        gcmToken: String?,
        completion: @escaping (Result<RegisterDevice.ResultData, NetworkError>) -> Void
    ) {
        networkStack.network.registerDevice(for: name, gcmToken: gcmToken, completion: completion)
    }
    
    func pairWithWebExtension(
        for deviceID: String,
        extensionID: String,
        deviceName: String,
        devicePublicKey: String,
        completion: @escaping (Result<PairWithWebExtension.ResultData, NetworkError>) -> Void
    ) {
        networkStack.network.pairWithWebExtension(
            for: deviceID,
            extensionID: extensionID,
            deviceName: deviceName,
            devicePublicKey: devicePublicKey,
            completion: completion
        )
    }
    
    func listAllPairings(
        for deviceID: String,
        completion: @escaping (Result<ListAllPairings.ResultData, NetworkError>) -> Void
    ) {
        networkStack.network.listAllPairings(for: deviceID, completion: completion)
    }
    
    func getPairing(
        for deviceID: String,
        extensionID: String,
        completion: @escaping (Result<GetPairing.ResultData, NetworkError>) -> Void
    ) {
        networkStack.network.getPairing(for: deviceID, extensionID: extensionID, completion: completion)
    }
    
    func deletePairing(
        for deviceID: String,
        extensionID: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        networkStack.network.deletePairing(for: deviceID, extensionID: extensionID, completion: completion)
    }
    
    func deleteAllPairings(
        for deviceID: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        networkStack.network.deleteAllPairings(for: deviceID, completion: completion)
    }
    
    func updateDeviceNameToken(
        _ deviceName: String,
        gcmToken: String,
        for deviceID: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        networkStack.network.updateDeviceNameToken(
            deviceName,
            gcmToken: gcmToken,
            for: deviceID,
            completion: completion
        )
    }
    
    func listAll2FARequests(
        for deviceID: String,
        completion: @escaping (Result<ListAll2FARequests.ResultData, NetworkError>) -> Void
    ) {
        networkStack.network.listAll2FARequests(for: deviceID, completion: completion)
    }
    
    func send2FAToken(
        for deviceID: String,
        extensionID: String,
        tokenRequestID: String,
        token: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        networkStack.network.send2FAToken(
            for: deviceID,
            extensionID: extensionID,
            tokenRequestID: tokenRequestID,
            token: token,
            completion: completion
        )
    }
    
    func listAllNews(
        publishedAfter: String,
        completion: @escaping (Result<[ListNews.NewsEntry], NetworkError>) -> Void
    ) {
        networkStack.network.listAllNews(publishedAfter: publishedAfter, completion: completion)
    }
    
    func uploadLogs(
        _ logs: String,
        auditID: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        networkStack.network.uploadLogs(logs, auditID: auditID, completion: completion)
    }
}
