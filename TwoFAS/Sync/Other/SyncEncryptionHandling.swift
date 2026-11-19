//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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
import CryptoKit

/// What the Info record carries about the encryption, besides its type and reference. None of it is secret:
/// the salt and the parameters let a device that has only the password derive the user's key, and the key of the
/// record identifiers is sealed with the sync key.
struct SyncCloudEncryptionInfo: Equatable {
    var kdfSalt: Data?
    /// `SyncKDFParameters`, encoded
    var kdfParameters: Data?
    /// `SyncIdentifierKey`, sealed with the sync key
    var wrappedIdentifierKey: Data?

    static let empty = SyncCloudEncryptionInfo()
}

protocol SyncEncryptionHandling: AnyObject {
    var encryptionReference: Data? { get }
    /// The current sync key (the system key or the user's key) – what the sealed records are sealed with
    var recordKey: SymmetricKey? { get }
    /// The key the record names are derived with. `nil` when the cloud has none yet or it can't be opened with
    /// the current sync key.
    var identifierKey: SyncIdentifierKey? { get }
    /// Creates the key of the record identifiers when the cloud has none yet.
    /// - Returns: Whether there is a key now.
    @discardableResult
    func createIdentifierKeyIfNeeded() -> Bool
    /// What the Info record should carry now. `cached` is what it carried when it was last fetched – kept for
    /// everything this device has nothing better for.
    func cloudEncryptionInfo(cached: SyncCloudEncryptionInfo) -> SyncCloudEncryptionInfo
    /// The Info record that was fetched (or is cached) carries `info`
    func cloudEncryptionInfoFetched(_ info: SyncCloudEncryptionInfo)
    var hasCompleteEncryptionElements: Bool { get }
    var hasSystemEncryptionElements: Bool { get }
    
    func encrypt(_ data: Data) -> Data?
    func decrypt(_ data: Data) -> Data?
    func verifyUserPassword(_ password: String) -> Bool
}
