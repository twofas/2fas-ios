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

extension SettingsMenuPresenter {
    func buildMenu() -> [SettingsMenuSection] {
        let networkSSLError = SettingsMenuSection(
            cells: [
                .init(
                    icon: .symbol("exclamationmark.triangle.fill"),
                    title: T.Settings.sslErrorDescription,
                    accessory: .warning,
                    isEnabled: false
                )
            ])

        let backup = SettingsMenuSection(
            cells: [
                .init(
                    icon: .symbol("cloud.fill"),
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
            cells: [
                .init(
                    icon: .symbol("staroflife.shield"),
                    title: T.Settings.appSecurity,
                    info: securityDescription,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .security)
                )
            ]
        )
        let browerExtensionDescription: String = {
            if interactor.hasActiveBrowserExtension {
                return T.Commons.on
            }
            return T.Commons.off
        }()
        let browerExtension = SettingsMenuSection(
            cells: [
                .init(
                    icon: .symbol("puzzlepiece.extension.fill"),
                    title: T.Browser.browserExtensionSettings,
                    info: browerExtensionDescription,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .browserExtension)
                ),
                .init(
                    icon: .symbol("lock.applewatch"),
                    title: T.Settings.appleWatch,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .appleWatch)
                )
            ]
        )

        let areWidgetsOn = interactor.areWidgetsEnabled
        let preferences = SettingsMenuSection(
            cells: [
                .init(
                    icon: .symbol("eye.fill"),
                    title: T.Settings.appearance,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .appearance)
                ),
                .init(
                    icon: .symbol("square.grid.2x2.fill"),
                    title: T.Settings.widgets,
                    accessory: .toggle(kind: .widgets, isOn: areWidgetsOn)
                )
            ],
            footer: T.Settings.displaySelectedServices
        )

        let manageTokens = SettingsMenuSection(
            cells: [
                .init(
                    icon: .symbol("arrow.left.arrow.right"),
                    title: T.Settings.transfer,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .transfer)
                ),
                .init(
                    icon: .symbol("trash.fill"),
                    title: T.Settings.trashOption,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .trash)
                )
            ]
        )

        let pass = SettingsMenuSection(
            cells: [
                .init(
                    icon: .brand(Asset.settingsPass.image),
                    title: interactor.is2PASSInstalled ? T.settingsOpenTwofass : T.settingsOpenTwofassAppstore,
                    accessory: .external,
                    action: .navigation(navigatesTo: interactor.is2PASSInstalled ? .openPass : .appStorePass),
                    rememberPosition: false
                )
            ],
            footer: nil
        )

        let info = SettingsMenuSection(
            cells: [
                .init(
                    icon: .symbol("questionmark.circle.fill"),
                    title: T.Settings.support,
                    accessory: .external,
                    action: .navigation(navigatesTo: .faq),
                    rememberPosition: false
                ),
                .init(
                    icon: .symbol("info.circle.fill"),
                    title: T.Settings.about,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .about)
                )
            ],
            footer: T.Settings.infoFooter
        )

        var menu: [SettingsMenuSection] = []
        if interactor.hasSSLNetworkError && interactor.hasActiveBrowserExtension {
            menu.append(networkSSLError)
        }

        menu.append(contentsOf: [
            backup,
            security
        ])

        if interactor.isBrowserExtensionAllowed {
            menu.append(browerExtension)
        }

        menu.append(contentsOf: [
            preferences,
            manageTokens,
            pass,
            info
        ])
        return menu
    }
}
