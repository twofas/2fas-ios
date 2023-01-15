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

public final class CodeStorage {
    private let storage: LocalEncryptedStorage
    
    init(storage: LocalEncryptedStorage) {
        self.storage = storage
    }
    
    private var storedType: Protection.CodeType {
        let codeType: Protection.CodeType
        if let cdString = storage.stringValue(for: .codeType), let cd = Protection.CodeType(rawValue: cdString) {
            codeType = cd
        } else {
            codeType = .PIN4
        }
        
        return codeType
    }
    
    private var storedPIN: Protection.Code? {
        guard let pinValue = storage.stringValue(for: .pinKey) else { return nil }
        
        return Protection.Code(PINvalue: pinValue, codeType: storedType)
    }
    
    public func validate(withPIN PINvalue: Protection.PIN) -> Bool {
        storedPIN?.PINvalue == PINvalue
    }
    
    public func save(PINValue: String, codeType: Protection.CodeType) {
        storage.saveString(for: .pinKey, value: PINValue)
        storage.saveString(for: .codeType, value: codeType.rawValue)
    }
    
    public var currentType: Protection.CodeType { storedType }
    
    public var isSet: Bool { storedPIN != nil }
    
    public func remove() {
        storage.remove(for: .pinKey)
        storage.remove(for: .codeType)
    }
}
