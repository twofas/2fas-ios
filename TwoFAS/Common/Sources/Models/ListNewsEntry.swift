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

public struct ListNewsEntry: Hashable {
    public enum Icon: String, Decodable, Hashable {
        case updates
        case news
        case features
        case youtube
        case tips
    }
    
    public enum InternalLink {
        case backup
    }
    
    public let newsID: String
    public let icon: Icon
    public let link: URL?
    public let message: String?
    public let publishedAt: Date
    public let createdAt: Date?
    public let wasRead: Bool
    public let internalLink: InternalLink?
    public let localNotificationType: String?
    
    public init(
        newsID: String,
        icon: Icon,
        link: URL?,
        message: String?,
        publishedAt: Date,
        createdAt: Date?,
        wasRead: Bool,
        internalLink: InternalLink?,
        localNotificationType: String? = nil
    ) {
        self.newsID = newsID
        self.icon = icon
        self.link = link
        self.message = message
        self.publishedAt = publishedAt
        self.createdAt = createdAt
        self.wasRead = wasRead
        self.internalLink = internalLink
        self.localNotificationType = localNotificationType
    }
}
