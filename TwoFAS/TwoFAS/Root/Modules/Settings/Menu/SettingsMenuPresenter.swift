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
import Data

@Observable
final class SettingsMenuPresenter {
    var sections: [SettingsMenuSection] = []
    var selectedModule: SettingsNavigationModule?
    var isCollapsed: Bool = false
    var showsSidebarButton: Bool = false

    var sidebarRevealAction: (() -> Void)?

    private let flowController: SettingsMenuFlowControlling
    let interactor: SettingsMenuModuleInteracting

    init(flowController: SettingsMenuFlowControlling, interactor: SettingsMenuModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension SettingsMenuPresenter {
    var currentViewPath: ViewPath.Settings? {
        switch selectedModule {
        case .backup: .backup
        case .security: .security
        case .browserExtension: .browserExtension
        case .trash: .trash
        case .about: .about
        case .transfer: .transfer
        case .appearance: .appearance
        case .appleWatch: .appleWatch
        case .faq, .appStorePass, .openPass: nil
        default: nil
        }
    }

    func viewWillAppear() {
        reload()
    }

    func handleSelection(_ action: SettingsMenuCell.Action, rememberPosition: Bool) {
        switch action {
        case .navigation(let navigatesTo):
            navigate(to: navigatesTo, rememberPosition: rememberPosition)
        }
        reload()
    }

    func handleToggle(_ kind: SettingsNavigationToggle) {
        toggleAction(kind: kind)
    }

    func setCollapsed() {
        isCollapsed = true
    }

    func setExpanded() {
        isCollapsed = false
    }

    func restoreSelection(_ viewPath: ViewPath.Settings?) {
        // Restore which module is "selected" without navigating anywhere. The
        // selection is only used to populate the detail column once the layout is
        // (or becomes) expanded; while collapsed the menu list stays at its root.
        selectedModule = module(for: viewPath)
    }

    func handleShowSelected() {
        if isCollapsed {
            if let selectedModule {
                navigate(to: selectedModule)
            }
        } else {
            // Restoring the detail column on expansion: force the navigation so the
            // column is rebuilt even when the target equals the remembered module
            // (otherwise the reselection guard would leave the detail empty).
            navigate(to: selectedModule ?? .backup, force: true)
        }
    }

    func handleShowingRoot() {
        // Returning to the collapsed root menu must not forget the selected module:
        // it is needed to restore the detail column when the layout expands again.
        // The highlight is already suppressed while collapsed (see isSelected), so
        // there is nothing to clear here.
    }

    func handleSwitchToBackup() {
        navigate(to: .backup)
    }

    func handleEnableWidgetsFromWarningWindow() {
        interactor.enableWidgets()
        reload()
    }

    func handleWidgetsCanceledFromWarningWindow() {
        reload()
    }

    func handleAppSecurityChaged() {
        reload()
    }

    func handleNavigateToViewPath(_ viewPath: ViewPath.Settings, force: Bool = false) {
        switch viewPath {
        case .backup: navigate(to: .backup, force: force)
        case .security: navigate(to: .security, force: force)
        case .browserExtension: navigate(to: .browserExtension, force: force)
        case .trash: navigate(to: .trash, force: force)
        case .about: navigate(to: .about, force: force)
        case .transfer: navigate(to: .transfer, force: force)
        case .appearance: navigate(to: .appearance, force: force)
        case .appleWatch: navigate(to: .appleWatch, force: force)
        @unknown default: break
        }
    }
}

private extension SettingsMenuPresenter {
    func navigate(to navigateTo: SettingsNavigationModule, rememberPosition: Bool = true, force: Bool = false) {
        if !force, rememberPosition, navigateTo == selectedModule, !isCollapsed {
            // Re-selecting the already-active module in the two-column layout:
            // return its detail stack to root instead of rebuilding the same
            // detail. (Collapsed layout falls through and pushes a fresh copy,
            // since the menu is only reachable at the navigation root there.)
            flowController.toPopDetailToRoot()
            return
        }
        if rememberPosition {
            selectedModule = navigateTo
        } else {
            selectedModule = nil
        }

        flowController.toUpdateCurrentPosition(navigateToViewPath(navigateTo: navigateTo))

        if !isCollapsed {
            reload()
        }

        switch navigateTo {
        case .backup:
            flowController.toBackup()
        case .browserExtension:
            flowController.toBrowserExtension()
        case .security:
            flowController.toSecurity()
        case .trash:
            flowController.toTrash()
        case .faq:
            flowController.toFAQ()
        case .about:
            flowController.toAbout()
        case .transfer:
            flowController.toTransfer()
        case .appearance:
            flowController.toAppearance()
        case .appleWatch:
            flowController.toAppleWatch()
        case .appStorePass:
            flowController.toTwoPASSAppStore()
        case .openPass:
            flowController.toOpenTwoPASS()
        #if DEV
        case .debug:
            flowController.toDebug()
        #endif
        }
    }

    func toggleAction(kind: SettingsNavigationToggle) {
        switch kind {
        case .widgets: widgetAction()
        }
    }

    func reload() {
        sections = buildMenu()
    }

    func widgetAction() {
        if interactor.areWidgetsEnabled {
            interactor.disableWidgets()
            reload()
        } else {
            if interactor.shouldShowWidgetWarning {
                flowController.toWidgetEnablingWarning()
            } else {
                interactor.enableWidgets()
                reload()
            }
        }
    }

    func module(for viewPath: ViewPath.Settings?) -> SettingsNavigationModule? {
        guard let viewPath else { return nil }
        switch viewPath {
        case .backup: return .backup
        case .security: return .security
        case .browserExtension: return .browserExtension
        case .trash: return .trash
        case .about: return .about
        case .transfer: return .transfer
        case .appearance: return .appearance
        case .appleWatch: return .appleWatch
        @unknown default: return nil
        }
    }

    func navigateToViewPath(navigateTo: SettingsNavigationModule) -> ViewPath.Settings? {
        switch navigateTo {
        case .backup: .backup
        case .security: .security
        case .browserExtension: .browserExtension
        case .trash: .trash
        case .about: .about
        case .transfer: .transfer
        case .appearance: .appearance
        case .appleWatch: .appleWatch
        case .faq, .appStorePass, .openPass: nil
        #if DEV
        case .debug: nil
        #endif
        @unknown default: nil
        }
    }
}
