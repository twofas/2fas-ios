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
import CryptoKit
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

/// Loads the data key once per process. `noKey` and `keyUnavailable` are re-checked at most once per second,
/// so a key created by the main app or Keychain becoming available after the first unlock is picked up.
/// Everything that touches the key store happens under one lock; diagnostics are logged only after releasing it,
/// because saving a log can reach Storage, which calls back into the cipher.
public final class LocalStorageCipherImpl: LocalStorageCipherAdmin {
    private enum Status {
        case noKey(checkedAt: Date)
        case available(LocalStorageCipherCore)
        case keyLost
        case keyUnavailable(checkedAt: Date)
    }

    private static let recheckInterval: TimeInterval = 1

    private let keyStore: LocalStorageKeyStore
    private let canCreateKey: Bool
    private let now: () -> Date
    private let lock = NSLock()
    private var status: Status?
    /// The stored key ID at the time `status` was loaded
    private var loadedKeyID: String?

    init(keyStore: LocalStorageKeyStore, canCreateKey: Bool, now: @escaping () -> Date = Date.init) {
        self.keyStore = keyStore
        self.canCreateKey = canCreateKey
        self.now = now
    }

    public var state: LocalStorageCipherState {
        var diagnostics: [String] = []
        defer { Self.log(diagnostics) }
        return switch lock.withLock({ currentStatus(diagnostics: &diagnostics) }) {
        case .noKey: .noKey
        case .available: .available
        case .keyLost: .keyLost
        case .keyUnavailable: .keyUnavailable
        }
    }

    public func seal(_ plaintext: Data, associatedData: Data) throws -> Data {
        try core(creatingKey: canCreateKey).seal(plaintext, associatedData: associatedData)
    }

    public func open(_ sealed: Data, associatedData: Data) throws -> Data {
        try core(creatingKey: false).open(sealed, associatedData: associatedData)
    }

    public func lookupHash(for value: String, context: String) throws -> Data {
        try core(creatingKey: false).lookupHash(for: value, context: context)
    }

    /// Creates the key in `.noKey` like the first `seal` does (main app only)
    public func prepareForWriting() throws {
        _ = try core(creatingKey: canCreateKey)
    }

    public func createKeyIfNeeded() throws {
        guard canCreateKey else {
            assertionFailure("Only the main app can create the local storage key")
            throw LocalStorageCipherError.noKey
        }
        _ = try core(creatingKey: true)
    }

    public func discardLostKey() {
        lock.withLock {
            keyStore.discardKeyID()
            status = .noKey(checkedAt: now())
            loadedKeyID = nil
        }
    }

    /// For a process that outlives a reset of the local data in the main app (an extension): `.available` and
    /// `.keyLost` aren't re-checked on their own. Forgets the loaded key when the stored key ID is another one
    /// (or the key was lost – it may have been replaced), so the next use loads the current key.
    /// - Returns: Whether the key ID changed – the stores were replaced along with the key.
    public func reloadKeyIfChanged() -> Bool {
        lock.withLock {
            guard let status else { return false }
            let isChanged = keyStore.storedKeyID != loadedKeyID
            let isLost = if case .keyLost = status { true } else { false }
            if isChanged || isLost {
                self.status = nil
            }
            return isChanged
        }
    }

    // MARK: - Private

    private func core(creatingKey: Bool) throws -> LocalStorageCipherCore {
        var diagnostics: [String] = []
        defer { Self.log(diagnostics) }
        return try lock.withLock {
            switch currentStatus(diagnostics: &diagnostics) {
            case .available(let core):
                return core
            case .noKey:
                guard creatingKey else { throw LocalStorageCipherError.noKey }
                return try createCore(diagnostics: &diagnostics)
            case .keyLost:
                throw LocalStorageCipherError.keyLost
            case .keyUnavailable:
                throw LocalStorageCipherError.keyUnavailable
            }
        }
    }

    /// Has to be called while holding the lock. Store errors never leave the cipher - callers only handle
    /// `LocalStorageCipherError`. The status stays `noKey`, so the next call tries again.
    private func createCore(diagnostics: inout [String]) throws -> LocalStorageCipherCore {
        let dataKey: SymmetricKey
        do {
            dataKey = try keyStore.create { diagnostics.append($0) }
        } catch {
            diagnostics.append("Can't create local storage key: \(LocalStorageKeyStore.describe(error))")
            throw LocalStorageCipherError.keyUnavailable
        }
        let core = LocalStorageCipherCore(dataKey: dataKey)
        status = .available(core)
        loadedKeyID = keyStore.storedKeyID
        return core
    }

    /// Has to be called while holding the lock
    private func currentStatus(diagnostics: inout [String]) -> Status {
        if let status, !needsRecheck(status) {
            return status
        }
        let checkedAt = now()
        loadedKeyID = keyStore.storedKeyID
        let status: Status = switch keyStore.load(report: { diagnostics.append($0) }) {
        case .noKey: .noKey(checkedAt: checkedAt)
        case .loaded(let dataKey): .available(LocalStorageCipherCore(dataKey: dataKey))
        case .lost: .keyLost
        case .unavailable: .keyUnavailable(checkedAt: checkedAt)
        }
        self.status = status
        return status
    }

    private func needsRecheck(_ status: Status) -> Bool {
        switch status {
        case .available, .keyLost:
            false
        case .noKey(let checkedAt), .keyUnavailable(let checkedAt):
            now().timeIntervalSince(checkedAt) >= Self.recheckInterval
        }
    }

    /// Must not be called while holding the lock
    private static func log(_ diagnostics: [String]) {
        diagnostics.forEach { Log("LocalStorageCipher - \($0)", module: .protection, severity: .warning) }
    }
}
