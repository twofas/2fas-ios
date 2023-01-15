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
import LocalAuthentication
import Common

public final class BiometricAuth {
    public weak var delegate: BiometricAuthDelegate?
    
    private let context = LAContext()
    private let storage: LocalEncryptedStorage
    
    init(storage: LocalEncryptedStorage) {
        self.storage = storage
    }
    
    public var isAvailable: Bool {
        var error: NSError?
        
        let avail = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if let err = error {
            Log("isAvailable - can't use bio authenticating: \(err.localizedDescription)")
        }
        
        return avail
    }
    
    public var biometryType: LABiometryType {
        context.biometryType
    }
    
    public var isBiometryLockedOut: Bool {
        var error: NSError?
        _ = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        guard let err = error else { return false }
        return err.code == LAError.biometryLockout.rawValue
    }
    
    public var isEnabled: Bool { storage.boolValue(for: .bioAuthEnabled) }
    
    public func enable() {
        guard isAvailable else {
            Log("Biometric Auth not available")
            return
        }
        
        storage.saveBool(for: .bioAuthEnabled, value: true)
    }
    
    public func disable() {
        storage.remove(for: .bioAuthEnabled)
    }
    
    public func authenticate(reason: String) {
        var error: NSError?
        Log("Authenticating using bio")
        
        guard context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let err = error {
                Log("Error - can't use bio authenticating: \(err.localizedDescription)")
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.bioAuthFailed()
            }
            
            return
        }
            
        if let currentVersion = UIDevice.current.systemVersion.splitVersion(),
           currentVersion < VersionDecoded(major: 13, minor: 2, fix: 0) {
            // Fix for bug in iOS 13.0 and 13.1 where TouchID window is invisible
            evaluate(reason: reason, ignore: true)
        }
        
        evaluate(reason: reason, ignore: false)
    }
    
    private func evaluate(reason: String, ignore: Bool) {
        context.evaluatePolicy(
            LAPolicy.deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason,
            reply: { [weak self] (success: Bool, evalPolicyError: Error?) -> Void in
            guard !ignore else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                if success {
                    self.delegate?.bioAuthSuccess()
                    Log("BioAuthSuccess")
                } else {
                    guard let err = evalPolicyError as NSError? else {
                        assertionFailure("Unsupported conversion")
                        return
                    }
                    Log("Error while authenticating - \(err.localizedDescription)")
                    
                    self.delegate?.bioAuthFailed()
                }
            }
        })
    }
}
