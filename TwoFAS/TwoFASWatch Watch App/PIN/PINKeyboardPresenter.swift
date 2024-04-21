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
import WatchKit

enum PINKeyboardResult: Equatable, Hashable {
    static func == (lhs: PINKeyboardResult, rhs: PINKeyboardResult) -> Bool {
        switch (lhs, rhs) {
        case (.verified, .verified): true
        case (.closed, .closed): true
        case (.entered, .entered): true
        case (.saved, .saved): true
        default: false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
    
    case verified
    case closed
    case entered(AppPIN)
    case saved
}

final class PINKeyboardPresenter: ObservableObject {
    @Published var isNumKeyboardLocked = false
    @Published var isDeleteVisible = false
    @Published var pin: String = "⠀"
    @Published var animateFailure = false
    @Published var showCloseButton = false
    @Published var navigationTitle = ""
        
    private let interactor: PINKeyboardInteracting
    private let completion: (PINKeyboardResult) -> Void
    
    init(interactor: PINKeyboardInteracting, completion: @escaping (PINKeyboardResult) -> Void) {
        self.interactor = interactor
        self.completion = completion
        
        showCloseButton = interactor.variant.showCloseButton
        navigationTitle = interactor.variant.navigationTitle
    }
    
    func onCloseAction() {
        guard showCloseButton else { return }
        completion(.closed)
    }
    
    func onShakeAnimationEnded() {
        interactor.clearPINNumbers()
        pin = interactor.pinInvisible
        
        animateFailure = false
        isDeleteVisible = false
        isNumKeyboardLocked = false
    }
    
    func numButtonPressed(_ value: Int) {
        func validate() {
            if interactor.validate() {
                DispatchQueue.main.async {
                    WKInterfaceDevice().play(.success)
                }
                isDeleteVisible = false
                isNumKeyboardLocked = true
                
                switch interactor.variant {
                case .PINValidation: completion(.verified)
                case .PINValidationWithClose: completion(.verified)
                case .enterNewPIN: completion(.entered(interactor.completePIN))
                case .verifyPIN:
                    interactor.save()
                    completion(.saved)
                }
            } else {
                wrongPIN()
            }
        }
        
        if interactor.isFull {
            validate()
            return
        }
        
        interactor.addPINNumber(value)
        
        updateDeleteButton()
        pin = interactor.pinLastLetterVisible
        
        if interactor.isFull {
            validate()
        }
    }
    
    func onNumButtonRelease(_ value: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.pin = self?.interactor.pinInvisible ?? ""
        }
    }
    
    func onDeleteAction() {
        guard !interactor.isEmpty else { return }
        interactor.removePINNumber()
        pin = interactor.pinInvisible
        updateDeleteButton()
    }
}

private extension PINKeyboardPresenter {
    func wrongPIN() {
        isDeleteVisible = false
        isNumKeyboardLocked = true
        animateFailure = true
    }
    
    func updateDeleteButton() {
        isDeleteVisible = !interactor.isEmpty
    }
}

private extension PINKeyboardVariant {
    var navigationTitle: String {
        switch self {
        case .PINValidation: T.Security.enterPinShort
        case .PINValidationWithClose: T.Security.enterPinShort
        case .enterNewPIN: T.Security.enterNewPinShort
        case .verifyPIN: T.Security.repeatNewPinShort
        }
    }
    
    var showCloseButton: Bool {
        switch self {
        case .PINValidation: false
        default: true
        }
    }
}
