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

final class SettingsMenuPresenter {
    weak var view: SettingsMenuViewControlling?
    
    private let flowController: SettingsMenuFlowControlling
    let interactor: SettingsMenuModuleInteracting
    
    private var selectedModule: SettingsNavigationModule?
    
    private(set) var isCollapsed = false
    private(set) var selectedIndex: IndexPath?
    
    private let tapLength = 0.75
    
    init(flowController: SettingsMenuFlowControlling, interactor: SettingsMenuModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension SettingsMenuPresenter {
    func viewWillAppear() {
        reload()
    }
    
    func handleSelection(at indexPath: IndexPath) {
        let menu = buildMenu()
        guard let section = menu[safe: indexPath.section],
              let cell = section.cells[safe: indexPath.row],
              let action = cell.action else {
            reload()
            return
        }
        switch action {
        case .navigation(let navigatesTo):
            navigate(to: navigatesTo)
        }
        reload()
    }
    
    func setCollapsed() {
        isCollapsed = true
        view?.clearSelection()
    }
    
    func setExpanded() {
        isCollapsed = false
        guard let selectedIndex else { return }
        view?.setSelection(at: selectedIndex)
    }
    
    func handleShowSelected() {
        if isCollapsed {
            if let selectedModule {
                navigate(to: selectedModule)
            }
        } else {
            if let selectedModule {
                navigate(to: selectedModule)
            } else {
                navigate(to: .backup)
            }
        }
    }
    
    func handleToggle(for indexPath: IndexPath) {
        let menu = buildMenu()
        guard let section = menu[safe: indexPath.section],
              let cell = section.cells[safe: indexPath.row],
              let cellAccessory = cell.accessory,
              case SettingsMenuCell.AccessoryKind.toggle(let action, _) = cellAccessory
        else { return }
        toggleAction(kind: action)
    }
    
    func handleShowingRoot() {
        if isCollapsed {
            selectedIndex = nil
            selectedModule = nil
        }
    }
    
    func handleToFAQ() {
        navigate(to: .faq)
    }
    
    func handleToSetupPIN() {
        guard selectedModule != .security else { return }
        navigate(to: .security)
    }
    
    func handleSwitchToBrowserExtension() {
        guard selectedModule != .browserExtension else { return }
        navigate(to: .browserExtension)
    }
    
    func handleEnableWidgetsFromWarningWindow() {
        interactor.enableWidgets()
        reload()
    }
    
    func handleWidgetsCanceledFromWarningWindow() {
        reload()
    }
    
    func handleSocialChannel(_ socialChannel: SocialChannel) {
        flowController.toSocialChannel(socialChannel)
    }
    
    func handleAppSecurityChaged() {
        reload()
    }
}

private extension SettingsMenuPresenter {
    func navigate(to navigateTo: SettingsNavigationModule) {
        let menu = buildMenu()
        guard let indexPath = menu.indexPath(for: navigateTo) else { return }
        selectedModule = navigateTo
        selectedIndex = indexPath
        
        if !isCollapsed {
            view?.setSelection(at: indexPath)
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
        case .donate:
            flowController.toDonate()
        }
    }
    
    func toggleAction(kind: SettingsNavigationToggle) {
        switch kind {
        case .incomingToken: interactor.toogleIncomingToken()
        case .widgets: widgetAction()
        }
    }
    
    func reload() {
        let menu = buildMenu()
        view?.reload(with: menu)
    }
    
    func widgetAction() {
        if interactor.areWidgetsEnabled {
            interactor.disableWidgets()
        } else {
            if interactor.shouldShowWidgetWarning {
                flowController.toWidgetEnablingWarning()
            } else {
                interactor.enableWidgets()
            }
        }
    }
}
