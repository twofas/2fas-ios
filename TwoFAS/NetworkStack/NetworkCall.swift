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

final class NetworkCall {
    var sslError: (() -> Void)?
    var noError: (() -> Void)?
    
    private let baseURL: URL
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    private let queue = DispatchQueue(label: "io.twofas.response-queue", qos: .userInitiated, attributes: [.concurrent])
    private let configuration: URLSessionConfiguration = {
        var headers: [String: String] = [:]
        
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        headers["Accept-Encoding"] = "gzip;q=1.0, compress;q=0.5"
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = headers
        
        config.requestCachePolicy = .reloadIgnoringCacheData
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        config.networkServiceType = .responsiveData
        config.waitsForConnectivity = false
        config.allowsConstrainedNetworkAccess = true
        config.allowsExpensiveNetworkAccess = true
        config.allowsCellularAccess = true
        
        return config
    }()
    private let session: URLSession
    
    init(baseURL: URL) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: configuration)
    }
    
    func handleCall<T: Decodable>(
        with request: NetworkRequestFormat,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        queue.async { [weak self] in
            guard let self else { return }
            let dataTask = self.session.dataTask(
                with: self.urlRequest(for: request)
            ) { [weak self] data, response, error in
                self?.completionHandler(data, response as? HTTPURLResponse, error, completion: completion)
            }
            dataTask.resume()
        }
    }
    
    func handleCall(with request: NetworkRequestFormat, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        queue.async { [weak self] in
            guard let self else { return }
            let dataTask = self.session.dataTask(
                with: self.urlRequest(for: request)
            ) { [weak self] data, response, error in
                self?.completionHandler(data, response as? HTTPURLResponse, error, completion: completion)
            }
            dataTask.resume()
        }
    }
    
    func handleCall<P: Encodable, T: Decodable>(
        with request: NetworkRequestFormat,
        data: P,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        queue.async { [weak self] in
            guard let self else { return }
            let dataTask = self.session.dataTask(
                with: self.urlRequest(for: request, data: data)
            ) { [weak self] data, response, error in
                self?.completionHandler(data, response as? HTTPURLResponse, error, completion: completion)
            }
            dataTask.resume()
        }
    }
    
    func handleCall<P: Encodable>(
        with request: NetworkRequestFormat,
        data: P,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        queue.async { [weak self] in
            guard let self else { return }
            let dataTask = self.session.dataTask(
                with: self.urlRequest(for: request, data: data)
            ) { [weak self] data, response, error in
                self?.completionHandler(data, response as? HTTPURLResponse, error, completion: completion)
            }
            dataTask.resume()
        }
    }
    
    func handleCall(
        with request: NetworkMultipartRequestFormat,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        queue.async { [weak self] in
            guard let self else { return }
            let dataTask = self.session.dataTask(
                with: self.urlRequest(for: request)
            ) { [weak self] data, response, error in
                self?.completionHandler(data, response as? HTTPURLResponse, error, completion: completion)
            }
            dataTask.resume()
        }
    }
}

private extension NetworkCall {
    func completionHandler<T: Decodable>(
        _ data: Data?,
        _ urlResponse: HTTPURLResponse?,
        _ error: Error?,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard noErrorOccured(data, error, completion: completion),
              correctStatusCode(data, urlResponse, completion: completion)
        else { return }
        
        parseData(data, completion: completion)
    }
    
    func completionHandler(
        _ data: Data?,
        _ urlResponse: HTTPURLResponse?,
        _ error: Error?,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        guard noErrorOccured(data, error, completion: completion),
              correctStatusCode(data, urlResponse, completion: completion)
        else { return }
        
        successCall(completion: completion)
    }
    
    func noErrorOccured<T>(
        _ data: Data?,
        _ error: Error?,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> Bool {
        if let nsError = error, data == nil {
            let error = nsError as NSError
            if error.code == NSURLErrorSecureConnectionFailed {
                sslError?()
            } else if error.code.isNetworkError {
                noInternetCall(error: error, completion: completion)
            } else if error.code.isServerError {
                serverErrorCall(error: error, completion: completion)
            } else {
                otherErrorCall(error: error, completion: completion)
            }
            return false
        }
        return true
    }
    
    func correctStatusCode<T>(
        _ data: Data?,
        _ urlResponse: HTTPURLResponse?,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> Bool {
        guard let urlResponse else {
            otherErrorCall(error: nil, completion: completion)
            return false
        }
        
        guard urlResponse.statusCode >= 200 && urlResponse.statusCode < 300 else {
            let returnedError: ReturnedError? = {
                guard let data else { return nil }
                return try? jsonDecoder.decode(ReturnedError.self, from: data)
            }()
            serverResponseError(
                path: urlResponse.url?.absoluteString,
                status: urlResponse.statusCode,
                returnedError: returnedError,
                completion: completion
            )
            return false
        }
        return true
    }
    
    func parseData<T: Decodable>(_ data: Data?, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let responseData: T = {
            guard let data else { return nil }
            var result: T?
            do {
                result = try jsonDecoder.decode(T.self, from: data)
            } catch {
                Log("Network Stack: Parse error! error: \(error)", module: .network)
                Log(
                    "Network Stack: Data: \(String(describing: String(data: data, encoding: .utf8)))",
                    module: .network,
                    save: false
                )
            }
            return result
        }() else {
            parseError(completion: completion)
            return
        }
        successCall(responseData, completion: completion)
    }
    
    func urlRequest(for request: NetworkRequestFormat) -> URLRequest {
        let path = baseURL.absoluteString + "/" + request.path
        guard
            let url = URL(string: path)
        else { fatalError("Network Stack: Can't create path for url: \(request.path)") }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        return urlRequest
    }
    
    func urlRequest<P: Encodable>(for request: NetworkRequestFormat, data: P) -> URLRequest {
        let path = baseURL.absoluteString + "/" + request.path
        guard
            let url = URL(string: path)
        else { fatalError("Network Stack: Can't create path for url: \(request.path)") }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = try? jsonEncoder.encode(data)
        
        return urlRequest
    }
    
    func urlRequest(for request: NetworkMultipartRequestFormat) -> URLRequest {
        let path = baseURL.absoluteString + "/" + request.path
        guard
            let url = URL(string: path)
        else { fatalError("Network Stack: Can't create path for url: \(request.path)") }
        request.seal()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue("multipart/form-data; boundary=\(request.boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = request.httpBody as Data
        
        return urlRequest
    }
}

private extension NetworkCall {
    func noInternetCall<T>(error: NSError, completion: @escaping (Result<T, NetworkError>) -> Void) {
        Log("Network Stack: No internet! error: \(error)", module: .network)
        DispatchQueue.main.async {
            completion(.failure(.noInternet))
        }
    }
    
    func serverErrorCall<T>(error: NSError, completion: @escaping (Result<T, NetworkError>) -> Void) {
        Log("Network Stack: Server error! error: \(error)", module: .network)
        DispatchQueue.main.async {
            completion(.failure(.connection(error: .serverError)))
        }
    }
    
    func otherErrorCall<T>(error: NSError?, completion: @escaping (Result<T, NetworkError>) -> Void) {
        Log("Network Stack: Other error! error: \(String(describing: error))", module: .network)
        DispatchQueue.main.async {
            completion(.failure(.connection(error: .otherError)))
        }
    }
    
    func serverResponseError<T>(
        path: String?,
        status: Int,
        returnedError: ReturnedError?,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        // swiftlint:disable line_length
        Log("Network Stack: Server response error! Path: \(path ?? "<unknown>"), status: \(status), returnedError: \(String(describing: returnedError))", module: .network)
        // swiftlint:enable line_length
        DispatchQueue.main.async {
            completion(.failure(.connection(error: .serverHTTPError(status: status, error: returnedError))))
        }
    }
    
    func parseError<T>(completion: @escaping (Result<T, NetworkError>) -> Void) {
        DispatchQueue.main.async {
            completion(.failure(.connection(error: .parseError)))
        }
    }
    
    func successCall<T: Decodable>(_ responseData: T, completion: @escaping (Result<T, NetworkError>) -> Void) {
        DispatchQueue.main.async {
            completion(.success(responseData))
        }
    }
    
    func successCall(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        noError?()
        DispatchQueue.main.async {
            completion(.success(Void()))
        }
    }
}
