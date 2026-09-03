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

@Observable
final class DebugPresenter {
    var stateSections: [DebugStateSection] = []
    var pendingAction: DebugAction?
    var pendingGenerationCount: Int?
    var distributeIntoCategories: Bool = false
    var isRunning: Bool = false
    var runningMessage: String = ""

    private let flowController: DebugFlowControlling
    private let interactor: DebugModuleInteracting

    init(flowController: DebugFlowControlling, interactor: DebugModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }

    func viewWillAppear() {
        reloadState()
    }

    // MARK: - Actions

    func requestAction(_ action: DebugAction) {
        pendingAction = action
    }

    func confirmAction() {
        guard let action = pendingAction else { return }
        pendingAction = nil
        run(actionTitle: action.confirmationTitle) { [interactor] in
            switch action {
            case .wipeDatabase: interactor.wipeDatabase()
            case .resetApp: interactor.resetApp()
            case .wipeAndReset: interactor.wipeAndReset()
            case .trashAllServices: interactor.trashAllServices()
            case .restoreAllServices: interactor.restoreAllServices()
            case .emptyTrash: interactor.emptyTrash()
            case .reloadPushToken: interactor.reloadPushToken()
            case .unpairAllBrowsers: interactor.unpairAllBrowsers()
            }
        }
    }

    func cancelAction() {
        pendingAction = nil
    }

    // MARK: - Generation

    func requestGeneration(_ count: DebugGenerateCount) {
        pendingGenerationCount = count.rawValue
    }

    func confirmGeneration() {
        guard let count = pendingGenerationCount else { return }
        pendingGenerationCount = nil
        let distribute = distributeIntoCategories
        run(actionTitle: "Generating \(count) services…") { [interactor] in
            interactor.generateServices(count: count, distributeIntoCategories: distribute)
        }
    }

    func cancelGeneration() {
        pendingGenerationCount = nil
    }

    // MARK: - Helpers

    private func reloadState() {
        stateSections = interactor.buildStateSections()
    }

    private func run(actionTitle: String, work: @escaping @MainActor () -> Void) {
        isRunning = true
        runningMessage = actionTitle
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 50_000_000)
            work()
            self?.finishRunning()
        }
    }

    @MainActor
    private func finishRunning() {
        isRunning = false
        reloadState()
    }
}

extension DebugAction {
    var confirmationTitle: String {
        switch self {
        case .wipeDatabase:
            "Wiping database…"
        case .resetApp:
            "Resetting app…"
        case .wipeAndReset:
            "Wiping + resetting…"
        case .trashAllServices:
            "Moving services to trash…"
        case .restoreAllServices:
            "Restoring services from trash…"
        case .emptyTrash:
            "Emptying trash…"
        case .reloadPushToken:
            "Reloading push token…"
        case .unpairAllBrowsers:
            "Unpairing browsers…"
        }
    }

    var displayTitle: String {
        switch self {
        case .wipeDatabase:
            "Wipe database"
        case .resetApp:
            "Reset app (clear UserDefaults)"
        case .wipeAndReset:
            "Wipe DB + reset app"
        case .trashAllServices:
            "Move all services to trash"
        case .restoreAllServices:
            "Restore all services from trash"
        case .emptyTrash:
            "Empty trash"
        case .reloadPushToken:
            "Reload push token"
        case .unpairAllBrowsers: 
            "Unpair all browsers"
        }
    }

    var confirmationMessage: String {
        switch self {
        case .wipeDatabase:
            "Cloud sync will be disabled and ALL services, sections and trash will be permanently removed."
        case .resetApp: 
            "All UserDefaults will be cleared. Restart recommended."
        case .wipeAndReset:
            "Cloud sync will be disabled. All data + user defaults will be permanently removed. Restart recommended."
        case .trashAllServices:
            "All active services will be moved to trash."
        case .restoreAllServices:
            "All trashed services will be restored."
        case .emptyTrash:
            "All trashed services will be permanently removed."
        case .reloadPushToken: 
            "The device will re-register for remote notifications."
        case .unpairAllBrowsers: 
            "All paired browsers and pending auth requests will be removed."
        }
    }

    var isDestructive: Bool {
        switch self {
        case .wipeDatabase, .resetApp, .wipeAndReset, .emptyTrash, .unpairAllBrowsers, .trashAllServices:
            return true
        case .restoreAllServices, .reloadPushToken: return false
        }
    }
}
#endif
