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

public final class NetworkStackRepositoryImpl {
    private let platform = "ios"
    private let networkCall: NetworkCall
    init(baseURL: URL, notificationsBaseURL: URL) {
        self.networkCall = NetworkCall(
            baseURL: baseURL, 
            notificationsBaseURL: notificationsBaseURL
        )
        networkCall.sslError = {
            NotificationCenter.default.post(name: .SSLNetworkErrorNotificationKey, object: nil)
        }
        networkCall.noError = {
            NotificationCenter.default.post(name: .NoNetworkErrorNotificationKey, object: nil)
        }
    }
}

extension NetworkStackRepositoryImpl: NetworkStackRepository {
    public func registerDevice(
        for name: String,
        gcmToken: String?,
        completion: @escaping (Result<RegisterDevice.ResultData, NetworkError>) -> Void
    ) {
        let req = RegisterDevice.Request()
        let reqData = RegisterDevice.RequestData(name: name, fcm_token: gcmToken, platform: platform)
        networkCall.handleCall(with: req, data: reqData, completion: completion)
    }
    
    public func pairWithWebExtension(
        for deviceID: String,
        extensionID: String,
        deviceName: String,
        devicePublicKey: String,
        completion: @escaping (Result<PairWithWebExtension.ResultData, NetworkError>) -> Void
    ) {
        let req = PairWithWebExtension.Request(deviceID: deviceID)
        let reqData = PairWithWebExtension.RequestData(
            extension_id: extensionID,
            device_name: deviceName,
            device_public_key: devicePublicKey
        )
        networkCall.handleCall(with: req, data: reqData, completion: completion)
    }
    
    public func listAllPairings(
        for deviceID: String,
        completion: @escaping (Result<[ListAllPairings.BrowserPairing], NetworkError>) -> Void
    ) {
        let req = ListAllPairings.Request(deviceID: deviceID)
        networkCall.handleCall(with: req, completion: completion)
    }
    
    public func getPairing(
        for deviceID: String,
        extensionID: String,
        completion: @escaping (Result<GetPairing.ResultData, NetworkError>) -> Void
    ) {
        let req = GetPairing.Request(deviceID: deviceID, extensionID: extensionID)
        networkCall.handleCall(with: req, completion: completion)
    }
    
    public func deletePairing(
        for deviceID: String,
        extensionID: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        let req = DeletePairing.Request(deviceID: deviceID, extensionID: extensionID)
        networkCall.handleCall(with: req, completion: completion)
    }
    
    public func deleteAllPairings(
        for deviceID: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        let req = DeleteAllPairings.Request(deviceID: deviceID)
        networkCall.handleCall(with: req, completion: completion)
    }
    
    public func updateDeviceNameToken(
        _ deviceName: String,
        gcmToken: String,
        for deviceID: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        let req = UpdateDeviceName.Request(deviceID: deviceID)
        let reqData = UpdateDeviceName.RequestData(name: deviceName, fcm_token: gcmToken, platform: platform)
        networkCall.handleCall(with: req, data: reqData, completion: completion)
    }
    
    public func listAll2FARequests(
        for deviceID: String,
        completion: @escaping (Result<ListAll2FARequests.ResultData, NetworkError>) -> Void
    ) {
        let req = ListAll2FARequests.Request(deviceID: deviceID)
        networkCall.handleCall(with: req, completion: completion)
    }
    
    public func send2FAToken(
        for deviceID: String,
        extensionID: String,
        tokenRequestID: String,
        token: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        let req = Send2FAToken.Request(deviceID: deviceID)
        let reqData = Send2FAToken.RequestData(
            extension_id: extensionID,
            token_request_id: tokenRequestID,
            token: token
        )
        networkCall.handleCall(with: req, data: reqData, completion: completion)
    }

    public func listAllNews(
        publishedAfter: String,
        completion: @escaping (Result<[ListNews.NewsEntry], NetworkError>) -> Void
    ) {
        let req = ListNews.Request(platform: "ios", publishedAfter: publishedAfter)
        networkCall.handleNotificationsCall(with: req, completion: completion)
    }
    
    public func uploadLogs(
        _ logs: String,
        auditID: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        let req = UploadLogs.Request(auditID: auditID, textLog: logs)
        networkCall.handleCall(with: req, completion: completion)
    }
}
