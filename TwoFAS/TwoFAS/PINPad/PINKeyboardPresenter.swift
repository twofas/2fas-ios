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
import Common

class PINKeyboardPresenter {
    weak var keyboard: PINKeyboardViewControlling?
    
    var codeLength: Int = 0
    var lockTime: Int? = 0
    private(set) var isLocked = false
    
    private let timer = CountdownTimer()
    private let textChangeTime: Int = 3
    
    private(set) var numbers: [Int] = []
    
    let remainingTimeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .numeric
        formatter.unitsStyle = .short
        formatter.formattingContext = .middleOfSentence
        return formatter
    }()
    
    var passcode: String {
        numbers.concateToPostionString()
    }
    
    init() {
        timer.timerFinished = { [weak self] in
            DispatchQueue.main.async {
                self?.configureNormalScreen()
            }
        }
    }
    
    func handleDeleteButtonTap() {
        delete()
    }
    
    func handleNumberButtonPressed(_ number: Int) {
        insert(number)
    }
    
    func lock() {
        isLocked = true
        numbers = []
        keyboard?.emptyDots()
        keyboard?.lock(withMessage: lockTimeMessage)
        keyboard?.hideLeftButton()
        keyboard?.hideDeleteButton()
    }
    
    func unlock() {
        isLocked = false
        keyboard?.unlock()
        initialize()
    }
    
    func PINGathered() {}
    
    func viewWillAppear() {
        guard !isLocked else { return }
        
        initialize()
    }
    
    func initialize() {
        numbers = []
        keyboard?.setDots(number: codeLength)
        keyboard?.emptyDots()
        keyboard?.hideLeftButton()
        keyboard?.hideDeleteButton()
        configureNormalScreen()
    }
    
    func invalidInput() {
        guard !isLocked else { return }
        numbers = []
        keyboard?.hideDeleteButton()
        keyboard?.emptyDots()
        keyboard?.shakeDots()
        configureErrorScreen()
    }
    
    func setNewDotsCount(_ count: Int) {
        codeLength = count
        keyboard?.setDots(number: count)
        numbers = []
    }
    
    func configureNormalScreen() {
        guard !isLocked else { return }
    }
    
    func configureErrorScreen() {
        timer.start(with: textChangeTime)
    }
}

private extension PINKeyboardPresenter {
    var lockTimeMessage: String {
        guard let lockTime else {
            return T.Security.tooManyAttemptsError
        }
        let minute: Int? = {
            var calc = lockTime / 60
            if calc > 0 {
                let remainingSeconds = lockTime - (calc * 60)
                if remainingSeconds > 40 {
                    calc += 1
                }
                return calc
            }
            return nil
        }()
        let second: Int? = {
            let calc = lockTime / 60
            if calc > 0 {
                return nil
            }
            if lockTime == 0 {
                return 1
            }
            return lockTime
        }()
        let components = DateComponents(
            calendar: nil,
            timeZone: nil,
            era: nil,
            year: nil,
            month: nil,
            day: nil,
            hour: nil,
            minute: minute,
            second: second,
            nanosecond: nil,
            weekday: nil,
            weekdayOrdinal: nil,
            quarter: nil,
            weekOfMonth: nil,
            weekOfYear: nil,
            yearForWeekOfYear: nil
        )
        let formattedTime = remainingTimeFormatter.localizedString(from: components)
        return T.Security.tooManyAttemptsTryAgainAfterFormatter("\(formattedTime)")
    }
    
    func delete() {
        _ = numbers.popLast()
        keyboard?.fillDots(count: numbers.count)
        
        if numbers.count == 0 {
            keyboard?.hideDeleteButton()
        }
    }
    
    func insert(_ number: Int) {
        if numbers.count == 0 {
            keyboard?.showDeleteButton()
        }
        
        numbers.append(number)
        
        keyboard?.fillDots(count: numbers.count)
        
        if numbers.count == codeLength {
            PINGathered()
        }
    }
}
