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

import Foundation
import CoreData
import CryptoKit
@testable import Common
@testable import Protection

func makeTemporaryDirectory() -> URL {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}

func makeTestCipher() -> LocalStorageCipherCore {
    LocalStorageCipherCore(dataKey: SymmetricKey(size: .bits256))
}

func rawStoreBytes(name: String, in directory: URL) -> Data {
    var data = (try? Data(contentsOf: directory.appendingPathComponent("\(name).sqlite"))) ?? Data()
    if let wal = try? Data(contentsOf: directory.appendingPathComponent("\(name).sqlite-wal")) {
        data.append(wal)
    }
    return data
}

/// Closes the SQLite files now. Releasing the stack isn't enough – it may outlive `tearDown` in an autorelease pool,
/// and deleting the files of an open store makes SQLite report an API violation.
func closeStores(of stack: CoreDataStack) {
    guard let coordinator = stack.context.persistentStoreCoordinator else { return }
    stack.context.reset()
    for store in coordinator.persistentStores {
        try? coordinator.remove(store)
    }
}
