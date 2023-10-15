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

import UIKit
import Common
import Data

final class PINPadViewModel {   
    weak var delegate: PINPadViewControllerProtocol?
    
    var cancel: Callback?
    var resetAction: Callback?
    
    private let twoMinutes = 120
    private let minute = 60
    
    private var numbers: [Int] = []
    private var isLocked = false

    private let dataModel: PINPadDataModelProtocol
    
    private let timer = CountdownTimer()
    private let appLockStateInteractor: AppLockStateInteracting

    private let textChangeTime: Int = 3
    
    init(dataModel: PINPadDataModelProtocol, appLockStateInteractor: AppLockStateInteracting) {
        self.dataModel = dataModel
        self.appLockStateInteractor = appLockStateInteractor
        
        dataModel.invalidInput = { [weak self] in self?.invalidInput() }
        timer.timerFinished = { [weak self] in
            DispatchQueue.main.async {
                self?.prepareScreenWithNormalData()
                VoiceOver.say(dataModel.screenTitle)
            }
        }
    }
    
    // MARK: PINPadViewControllerProtocol implementation
    
    func leftButtonPressed() {       
        cancel?()
    }
    
    func deleteButtonPressed() {    
        deleteNumber()
    }
    
    func numberButtonPressed(number: Int) {       
        insertNumber(number)
    }
    
    func viewDidLoad() {
        delegate?.setDots(number: dataModel.codeLength)
    }
    
    func viewWillAppear() {       
        guard !isLocked else { return }
        
        prepareInitialState()
    }
    
    func lock() {       
        isLocked = true
        let lockTimeMessage: String = {
            if let lockTime = appLockStateInteractor.appLockRemainingSeconds {
                if lockTime < twoMinutes {
                    return T.Security.tooManyAttemptsError2
                }
                return T.Security.tooManyAttemptsTryAgainAfter("\(lockTime / minute)")
            }
            return  T.Security.tooManyAttemptsError
        }()
        numbers = []
        delegate?.emptyDots()
        delegate?.lock(withMessage: lockTimeMessage)
        delegate?.hideLeftButton()
        delegate?.hideRightButton()
    }
    
    func unlock() {       
        isLocked = false
        delegate?.unlock()
        prepareInitialState()
    }
    
    func reset() {
        resetAction?()
    }
    
    // MARK: - Private methods
    
    private func prepareInitialState() {       
        numbers = []
        delegate?.emptyDots()
        delegate?.hideLeftButton()
        delegate?.hideRightButton()
        
        if resetAction != nil {
            delegate?.showReset()
        }
        prepareScreenWithNormalData()
    }
    
    private func deleteNumber() {       
        _ = numbers.popLast()
        delegate?.fillDots(count: numbers.count)
        if numbers.isEmpty {
            delegate?.hideRightButton()
        }
    }
    
    private func insertNumber(_ number: Int) {       
        if numbers.isEmpty {
            delegate?.showDeleteButton()
        }
        
        numbers.append(number)
        
        delegate?.fillDots(count: numbers.count)
        
        if numbers.count == dataModel.codeLength {
            dataModel.PINGathered(numbers: self.numbers)
        }
    }
    
    private func invalidInput() {
        guard !isLocked else { return }
        numbers = []
        delegate?.hideRightButton()
        delegate?.emptyDots()
        delegate?.shakeDots()
        prepareScreenWithError()
    }
    
    private func prepareScreenWithNormalData() {
        guard !isLocked else { return }
        let screenData = PINPadScreenData(
            screenTitle: dataModel.screenTitle,
            buttonTitle: dataModel.leftButton,
            titleType: .normal
        )
        delegate?.prepareScreen(withScreenData: screenData)
    }
    
    private func prepareScreenWithError() {
        let screenData = PINPadScreenData(
            screenTitle: T.Security.incorrectPIN,
            buttonTitle: dataModel.leftButton,
            titleType: .error
        )
        VoiceOver.say(T.Security.incorrectPIN)
        delegate?.prepareScreen(withScreenData: screenData)
        
        timer.start(with: textChangeTime)
    }
}
