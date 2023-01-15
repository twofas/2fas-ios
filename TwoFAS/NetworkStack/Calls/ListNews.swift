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

public enum ListNews {
    public struct Request: NetworkRequestFormat {
        let platform: String
        let publishedAfter: String
        
        let method: HTTPMethod = .GET
        var path: String {
            let path = "mobile/notifications"
            var params: [String] = []
            if let platform = platform.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                params.append("platform=\(platform)")
            }
            if let publishedAfter = publishedAfter.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                params.append("published_after=\(publishedAfter)")
            }
            if params.isEmpty {
                return path
            }
            return path + "?" + params.joined(separator: "&")
        }
    }
        
    typealias ResultData = [NewsEntry]
    
    public struct NewsEntry: Decodable {
        public let id: String
        public let icon: String
        public let link: String?
        public let message: String?
        public let publishedAt: String
        public let createdAt: String?
    }
}
