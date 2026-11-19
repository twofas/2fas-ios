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

public protocol CommonServiceHandler: AnyObject {
    typealias CommonDidDelete = (String) -> Void
    typealias CommonDidModify = ([String]) -> Void
    typealias CommonDidCreate = (String) -> Void
    
    var commonDidDelete: CommonDidDelete? { get set }
    var commonDidModify: CommonDidModify? { get set }
    var commonDidCreate: CommonDidCreate? { get set }
        
    func setServices(_ servicesservices: [ServiceData]) -> Bool
    func getAllServices() -> [ServiceData]
    
    /// Sets the services that are in the cloud, deciding about deletions by their records only: a service that
    /// isn't in the cloud is deleted here only when the cloud has the record of its deletion.
    func setServices(_ services: [ServiceData], deletions: SyncedDeletions) -> Bool
    /// The records of the services deleted here
    func getAllServiceDeletions() -> [CommonServiceDeletion]
}

/// The deletions known to the cloud, handed over with the state of the cloud
public struct SyncedDeletions {
    /// When a service was deleted, by the identifier of its deletion
    public let services: [Data: Date]
    /// The identifier of the deletion of a service, by its secret
    public let serviceIdentifier: (String) -> Data
    /// When a section was deleted, by its ID
    public let sections: [String: Date]
    /// `false` on a device that only mirrors the cloud (the watch): what the cloud doesn't have is removed there.
    /// Otherwise an item without the record of its deletion stays and is sent to the cloud.
    public let keepsLocalOnlyItems: Bool
    
    public init(
        services: [Data: Date],
        serviceIdentifier: @escaping (String) -> Data,
        sections: [String: Date],
        keepsLocalOnlyItems: Bool
    ) {
        self.services = services
        self.serviceIdentifier = serviceIdentifier
        self.sections = sections
        self.keepsLocalOnlyItems = keepsLocalOnlyItems
    }
}

/// The record of a service deleted on this device
public struct CommonServiceDeletion: Hashable {
    /// `nil` once the deletion is known to the cloud – `syncID` identifies it then
    public let secret: String?
    public let syncID: Data?
    public let deletedAt: Date
    
    public init(secret: String?, syncID: Data?, deletedAt: Date) {
        self.secret = secret
        self.syncID = syncID
        self.deletedAt = deletedAt
    }
}

/// The record of a section deleted on this device
public struct CommonSectionDeletion: Hashable {
    public let sectionID: String
    public let deletedAt: Date
    
    public init(sectionID: String, deletedAt: Date) {
        self.sectionID = sectionID
        self.deletedAt = deletedAt
    }
}
