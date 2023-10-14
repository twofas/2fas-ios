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

final class CoreDataMigrationVersionList {
    private let versions: [CoreDataMigrationVersion]
    
    init(versions: [CoreDataMigrationVersion]) {
        self.versions = versions
    }
    
    var current: CoreDataMigrationVersion {
        guard let latest = versions.last else {
            fatalError("No model versions found")
        }

        return latest
    }
    
    func first(where predicate: (CoreDataMigrationVersion) -> Bool) -> CoreDataMigrationVersion? {
        for v in versions {
            if predicate(v) { return v }
        }
        return nil
    }
    
    func nextVersion(for version: CoreDataMigrationVersion) -> CoreDataMigrationVersion? {
        guard let index = versions.firstIndex(where: { $0 == version }) else { return nil }
        return versions[safe: index + 1]
    }
    
    func isCurrentVersion(for compareVersion: CoreDataMigrationVersion) -> Bool {
        current == compareVersion
    }
}

public final class CoreDataMigrationVersion: Equatable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public static func == (lhs: CoreDataMigrationVersion, rhs: CoreDataMigrationVersion) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
