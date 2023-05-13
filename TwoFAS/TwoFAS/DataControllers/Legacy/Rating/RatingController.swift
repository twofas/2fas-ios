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
import StoreKit

// swiftlint:disable no_magic_numbers
enum RatingController {
    private enum StateParamsKeys: String {
        case runTimes = "RatingController.runTimes"
        case firstRun = "RatingController.firstRun"
        case lastPresented = "RatingController.lastPresented"
        case presentedCount = "RatingController.presentedCount"
    }
    
    private struct StateParams {
        let runTimes: Int
        let firstRun: Date?
        let lastPresented: Date?
        let presentedCount: Int
    }
    
    static func uiIsVisible() {
        let currentState = restoreState()
        
        var runTimes = currentState.runTimes
        var firstRun = currentState.firstRun
        var lastPresented = currentState.lastPresented
        var presentedCount = currentState.presentedCount

        let currentDate = Date()
        
        let firstRunDaysAgo = (firstRun != nil) ? firstRun!.days(from: currentDate) : 0
        let lastPresentedDaysAgo = lastPresented != nil ? lastPresented!.days(from: currentDate) : 0
        
        var shouldShowRatingNow = false
        
        if shouldShowRating(
            runTimes: runTimes,
            firstRunDaysAgo: firstRunDaysAgo,
            lastPresentedDaysAgo: lastPresentedDaysAgo,
            presentedCount: presentedCount
        ) {
            lastPresented = currentDate
            presentedCount += 1
            
            shouldShowRatingNow = true
        }
        
        runTimes += 1
        
        if firstRun == nil {
            firstRun = currentDate
        }
        
        let newState = StateParams(
            runTimes: runTimes,
            firstRun: firstRun,
            lastPresented: lastPresented,
            presentedCount: presentedCount
        )
        
        guard let scene = UIApplication.shared.currentScene else { return }
        saveState(state: newState)
        
        if shouldShowRatingNow {
            showRating(in: scene)
        }
    }

    // Rules:
    // user runs app 10 times in 2 weeks -> rate
    // otherwise after 1 month
    // after that ask every 2 weeks
    static func shouldShowRating(
        runTimes: Int,
        firstRunDaysAgo: Int,
        lastPresentedDaysAgo: Int,
        presentedCount: Int
    ) -> Bool {
        guard runTimes > 0, firstRunDaysAgo >= 14 else { return false }
        
        if presentedCount == 0 && (runTimes >= 10 || firstRunDaysAgo >= 30) {
            return true
        } else if presentedCount == 1 && firstRunDaysAgo >= 35 && lastPresentedDaysAgo >= 14 {
            return true
        } else if presentedCount == 2 && firstRunDaysAgo > 50 && lastPresentedDaysAgo >= 14 {
            return true
        } else if presentedCount > 2 && lastPresentedDaysAgo > 180 {
            return true
        }
        
        return false
    }
    
    private static func showRating(in scene: UIWindowScene) {
        let twoSecondsFromNow = DispatchTime.now() + 4.0
        
        DispatchQueue.main.asyncAfter(deadline: twoSecondsFromNow) {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private static func saveState(state: StateParams) {
        let def = UserDefaults.standard
        def.set(state.runTimes, forKey: StateParamsKeys.runTimes.rawValue)
        
        if let firstRun = state.firstRun {
            def.set(firstRun.timeIntervalSince1970, forKey: StateParamsKeys.firstRun.rawValue)
        } else {
            def.removeObject(forKey: StateParamsKeys.firstRun.rawValue)
        }
        
        if let lastPresented = state.lastPresented {
            def.set(lastPresented.timeIntervalSince1970, forKey: StateParamsKeys.lastPresented.rawValue)
        } else {
            def.removeObject(forKey: StateParamsKeys.lastPresented.rawValue)
        }
        
        def.set(state.presentedCount, forKey: StateParamsKeys.presentedCount.rawValue)
        
        def.synchronize()
    }
    
    private static func restoreState() -> StateParams {
        let def = UserDefaults.standard
        let runTimes = def.integer(forKey: StateParamsKeys.runTimes.rawValue)
        let firstRun = def.double(forKey: StateParamsKeys.firstRun.rawValue)
        let lastPresented = def.double(forKey: StateParamsKeys.lastPresented.rawValue)
        let presentedCount = def.integer(forKey: StateParamsKeys.presentedCount.rawValue)
        
        let firstRunDate: Date? = firstRun.isZero ? nil : Date(timeIntervalSince1970: firstRun)
        let lastPresentedDate: Date? = lastPresented.isZero ? nil : Date(timeIntervalSince1970: lastPresented)
        
        return StateParams(
            runTimes: runTimes,
            firstRun: firstRunDate,
            lastPresented: lastPresentedDate,
            presentedCount: presentedCount
        )
    }
}
// swiftlint:enable no_magic_numbers
