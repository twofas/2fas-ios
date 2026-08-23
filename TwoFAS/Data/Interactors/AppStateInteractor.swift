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
import CoreGraphics

public protocol AppStateInteracting: AnyObject {
    var isLockScreenActive: Bool { get }

    func lockScreenActive()
    func lockScreenInactive()

    var isBiometryAuthenticating: Bool { get }
    func biometryAuthenticationStarted()
    func biometryAuthenticationEnded()

    var appState: AppState { get }
    func saveAppState(_ appState: AppState)

    var willURLBeHandled: Bool { get }
    func clearURLWillBeHandled()
    func markURLWillBeHandled()

    var plusButtonRect: CGRect? { get }
    func savePlusButtonRect(_ rect: CGRect?)

    var isAddingServiceVisible: Bool { get }
    func saveIsAddingServiceVisible(_ value: Bool)

    func storeQuickAction(_ action: QuickAction)
    func takeQuickAction() -> QuickAction?

    var openBackupExportOnAppear: Bool { get }
    func setOpenBackupExportOnAppear(_ value: Bool)

    var openAddServiceOnAppear: Bool { get }
    func setOpenAddServiceOnAppear(_ value: Bool)

    var focusSearchOnAppear: Bool { get }
    func setFocusSearchOnAppear(_ value: Bool)
}

final class AppStateInteractor {
    private let mainRepository: MainRepository
    private let notificationCenter: NotificationCenter
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
        self.notificationCenter = .default
    }
}

extension AppStateInteractor: AppStateInteracting {
    var isLockScreenActive: Bool {
        mainRepository.isLockScreenActive
    }
    
    func lockScreenActive() {
        mainRepository.lockScreenActive()
    }
    
    func lockScreenInactive() {
        mainRepository.lockScreenInactive()
    }

    var isBiometryAuthenticating: Bool {
        mainRepository.isBiometryAuthenticating
    }

    func biometryAuthenticationStarted() {
        mainRepository.biometryAuthenticationStarted()
    }

    func biometryAuthenticationEnded() {
        mainRepository.biometryAuthenticationEnded()
    }

    var appState: AppState {
        mainRepository.appState
    }
    
    func saveAppState(_ appState: AppState) {
        mainRepository.saveAppState(appState)
        notificationCenter.post(name: .appStateDidChange, object: nil, userInfo: nil)
    }
    
    var willURLBeHandled: Bool { mainRepository.willURLBeHandled }

    func clearURLWillBeHandled() {
        mainRepository.clearURLWillBeHandled()
    }

    func markURLWillBeHandled() {
        mainRepository.markURLWillBeHandled()
    }

    var plusButtonRect: CGRect? { mainRepository.plusButtonRect }

    func savePlusButtonRect(_ rect: CGRect?) {
        mainRepository.savePlusButtonRect(rect)
    }

    var isAddingServiceVisible: Bool { mainRepository.isAddingServiceVisible }

    func saveIsAddingServiceVisible(_ value: Bool) {
        guard mainRepository.isAddingServiceVisible != value else { return }
        mainRepository.saveIsAddingServiceVisible(value)
        notificationCenter.post(name: .addingServiceVisibilityDidChange, object: nil, userInfo: nil)
    }

    func storeQuickAction(_ action: QuickAction) {
        mainRepository.storeQuickAction(action)
        NotificationCenter.default.post(name: .quickActionRequested, object: nil)
    }

    func takeQuickAction() -> QuickAction? {
        mainRepository.takeQuickAction()
    }

    var openBackupExportOnAppear: Bool { mainRepository.openBackupExportOnAppear }

    func setOpenBackupExportOnAppear(_ value: Bool) {
        mainRepository.setOpenBackupExportOnAppear(value)
    }

    var openAddServiceOnAppear: Bool { mainRepository.openAddServiceOnAppear }

    func setOpenAddServiceOnAppear(_ value: Bool) {
        mainRepository.setOpenAddServiceOnAppear(value)
    }

    var focusSearchOnAppear: Bool { mainRepository.focusSearchOnAppear }

    func setFocusSearchOnAppear(_ value: Bool) {
        mainRepository.setFocusSearchOnAppear(value)
    }
}
