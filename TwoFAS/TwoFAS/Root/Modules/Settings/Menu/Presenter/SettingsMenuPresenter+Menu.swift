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
        
        let browerExtension = SettingsMenuSection(
            title: T.Browser.browserExtension,
            cells: [
                .init(
                    icon: Asset.settingsBrowserExtension.image,
                    title: T.Browser.browserExtensionSettings,
                    info: securityDescription,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .browserExtension)
                )
            ]
        )
        
        let areWidgetsOn = interactor.areWidgetsEnabled
        let preferences = SettingsMenuSection(
            title: T.Settings.preferences,
            cells: [
                .init(
                    icon: Asset.settingsAppearance.image,
                    title: T.Settings.appearance,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .appearance)
                ),
                .init(
                    icon: Asset.settingsWidget.image,
                    title: T.Settings.widgets,
                    accessory: .toggle(kind: .widgets, isOn: areWidgetsOn)
                )
            ],
            footer: T.Settings.displaySelectedServices
        )
        
        let manageTokens = SettingsMenuSection(
            title: T.Settings.manageTokens,
            cells: [
                .init(
                    icon: Asset.settingsExternalImport.image,
                    title: T.Settings.externalImport,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .externalImport)
                ),
                .init(
                    icon: Asset.settingsTrash.image,
                    title: T.Settings.trashOption,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .trash)
                )
            ]
        )
        
        let exteralLinkImage = Asset.externalLinkIcon.image
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(Theme.Colors.Icon.theme)
        let donateLabel = {
            let label = UILabel()
            label.textColor = Theme.Colors.Text.theme
            label.text = T.Settings.itMatters
            label.minimumScaleFactor = 0.3
            label.adjustsFontSizeToFitWidth = true
            label.numberOfLines = 1
            label.allowsDefaultTighteningForTruncation = true
            label.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
            label.baselineAdjustment = .alignBaselines
            return label
        }()
        let customView = {
            let img = UIImageView(image: exteralLinkImage)
            img.tintColor = Theme.Colors.Icon.theme
            img.contentMode = .right
            let view = UIView()
            view.addSubview(donateLabel, with: [
                donateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                donateLabel.topAnchor.constraint(equalTo: view.topAnchor),
                donateLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            view.addSubview(img, with: [
                img.leadingAnchor.constraint(
                    equalTo: donateLabel.trailingAnchor,
                    constant: Theme.Metrics.standardMargin
                ),
                img.topAnchor.constraint(equalTo: view.topAnchor),
                img.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                img.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            return view
        }()
                
        let info = SettingsMenuSection(
            title: T.Commons.info,
            cells: [
                .init(
                    icon: Asset.settingsFAQ.image,
                    title: T.Settings.support,
                    accessory: .external,
                    action: .navigation(navigatesTo: .faq)
                ),
                .init(
                    icon: Asset.settingsInfo.image,
                    title: T.Settings.about,
                    accessory: .arrow,
                    action: .navigation(navigatesTo: .about)
                ),
                .init(
                    icon: Asset.settingsDonate.image,
                    title: T.Settings.donateTwofas,
                    accessory: .customView(customView),
                    action: .navigation(navigatesTo: .donate)
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
            security,
            browerExtension,
            preferences,
            manageTokens,
            info
        ])
        return menu
    }
}
