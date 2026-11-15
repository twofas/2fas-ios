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

public enum LocalStorageCipherState: Equatable {
    case noKey
    case available
    case keyLost
    case keyUnavailable
}

public enum LocalStorageCipherError: Error, Equatable {
    case noKey
    case keyLost
    case keyUnavailable
    case unsupportedEnvelopeVersion(UInt8)
    case malformedEnvelope
}

public protocol LocalStorageCipher: AnyObject {
    var state: LocalStorageCipherState { get }
    func seal(_ plaintext: Data, associatedData: Data) throws -> Data
    func open(_ sealed: Data, associatedData: Data) throws -> Data
    func lookupHash(for value: String, context: String) throws -> Data
    /// Ensures a key exists for writing. In the main app creates the key on first use; elsewhere throws.
    func prepareForWriting() throws
}

public protocol LocalStorageKeyManaging: AnyObject {
    func createKeyIfNeeded() throws
    func discardLostKey()
}

public typealias LocalStorageCipherAdmin = LocalStorageCipher & LocalStorageKeyManaging
