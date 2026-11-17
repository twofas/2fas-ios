//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

#if DEV
import Foundation
import Data
import Common

protocol DebugModuleInteracting: AnyObject {
    func buildStateSections() -> [DebugStateSection]

    func wipeDatabase()
    func resetApp()
    func wipeAndReset()
    func trashAllServices()
    func restoreAllServices()
    func emptyTrash()
    func reloadPushToken()
    func unpairAllBrowsers()
    func runLocalStorageKeyAction(_ action: DebugAction)

    func generateServices(count: Int, distributeIntoCategories: Bool)
}

final class DebugModuleInteractor {
    private let debugTools: DebugToolsInteracting
    private let appInfoInteractor: AppInfoInteracting

    init(
        debugTools: DebugToolsInteracting,
        appInfoInteractor: AppInfoInteracting
    ) {
        self.debugTools = debugTools
        self.appInfoInteractor = appInfoInteractor
    }
}

extension DebugModuleInteractor: DebugModuleInteracting {
    func buildStateSections() -> [DebugStateSection] {
        [
            DebugStateSection(title: "App", rows: [
                .init(name: "Version", value: appInfoInteractor.currentAppVersion),
                .init(name: "First run", value: "\(appInfoInteractor.dateOfFirstRun)"),
                .init(name: "2FAS Pass installed", value: appInfoInteractor.is2FASPASSInstalled.debugValue)
            ]),
            DebugStateSection(title: "Security", rows: [
                .init(name: "PIN set", value: debugTools.isPINSet.debugValue),
                .init(name: "Biometry enabled", value: debugTools.isBiometryEnabled.debugValue),
                .init(name: "Device ID set", value: debugTools.isDeviceIDSet.debugValue),
                .init(name: "Device ID", value: debugTools.deviceID ?? "—")
            ]),
            DebugStateSection(title: "Storage", rows: [
                .init(name: "Services (active)", value: "\(debugTools.totalServicesCount)"),
                .init(name: "Services (trashed)", value: "\(debugTools.trashedServicesCount)"),
                .init(name: "Sections", value: "\(debugTools.sectionsCount)")
            ]),
            DebugStateSection(title: "Local storage key", rows: [
                .init(name: "Key state", value: debugTools.localStorageKeyStateDescription),
                .init(name: "Key ID", value: debugTools.localStorageKeyID ?? "—"),
                .init(
                    name: "Lost-key launches",
                    value: "\(debugTools.lostKeyLaunches) of \(LostKeyLaunchCounter.wipeThreshold)"
                ),
                .init(
                    name: "Simulated unavailable launches left",
                    value: "\(debugTools.keychainUnavailableLaunchesLeft)"
                ),
                .init(name: "Protected data available", value: debugTools.isProtectedDataAvailable.debugValue)
            ]),
            DebugStateSection(title: "Cloud", rows: [
                .init(name: "Cloud enabled", value: debugTools.isCloudBackupEnabled.debugValue),
                .init(name: "Cloud state", value: debugTools.cloudStateDescription)
            ]),
            DebugStateSection(title: "Push notifications", rows: [
                .init(name: "State", value: debugTools.notificationStateDescription),
                .init(name: "Last notification", value: debugTools.lastNotificationDescription)
            ]),
            DebugStateSection(title: "Browser Extension", rows: [
                .init(name: "Paired browsers", value: "\(debugTools.pairedBrowsersCount)")
            ])
        ]
    }

    func wipeDatabase() {
        debugTools.disableCloudBackup()
        debugTools.wipeAllServicesAndSections()
    }

    func resetApp() {
        debugTools.clearAllUserDefaults()
    }

    func wipeAndReset() {
        debugTools.disableCloudBackup()
        debugTools.wipeAllServicesAndSections()
        debugTools.clearAllUserDefaults()
    }

    func trashAllServices() {
        debugTools.trashAllServices()
    }

    func restoreAllServices() {
        debugTools.restoreAllServices()
    }

    func emptyTrash() {
        debugTools.emptyTrash()
    }

    func reloadPushToken() {
        debugTools.reloadPushToken()
    }

    func unpairAllBrowsers() {
        debugTools.removeAllBrowserPairings()
    }

    func runLocalStorageKeyAction(_ action: DebugAction) {
        switch action {
        case .removeLocalStorageKey: debugTools.removeLocalStorageKeyFromKeychain()
        case .replaceLocalStorageKey: debugTools.replaceLocalStorageKey()
        case .forgetLocalStorageKeyID: debugTools.forgetLocalStorageKeyID()
        case .setLostKeyCounterBeforeWipe:
            debugTools.setLostKeyLaunches(LostKeyLaunchCounter.wipeThreshold - 1)
        case .resetLostKeyCounter: debugTools.setLostKeyLaunches(0)
        case .keychainUnavailableOnce: debugTools.simulateUnavailableKeychain(launches: 1)
        case .keychainUnavailableFiveTimes: debugTools.simulateUnavailableKeychain(launches: 5)
        default: return
        }
        if action.closesApp {
            debugTools.terminateApp()
        }
    }

    func generateServices(count: Int, distributeIntoCategories: Bool) {
        // Turn off cloud so generated fake services don't pollute iCloud.
        debugTools.disableCloudBackup()

        var sectionIDs: [SectionID?] = [nil]
        if distributeIntoCategories {
            let categoryCount = Int.random(in: 3...7)
            let sampleNames = [
                "Work", "Personal", "Finance", "Social", "Dev",
                "Gaming", "Family", "Test", "Archive", "Legacy"
            ].shuffled()
            for idx in 0..<categoryCount {
                let title = sampleNames[safe: idx] ?? "Category \(idx + 1)"
                let id = debugTools.createSection(named: title)
                sectionIDs.append(id)
            }
        }

        for _ in 0..<count {
            let sectionID: SectionID?
            if distributeIntoCategories {
                // 20% chance of no section, else pick a random real section.
                if Int.random(in: 0..<100) < 20 {
                    sectionID = nil
                } else {
                    sectionID = sectionIDs.compactMap { $0 }.randomElement()
                }
            } else {
                sectionID = nil
            }
            debugTools.addRandomService(sectionID: sectionID)
        }
    }
}

private extension Bool {
    var debugValue: String { self ? "YES" : "no" }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
#endif
