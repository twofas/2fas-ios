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
import KeychainAccess
import SignalArgon2
import CryptoKit
import Common

final class SyncEncryptionHandler {
    enum CreationError: Error {
        case cantCreateSalt
        case cantCreateSystemKey
        case missingUserKey
    }
    
    var keyDidChange: Callback?
    
    private let keychain: Keychain
    /// Never leaves this device – for the stand-in system key
    private let localKeychain: Keychain
    private let userDefaults: UserDefaults
    
    private let systemKeyKey = "io.twofas.systemKeyKey"
    private let localSystemKeyKey = "io.twofas.localSystemKeyKey"
    private let userKeyKey = "io.twofas.userKeyKey"
    private let usedKeyKey = "io.twofas.usedKeyKey"
    private let saltKey = "io.twofas.saltKey"
    private let kdfParametersKey = "io.twofas.kdfParametersKey"
    private static let saltByteCount = 16
    
    private let reference: Data
    
    private var cachedSalt: Data?
    private var cachedSystemKey: SymmetricKey?
    /// `cachedSystemKey` is a stand-in made on this device because the real one – shared through the iCloud
    /// Keychain – wasn't there when the user's key was recovered with the password. It only seals what this
    /// device stores (the user's key, which key is used). It's never put into the iCloud Keychain, where it
    /// would compete with the real key on the other devices; when the real one arrives, it replaces it.
    private(set) var usesLocalSystemKey = false
    private var cachedUsedKey: Info.Encryption = .system
    private var cachedUserKey: SymmetricKey?
    private var cachedEncryptionReference: Data?
    
    /// What the Info record carried when it was last fetched
    private var cloudInfo = SyncCloudEncryptionInfo.empty
    private var cachedIdentifierKey: SyncIdentifierKey?
    
    private let localEncryptionKey: SymmetricKey
    
    init(
        reference: Data,
        localEncryptionKeyData: Data,
        keychainService: String = Config.keychainSync,
        userDefaults: UserDefaults = .standard
    ) {
        self.reference = reference
        self.localEncryptionKey = SymmetricKey(data: localEncryptionKeyData)
        self.keychain = Keychain(service: keychainService)
            .synchronizable(true)
            .accessibility(.afterFirstUnlock)
        self.localKeychain = Keychain(service: keychainService)
            .synchronizable(false)
            .accessibility(.afterFirstUnlockThisDeviceOnly)
        self.userDefaults = userDefaults
    }
    
    func initialize() {
        if let savedSalt = keychain[data: saltKey] {
            cachedSalt = savedSalt
        }
        
        let localSystemKey = localKeychain[data: localSystemKeyKey].map { SymmetricKey(data: $0) }
        if let savedSystemKey = keychain[data: systemKeyKey] {
            let systemKey = SymmetricKey(data: savedSystemKey)
            if let localSystemKey {
                // The real key arrived – what the stand-in sealed is sealed with it from now on
                adoptSystemKey(systemKey, replacing: localSystemKey)
            } else {
                cachedSystemKey = systemKey
                usesLocalSystemKey = false
            }
        } else if let localSystemKey {
            cachedSystemKey = localSystemKey
            usesLocalSystemKey = true
        }
        
        if let usedKeyValue = usedKey() {
            if usedKeyValue == .user {
                if let userKeyValue = userKey() {
                    cachedUserKey = SymmetricKey(data: userKeyValue)
                }
            }
            cachedUsedKey = usedKeyValue
        }
        
        cachedEncryptionReference = encrypt(reference)
    }
    
    /// Makes sure there is a salt and a system key, and uses the system key. What exists is never replaced: both
    /// are shared by all devices of the user through the iCloud Keychain, and everything in the cloud that was
    /// sealed with them would be lost with them.
    func create() -> Result<Void, CreationError> {
        if cachedSalt == nil {
            guard let createdSalt = createSalt() else {
                Log("SyncEncryptionHandler: Can't create salt!", module: .cloudSync, severity: .error)
                return .failure(.cantCreateSalt)
            }
            keychain[data: saltKey] = createdSalt
            cachedSalt = createdSalt
        }
        
        if cachedSystemKey == nil || usesLocalSystemKey {
            // A stand-in key can't be the key of the cloud – the other devices don't have it
            guard let keyData = Self.randomKeyData() else {
                Log("SyncEncryptionHandler: Can't create system key!", module: .cloudSync, severity: .error)
                return .failure(.cantCreateSystemKey)
            }
            keychain[data: systemKeyKey] = keyData
            let systemKey = SymmetricKey(data: keyData)
            if usesLocalSystemKey, let localSystemKey = cachedSystemKey {
                adoptSystemKey(systemKey, replacing: localSystemKey)
            } else {
                cachedSystemKey = systemKey
            }
        }
        
        cachedUsedKey = .system
        setUsedKey(.system)
        
        cachedEncryptionReference = encrypt(reference)
        
        return .success(())
    }
    
    /// Seals what `oldKey` sealed on this device (the user's key, which key is used) with `systemKey` and
    /// forgets the stand-in key.
    private func adoptSystemKey(_ systemKey: SymmetricKey, replacing oldKey: SymmetricKey) {
        cachedSystemKey = oldKey
        let storedUserKey = userKey()
        let storedUsedKey = usedKey()
        cachedSystemKey = systemKey
        usesLocalSystemKey = false
        if let storedUserKey {
            saveUserKey(storedUserKey)
        }
        if let storedUsedKey {
            setUsedKey(storedUsedKey)
        }
        localKeychain[data: localSystemKeyKey] = nil
        Log("SyncEncryptionHandler: the system key replaced the local stand-in", module: .cloudSync)
    }
    
    private static func randomKeyData() -> Data? {
        var keyData = Data(count: 32)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
        }
        return result == errSecSuccess ? keyData : nil
    }
    
    /// Brings back the user's key on a device that doesn't have it, from the password: the key is derived with
    /// the salt and the parameters the Info record carries and checked against the encryption reference of the
    /// cloud. Nothing changes when the password is wrong.
    ///
    /// On a device that has no system key either (no iCloud Keychain) a local one is created – the user's key is
    /// kept sealed with it.
    /// - Parameter cloudReference: The encryption reference of the Info record.
    /// - Returns: Whether the password opened the reference and the key is in use now.
    func recoverUserKey(password: String, cloudReference: Data?) -> Bool {
        guard let cloudReference else {
            Log("SyncEncryptionHandler: No reference to check the password with", module: .cloudSync, severity: .error)
            return false
        }
        let recovered = deriveUserKey(
            password: password,
            cloudReference: cloudReference,
            candidates: recoveryCandidates()
        )
        return applyRecoveredUserKey(recovered)
    }
    
    /// `recoverUserKey(password:cloudReference:)` with the key derived off the calling thread – deriving takes
    /// a noticeable moment, and several salts and parameters may have to be tried. Has to be called on the main
    /// thread; `completion` is called there too.
    func recoverUserKey(password: String, cloudReference: Data?, completion: @escaping (Bool) -> Void) {
        guard let cloudReference else {
            Log("SyncEncryptionHandler: No reference to check the password with", module: .cloudSync, severity: .error)
            completion(false)
            return
        }
        // Read here – deriving touches nothing of the handler that can change
        let candidates = recoveryCandidates()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let recovered = self?.deriveUserKey(
                password: password,
                cloudReference: cloudReference,
                candidates: candidates
            )
            DispatchQueue.main.async {
                completion(self?.applyRecoveredUserKey(recovered) ?? false)
            }
        }
    }
    
    private struct RecoveryCandidate: Equatable {
        let salt: Data
        let parameters: SyncKDFParameters
    }
    
    private struct RecoveredUserKey {
        let key: Data
        let salt: Data
        let parameters: SyncKDFParameters
    }
    
    /// What the key of the cloud may have been derived with. What the cloud says comes first: the salt or the
    /// parameters kept on this device may be those of another key.
    private func recoveryCandidates() -> [RecoveryCandidate] {
        let cloudParameters = cloudInfo.kdfParameters
            .flatMap { SyncKDFParameters(encoded: $0) }
            .flatMap { $0.isSupported ? $0 : nil }
        let salts = [cloudInfo.kdfSalt, cachedSalt.map { Data($0.prefix(Self.saltByteCount)) }]
            .compactMap { $0 }
            .filter { $0.count == Self.saltByteCount }
        var candidates: [RecoveryCandidate] = []
        for salt in salts {
            for parameters in [cloudParameters, userKeyParameters, .legacy].compactMap({ $0 }) {
                let candidate = RecoveryCandidate(salt: salt, parameters: parameters)
                if !candidates.contains(candidate) {
                    candidates.append(candidate)
                }
            }
        }
        return candidates
    }
    
    /// The first candidate whose key opens the encryption reference of the cloud. Reads nothing of the handler
    /// that changes – can run off the main thread.
    private func deriveUserKey(
        password: String,
        cloudReference: Data,
        candidates: [RecoveryCandidate]
    ) -> RecoveredUserKey? {
        for candidate in candidates {
            guard let key = generateKey(for: password, parameters: candidate.parameters, salt: candidate.salt),
                  decrypt(cloudReference, using: SymmetricKey(data: key)) == reference else { continue }
            return RecoveredUserKey(key: key, salt: candidate.salt, parameters: candidate.parameters)
        }
        return nil
    }
    
    private func applyRecoveredUserKey(_ recovered: RecoveredUserKey?) -> Bool {
        guard let recovered else {
            Log("SyncEncryptionHandler: The password doesn't open the cloud", module: .cloudSync)
            return false
        }
        if cachedSystemKey == nil {
            // The real system key isn't here (the iCloud Keychain is off, or it didn't deliver it yet). A
            // stand-in that stays on this device seals the user's key; a new key put into the iCloud Keychain
            // could replace the real one on the other devices.
            guard let keyData = Self.randomKeyData() else { return false }
            localKeychain[data: localSystemKeyKey] = keyData
            cachedSystemKey = SymmetricKey(data: keyData)
            usesLocalSystemKey = true
        }
        if cachedSalt.map({ Data($0.prefix(Self.saltByteCount)) }) != recovered.salt {
            // The salt of the cloud – this device derives the same key from now on
            keychain[data: saltKey] = recovered.salt
            cachedSalt = recovered.salt
        }
        saveUserKeyParameters(recovered.parameters)
        saveUserKey(recovered.key)
        cachedUserKey = SymmetricKey(data: recovered.key)
        setUsedKey(.user)
        cachedUsedKey = .user
        cachedIdentifierKey = nil
        cachedEncryptionReference = encrypt(reference)
        return true
    }
    
    func exportKeys() -> (salt: Data, systemKey: Data)? {
        guard let salt = keychain[data: saltKey], let systemKey = keychain[data: systemKeyKey]  else {
            Log(
                "SyncEncryptionHandler: Cannot export keys – salt or system key missing",
                module: .cloudSync,
                severity: .error
            )
            return nil
        }
        return (salt, systemKey)
    }
    
    /// Takes the salt and the system key from an exported file. Nothing is written before the keys are checked
    /// against the cloud, where that's possible: they replace what every device of the user has in the iCloud
    /// Keychain.
    /// - Parameters:
    ///   - cloudReference: The encryption reference of the Info record, `nil` when the cloud wasn't read yet.
    ///   - cloudEncryption: The key the cloud is sealed with, `nil` when the cloud wasn't read yet.
    @discardableResult
    func importKeys(
        salt: Data,
        systemKey: Data,
        password: String?,
        cloudReference: Data? = nil,
        cloudEncryption: Info.Encryption? = nil
    ) -> CloudKeysImportResult {
        Log("SyncEncryptionHandler: importing keys, has password: \(password != nil)")
        guard systemKey.count == 32, salt.count >= Self.saltByteCount else {
            Log("SyncEncryptionHandler: imported keys have unexpected sizes", module: .cloudSync, severity: .error)
            return .invalidKeys
        }
        var derived = ImportedUserKey.none
        if let password {
            derived = Self.importedUserKey(
                password: password,
                salt: salt,
                parameterSets: importParameterSets,
                cloudReference: cloudReference,
                reference: reference
            )
        }
        return finishImport(
            salt: salt,
            systemKey: systemKey,
            password: password,
            cloudReference: cloudReference,
            cloudEncryption: cloudEncryption,
            derived: derived
        )
    }
    
    /// `importKeys` with the key of the password derived off the calling thread – deriving takes a noticeable
    /// moment and two sets of parameters may have to be tried. Has to be called on the main thread; `completion`
    /// is called there too.
    func importKeys(
        salt: Data,
        systemKey: Data,
        password: String?,
        cloudReference: Data?,
        cloudEncryption: Info.Encryption?,
        completion: @escaping (CloudKeysImportResult) -> Void
    ) {
        guard let password, systemKey.count == 32, salt.count >= Self.saltByteCount else {
            // Nothing to derive
            completion(importKeys(
                salt: salt,
                systemKey: systemKey,
                password: password,
                cloudReference: cloudReference,
                cloudEncryption: cloudEncryption
            ))
            return
        }
        Log("SyncEncryptionHandler: importing keys, has password: true")
        // Read here – deriving touches nothing of the handler
        let parameterSets = importParameterSets
        let reference = reference
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let derived = Self.importedUserKey(
                password: password,
                salt: salt,
                parameterSets: parameterSets,
                cloudReference: cloudReference,
                reference: reference
            )
            DispatchQueue.main.async {
                guard let self else { return }
                completion(self.finishImport(
                    salt: salt,
                    systemKey: systemKey,
                    password: password,
                    cloudReference: cloudReference,
                    cloudEncryption: cloudEncryption,
                    derived: derived
                ))
            }
        }
    }
    
    private enum ImportedUserKey {
        /// No password – no user's key
        case none
        case key(Data, SyncKDFParameters)
        case failure(CloudKeysImportResult)
    }
    
    /// What the cloud says the user's key was derived with, then what was used before that was stored
    private var importParameterSets: [SyncKDFParameters] {
        let cloudParameters = cloudInfo.kdfParameters
            .flatMap { SyncKDFParameters(encoded: $0) }
            .flatMap { $0.isSupported ? $0 : nil }
        return [cloudParameters, .legacy].compactMap { $0 }
    }
    
    /// The user's key of an imported file – checked against the cloud when its reference is known. Touches
    /// nothing of the handler – can be called on any thread.
    private static func importedUserKey(
        password: String,
        salt: Data,
        parameterSets: [SyncKDFParameters],
        cloudReference: Data?,
        reference: Data
    ) -> ImportedUserKey {
        let importedSalt = Data(salt.prefix(saltByteCount))
        if let cloudReference {
            for parameters in parameterSets {
                guard let key = deriveKey(for: password, parameters: parameters, salt: importedSalt),
                      open(cloudReference, using: SymmetricKey(data: key)) == reference else { continue }
                return .key(key, parameters)
            }
            return .failure(.doesNotOpenBackup)
        }
        // Nothing to check against yet – the first sync does
        guard let parameters = parameterSets.first else { return .none }
        guard let key = deriveKey(for: password, parameters: parameters, salt: importedSalt) else {
            return .failure(.invalidKeys)
        }
        return .key(key, parameters)
    }
    
    private static func open(_ data: Data, using key: SymmetricKey) -> Data? {
        guard let sealedBox = try? AES.GCM.SealedBox(combined: data) else { return nil }
        return try? AES.GCM.open(sealedBox, using: key)
    }
    
    /// The part of an import that writes: only when `derived` isn't a failure and, without a password, the system
    /// key opens a cloud sealed with it
    private func finishImport(
        salt: Data,
        systemKey: Data,
        password: String?,
        cloudReference: Data?,
        cloudEncryption: Info.Encryption?,
        derived: ImportedUserKey
    ) -> CloudKeysImportResult {
        let importedSystemKey = SymmetricKey(data: systemKey)
        var userKey: Data?
        var userKeyParameters: SyncKDFParameters?
        switch derived {
        case .failure(let result):
            return result
        case .key(let key, let parameters):
            userKey = key
            userKeyParameters = parameters
        case .none:
            if password == nil, let cloudReference, cloudEncryption == .system {
                guard decrypt(cloudReference, using: importedSystemKey) == reference else {
                    return .doesNotOpenBackup
                }
            }
        }
        // A cloud sealed with a password and a file imported without one: the system key seals nothing in the
        // cloud that it could be checked against.
        
        let previousSystemKey = cachedSystemKey
        let hadLocalSystemKey = usesLocalSystemKey
        keychain[data: saltKey] = salt
        cachedSalt = salt
        keychain[data: systemKeyKey] = systemKey
        if hadLocalSystemKey, let previousSystemKey {
            adoptSystemKey(importedSystemKey, replacing: previousSystemKey)
        } else {
            cachedSystemKey = importedSystemKey
            usesLocalSystemKey = false
        }
        
        if let userKey {
            saveUserKeyParameters(userKeyParameters)
            saveUserKey(userKey)
            setUsedKey(.user)
        } else if password == nil, cloudEncryption != .user {
            setUsedKey(.system)
        }
        cachedIdentifierKey = nil
        initialize()
        if cachedUsedKey == .user {
            keyDidChange?()
        }
        return .imported
    }
    
    func debugReloadAllKeys() {
        removeSystemEncryptionElements()
        userDefaults.removeObject(forKey: userKeyKey)
        cachedUserKey = nil
        _ = create()
    }
    
    /// Forgets the salt and the system key – `create()` never replaces the ones that exist
    func removeSystemEncryptionElements() {
        keychain[data: saltKey] = nil
        keychain[data: systemKeyKey] = nil
        localKeychain[data: localSystemKeyKey] = nil
        cachedSalt = nil
        cachedSystemKey = nil
        usesLocalSystemKey = false
    }
}

extension SyncEncryptionHandler: SyncEncryptionHandling {
    var hasCompleteEncryptionElements: Bool {
        if usedKey() == .user {
            hasSystemEncryptionElements && userKey() != nil
        } else {
            hasSystemEncryptionElements
        }
    }
    
    var hasSystemEncryptionElements: Bool {
        cachedSalt != nil && cachedSystemKey != nil
    }
    
    func verifyUserPassword(_ password: String) -> Bool {
        guard canVerifyUserPassword else { return false }
        return isUserKeyValid(generateKey(for: password))
    }
    
    /// `verifyUserPassword(_:)` with the key derived off the calling thread. Has to be called on the main thread;
    /// `completion` is called there too.
    func verifyUserPassword(_ password: String, completion: @escaping (Bool) -> Void) {
        guard canVerifyUserPassword else {
            completion(false)
            return
        }
        deriveUserKey(for: password) { [weak self] key in
            completion(self?.isUserKeyValid(key) ?? false)
        }
    }
    
    /// The key of `password`, derived off the calling thread – deriving takes a noticeable moment. Has to be
    /// called on the main thread; `completion` is called there too, with `nil` when the key can't be derived.
    /// - Parameter parameters: `nil` – what the current user's key was derived with (to derive the same key).
    func deriveUserKey(
        for password: String,
        parameters: SyncKDFParameters? = nil,
        completion: @escaping (Data?) -> Void
    ) {
        // Read here – deriving touches nothing of the handler
        let parameters = parameters ?? userKeyParameters
        let salt = kdfSalt
        DispatchQueue.global(qos: .userInitiated).async {
            let key = Self.deriveKey(for: password, parameters: parameters, salt: salt)
            DispatchQueue.main.async {
                completion(key)
            }
        }
    }
    
    private var canVerifyUserPassword: Bool {
        guard usedKey() == .user else {
            Log(
                "SyncEncryptionHandler: Using system encryption - can't verify password",
                module: .cloudSync,
                severity: .error
            )
            return false
        }
        guard cachedEncryptionReference != nil else {
            Log(
                "SyncEncryptionHandler: No cached encryption reference",
                module: .cloudSync,
                severity: .error
            )
            return false
        }
        return true
    }
    
    /// Whether `key` opens the current encryption reference
    private func isUserKeyValid(_ key: Data?) -> Bool {
        guard let cachedEncryptionReference else { return false }
        guard let key else {
            Log("SyncEncryptionHandler: Can't recreate user key for verification", module: .cloudSync, severity: .error)
            return false
        }
        guard let data = decrypt(cachedEncryptionReference, using: SymmetricKey(data: key)) else {
            Log("SyncEncryptionHandler: Can't decrypt reference for verification", module: .cloudSync)
            return false
        }
        return data == reference
    }
    
    func setUserPassword(_ password: String) {
        // A new key never gets weaker parameters than the current ones, whatever the old key was derived with
        guard let key = generateKey(for: password, parameters: .current) else {
            Log("SyncEncryptionHandler: Can't create user key!", module: .cloudSync, severity: .error)
            return
        }
        setUserKey(key)
    }
    
    /// Touches nothing of the handler – can be called on any thread
    static func deriveKey(for password: String, parameters: SyncKDFParameters, salt: Data?) -> Data? {
        guard parameters.isSupported else {
            Log("SyncEncryptionHandler: Unsupported key derivation parameters", module: .cloudSync, severity: .error)
            return nil
        }
        guard let hexPassword = normalizeStringIntoHEXData(password) else {
            Log("SyncEncryptionHandler: Can't create HEX from Password", module: .cloudSync, severity: .error)
            return nil
        }
        
        guard let passwordData = Data(hexString: hexPassword) else {
            Log("SyncEncryptionHandler: Can't create HEX from Key", module: .cloudSync, severity: .error)
            return nil
        }
        guard let partOfSalt = salt else {
            Log("SyncEncryptionHandler: Cant' get salt!", module: .cloudSync, severity: .error)
            return nil
        }
        do {
            let (rawHash, _) = try Argon2.hash(
                iterations: UInt32(parameters.iterations),
                memoryInKiB: UInt32(parameters.memoryKiB),
                threads: UInt32(parameters.parallelism),
                password: passwordData,
                salt: partOfSalt,
                desiredLength: parameters.keyLength,
                variant: .id,
                version: .v13
            )
            return rawHash
        } catch {
            Log("SyncEncryptionHandler: Can't create key, error: \(error)", module: .cloudSync, severity: .error)
        }
        return nil
    }
    
    private static func normalizeStringIntoHEXData(_ string: String) -> String? {
        let normalized = string.decomposedStringWithCompatibilityMapping
        return normalized.data(using: .utf8)?
            .hexEncodedString()
    }
    
    /// What `setUserPassword(_:)` does with the key of the password, derived with the current parameters
    /// (`SyncKDFParameters.current`)
    func setUserKey(_ key: Data) {
        // Opened with the key that is replaced now – the identifiers of the records stay the same
        _ = identifierKey
        saveUserKeyParameters(.current)
        saveUserKey(key)
        cachedUserKey = SymmetricKey(data: key)
        
        setUsedKey(.user)
        cachedUsedKey = .user
        
        cachedEncryptionReference = encrypt(reference)
        keyDidChange?()
    }
    
    func setSystemKey() {
        // Opened with the key that is replaced now – the identifiers of the records stay the same
        _ = identifierKey
        saveUserKey(nil)
        saveUserKeyParameters(nil)
        cachedUserKey = nil
        
        setUsedKey(.system)
        cachedUsedKey = .system
        
        cachedEncryptionReference = encrypt(reference)
        keyDidChange?()
    }
    
    func encrypt(_ data: Data) -> Data? {
        guard let currentKey else {
            Log("Error while encrypting: no current key!", module: .cloudSync, severity: .error)
            return nil
        }
        guard let encrypted = encrypt(data, using: currentKey) else {
            return nil
        }
        return encrypted
    }
    
    func decrypt(_ data: Data) -> Data? {
        guard let currentKey else {
            Log("Error while decrypting: no current key!", module: .cloudSync, severity: .error)
            return nil
        }
        
        return decrypt(data, using: currentKey)
    }
    
    var encryptionReference: Data? {
        cachedEncryptionReference
    }
    
    var encryptionType: Info.Encryption {
        cachedUsedKey
    }
    
    /// The user's key for the paired watch `deviceCode`, sealed with the system key – the watch has that one from
    /// the iCloud Keychain, and nobody who only sees the Info record does. `nil` when the user's key isn't used.
    func watchTicket(for deviceCode: DeviceCode) -> Data? {
        // A ticket sealed with a stand-in key couldn't be opened by the watch – it has the real one
        guard !usesLocalSystemKey, usedKey() == .user, let userKey = userKey(), let cachedSystemKey else {
            return nil
        }
        do {
            return try SyncWatchTicket.seal(userKey: userKey, systemKey: cachedSystemKey, deviceCode: deviceCode.code)
        } catch {
            Log("SyncEncryptionHandler: Can't seal the watch ticket", module: .cloudSync, severity: .error)
            return nil
        }
    }
    
    // MARK: - Encryption info of the Info record
    
    var recordKey: SymmetricKey? { currentKey }
    
    var identifierKey: SyncIdentifierKey? {
        if let cachedIdentifierKey {
            return cachedIdentifierKey
        }
        guard let wrapped = cloudInfo.wrappedIdentifierKey, let currentKey else { return nil }
        do {
            let key = try SyncIdentifierKey.unwrap(wrapped, with: currentKey)
            cachedIdentifierKey = key
            return key
        } catch {
            Log("SyncEncryptionHandler: Can't open the identifier key", module: .cloudSync, severity: .error)
            return nil
        }
    }
    
    /// Creates the key of the record identifiers when the cloud has none – for a clean cloud or one that is
    /// migrated to the format that uses it. An existing key is never replaced: the names of all records depend on
    /// it.
    /// - Returns: Whether there is a key now.
    @discardableResult
    func createIdentifierKeyIfNeeded() -> Bool {
        if identifierKey != nil { return true }
        guard cloudInfo.wrappedIdentifierKey == nil, currentKey != nil else { return false }
        cachedIdentifierKey = .generate()
        return true
    }
    
    func cloudEncryptionInfo(cached: SyncCloudEncryptionInfo) -> SyncCloudEncryptionInfo {
        var info = cached
        if let salt = kdfSalt {
            info.kdfSalt = salt
        }
        if cachedUsedKey == .user {
            info.kdfParameters = userKeyParameters.encoded() ?? cached.kdfParameters
        }
        if let identifierKey, let currentKey, let wrapped = try? identifierKey.wrapped(with: currentKey) {
            info.wrappedIdentifierKey = wrapped
        }
        return info
    }
    
    func cloudEncryptionInfoFetched(_ info: SyncCloudEncryptionInfo) {
        if info.wrappedIdentifierKey != cloudInfo.wrappedIdentifierKey {
            // Sealed again (the password changed elsewhere) or another key (the cloud was erased)
            cachedIdentifierKey = nil
        }
        cloudInfo = info
    }
    
    func purge() {
        saveUserKey(nil)
        if encryptionType == .user {
            setSystemKey()
        }
    }
}

private extension SyncEncryptionHandler {
    func encrypt(_ data: Data, using key: SymmetricKey) -> Data? {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined
        } catch {
            Log("Error while encrypting: \(error)", module: .cloudSync, severity: .error)
            return nil
        }
    }
    
    func decrypt(_ data: Data, using key: SymmetricKey) -> Data? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let result = try AES.GCM.open(sealedBox, using: key)
            return result
        } catch {
            Log("Error while decrypting: \(error)", module: .cloudSync, severity: .error)
            return nil
        }
    }
    
    var currentKey: SymmetricKey? {
        if cachedUsedKey == .system {
            cachedSystemKey
        } else {
            cachedUserKey
        }
    }
    
    /// The salt the user's key is derived with: this device's (from the iCloud Keychain) or, on a device that
    /// doesn't have it, the one the Info record carries
    var kdfSalt: Data? {
        if let cachedSalt, cachedSalt.count >= Self.saltByteCount {
            return Data(cachedSalt.prefix(Self.saltByteCount))
        }
        guard let salt = cloudInfo.kdfSalt, salt.count == Self.saltByteCount else { return nil }
        return salt
    }
    
    /// What the current user's key was derived with: saved when the key was set here, otherwise what the Info
    /// record says, otherwise what was used before the parameters were stored
    var userKeyParameters: SyncKDFParameters {
        if let encoded = userDefaults.data(forKey: kdfParametersKey),
           let parameters = SyncKDFParameters(encoded: encoded), parameters.isSupported {
            return parameters
        }
        if let encoded = cloudInfo.kdfParameters,
           let parameters = SyncKDFParameters(encoded: encoded), parameters.isSupported {
            return parameters
        }
        return .legacy
    }
    
    private func saveUserKeyParameters(_ parameters: SyncKDFParameters?) {
        userDefaults.set(parameters?.encoded(), forKey: kdfParametersKey)
        userDefaults.synchronize()
    }
    
    /// - Parameter parameters: `nil` – what the current user's key was derived with (to derive the same key).
    /// - Parameter salt: `nil` – the salt of the current user's key.
    func generateKey(for password: String, parameters: SyncKDFParameters? = nil, salt: Data? = nil) -> Data? {
        Self.deriveKey(for: password, parameters: parameters ?? userKeyParameters, salt: salt ?? kdfSalt)
    }
    
    private func createSalt() -> Data? {
        let str = String.random(length: 64)
        guard let data = str.data(using: .utf8) else {
            Log("Can't create data for salt", module: .cloudSync, severity: .error)
            return nil
        }
        return Data(SHA256.hash(data: data))
    }
    
    private func saveUserKey(_ userKey: Data?) {
        guard let userKey else {
            userDefaults.set(nil, forKey: userKeyKey)
            userDefaults.synchronize()
            return
        }
        guard let cachedSystemKey, let encrypted = encrypt(userKey, using: cachedSystemKey) else {
            Log("Can't encrypt user key for saving", module: .cloudSync, severity: .error)
            return
        }
        userDefaults.set(encrypted, forKey: userKeyKey)
        userDefaults.synchronize()
    }
    
    private func userKey() -> Data? {
        guard let encrypted = userDefaults.data(forKey: userKeyKey) else {
            return nil
        }
        guard let cachedSystemKey, let decrypted = decrypt(encrypted, using: cachedSystemKey) else {
            Log("Can't decrypt user key for retrieval", module: .cloudSync, severity: .error)
            return nil
        }
        return decrypted
    }
    
    private func setUsedKey(_ usedKey: Info.Encryption) {
        guard let cachedSystemKey,
              let data = usedKey.rawValue.data(using: .utf8),
              let encrypted = encrypt(data, using: cachedSystemKey) else {
            Log("Can't encrypt used key for saving", module: .cloudSync, severity: .error)
            return
        }
        userDefaults.set(encrypted, forKey: usedKeyKey)
        userDefaults.synchronize()
    }
    
    private func usedKey() -> Info.Encryption? {
        guard let encrypted = userDefaults.data(forKey: usedKeyKey) else {
            return nil
        }
        guard let cachedSystemKey,
              let decryptedData = decrypt(encrypted, using: cachedSystemKey),
              let decryptedRaw = String(data: decryptedData, encoding: .utf8),
              let decrypted = Info.Encryption(rawValue: decryptedRaw)
        else {
            Log("Can't decrypt used key for retrieval", module: .cloudSync, severity: .error)
            return nil
        }
        return decrypted
    }
}
