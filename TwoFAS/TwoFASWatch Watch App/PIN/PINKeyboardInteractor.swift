//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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
import CommonWatch

enum PINKeyboardVariant {
    case PINValidation
    case PINValidationWithClose
    case enterNewPIN(PINType)
    case verifyPIN(AppPIN)
}

protocol PINKeyboardInteracting: AnyObject {
    var length: Int { get }
    var isFull: Bool { get }
    var isEmpty: Bool { get }
    var pinLastLetterVisible: String { get }
    var pinInvisible: String { get }
    var variant: PINKeyboardVariant { get }
    var completePIN: AppPIN { get }
    func validate() -> Bool
    func save()
    func remove()
    
    func addPINNumber(_ number: Int)
    func removePINNumber()
    func clearPINNumbers()
}

final class PINKeyboardInteractor {
    private let mainRepository: MainRepository
    
    private let pinType: PINType
    private let currentPIN: AppPIN?
    let variant: PINKeyboardVariant
    
    var completePIN: AppPIN {
        AppPIN(type: pinType, value: collectedPIN.createPIN())
    }
    
    private let placeholder = "•"
    
    private var collectedPIN: [String] = []
    
    init(mainRepository: MainRepository, variant: PINKeyboardVariant) {
        self.mainRepository = mainRepository
        self.variant = variant
        
        self.pinType = {
            switch variant {
            case .PINValidation, .PINValidationWithClose: mainRepository.pin?.type ?? .digits4
            case .enterNewPIN(let PINType): PINType
            case .verifyPIN(let appPIN): appPIN.type
            }
        }()
        
        self.currentPIN = {
            switch variant {
            case .PINValidation, .PINValidationWithClose: mainRepository.pin
            case .enterNewPIN: nil
            case .verifyPIN(let appPIN): appPIN
            }
        }()
    }
}

extension PINKeyboardInteractor: PINKeyboardInteracting {
    var length: Int {
        collectedPIN.count
    }
    
    var isFull: Bool {
        length == pinType.digits
    }
    
    var isEmpty: Bool {
        collectedPIN.isEmpty
    }
    
    var pinLastLetterVisible: String {
        guard !isEmpty else { return "⠀" }
        return collectedPIN.enumerated()
            .map { index, element in
                if index == collectedPIN.count - 1 {
                    return element
                }
                return placeholder
            }
            .joined()
    }
    
    var pinInvisible: String {
        guard !isEmpty else { return "⠀" }
        return collectedPIN.map({ _ in placeholder }).joined()
    }
    
    func validate() -> Bool {
        guard isFull else { return false }
        if let currentPIN {
            return currentPIN.value == collectedPIN.createPIN()
        }
        return true
    }
    
    func save() {
        guard let currentPIN, variant.canSave else { return }
        mainRepository.setPIN(currentPIN)
    }
    
    func remove() {
        mainRepository.setPIN(nil)
    }
    
    func addPINNumber(_ number: Int) {
        guard !isFull else { return }
        collectedPIN.append(String(number))
    }
    
    func removePINNumber() {
        guard !isEmpty else { return }
        collectedPIN.removeLast()
    }
    
    func clearPINNumbers() {
        collectedPIN = []
    }
}

private extension Array where Element == String {
    func createPIN() -> String {
        map { String($0) }.reduce("", +)
    }
}

private extension PINKeyboardVariant {
    var canSave: Bool {
        switch self {
        case .verifyPIN: true
        default: false
        }
    }
}
