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

extension SettingsMenuPresenter {
    func buildMenu() -> [SettingsMenuSection] {
        let networkSSLError = SettingsMenuSection(
            title: T.Settings.sslErrorTitle,
            cells: [
                .init(title: T.Settings.sslErrorDescription, accessory: .warning, isEnabled: false)
        ])
        
        let backup = SettingsMenuSection(
            title: T.Settings.backupAndSynchronization,
            cells: [
                .init(
                    icon: Asset.backupSettingsIcon.image,
                    title: T.Backup._2fasBackup,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .backup)
                )
            ]
        )
        
        let securityDescription: String = {
            if interactor.isSecurityEnabled {
                return T.Commons.on
            }
            return T.Commons.off
        }()
        let security = SettingsMenuSection(
            title: T.Settings.security,
            cells: [
                .init(
                    icon: Asset.settingsPIN.image,
                    title: T.Settings.appSecurity,
                    info: securityDescription,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .security)
                )
            ]
        )
        
        let exteralLinkImage = Asset.externalLinkIcon.image
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(Theme.Colors.Icon.theme)
        let customView = UIImageView(image: exteralLinkImage)
        customView.tintColor = Theme.Colors.Icon.theme
        customView.contentMode = .right
        let donate = SettingsMenuSection(
            title: T.Settings.donations,
            cells: [
                .init(
                    icon: Asset.settingsDonate.image,
                    title: T.Settings.donateTwofas,
                    accessory: .customView(customView),
                    action: .navigation(navigatesTo: .donate)
                )
            ]
        )
        
        let areWidgetsOn = interactor.areWidgetsEnabled
        var advancedCells: [SettingsMenuCell] = []
        advancedCells.append(.init(
            icon: Asset.settingsBrowserExtension.image,
            title: T.Browser.browserExtension,
            accessory: .arrow,
            action: .navigation(navigatesTo: .browserExtension)
        ))
        advancedCells.append(.init(
            icon: Asset.settingsWidget.image,
            title: T.Settings.widgets,
            accessory: .toggle(kind: .widgets, isOn: areWidgetsOn)
        ))
        
        let advancedWidgets = SettingsMenuSection(
            title: T.Settings.advanced,
            cells: advancedCells,
            footer: T.Settings.displaySelectedServices
        )
                
        let isIncomingTokenEnabled = interactor.isNextTokenEnabled
        let advancedIncoming = SettingsMenuSection(
            title: nil,
            cells: [
                .init(
                    icon: Asset.settingsNextToken.image,
                    title: T.Settings.showNextToken,
                    accessory: .toggle(kind: .incomingToken, isOn: isIncomingTokenEnabled)
                )
            ],
            footer: T.Settings.seeIncomingTokens
        )
        
        let externalImport = SettingsMenuSection(
            title: T.Backup.import,
            cells: [
                .init(
                    icon: Asset.settingsExternalImport.image,
                    title: T.Settings.externalImport,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .externalImport)
                )
            ],
            footer: nil
        )
        
        let trash = SettingsMenuSection(
            title: nil,
            cells: [
                .init(
                    icon: Asset.settingsTrash.image,
                    title: T.Settings.trash,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .trash)
                )
            ],
            footer: nil
        )
        
        let knowledge = SettingsMenuSection(
            title: T.Settings.knowledge,
            cells: [
                .init(
                    icon: Asset.settingsFAQ.image,
                    title: T.Settings.support,
                    accessory: .external,
                    action: .navigation(navigatesTo: .faq)
                )
            ]
        )
        
        let about = SettingsMenuSection(
            title: nil,
            cells: [
                .init(
                    icon: Asset.settingsInfo.image,
                    title: T.Settings.about,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .about)
                )
            ]
        )
        
        var menu: [SettingsMenuSection] = []
        if interactor.hasSSLNetworkError && interactor.hasActiveBrowserExtension {
            menu.append(networkSSLError)
        }
        
        menu.append(contentsOf: [
            backup,
            security,
            donate,
            advancedWidgets,
            externalImport,
            advancedIncoming,
            trash,
            knowledge,
            about
        ])
        return menu
    }
}
