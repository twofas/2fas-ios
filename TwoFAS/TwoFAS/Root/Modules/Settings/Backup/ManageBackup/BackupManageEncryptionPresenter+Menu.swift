//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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

extension BackupManageEncryptionPresenter {
    func buildMenu() -> [BackupManageEncryptionSection] {
        var menu: [BackupManageEncryptionSection] = []
        let modificationEnabled = interactor.isCloudBackupSynced
        let canDelete = interactor.canDelete
        if interactor.encryptionTypeIsUser {
            menu.append(contentsOf: [
                .init(
                    title: T.Backup.encryptionTitle,
                    cells: [
                        .init(
                            title: T.backupSettingsPasswordRemoveTitle,
                            action: .decrypt,
                            isEnabled: modificationEnabled
                        ),
                        .init(
                            title: T.Backup.encryptionChangePassword,
                            action: .recrypt,
                            isEnabled: modificationEnabled
                        )
                    ],
                    footer: T.Backup.encryptionPasswordDescription
                ),
                .init(
                    title: T.Backup.backupRemoval,
                    cells: [
                        .init(title: T.Backup.delete2fasBackup, action: .clear, isEnabled: canDelete)
                    ],
                    footer: T.Backup.warningIntroduction
                )
            ])
        } else {
            menu.append(contentsOf: [
                .init(
                    title: T.Backup.encryptionTitle,
                    cells: [
                        .init(
                            title: T.backupSettingsPasswordSetTitle,
                            action: .encrypt,
                            isEnabled: modificationEnabled
                        )
                    ],
                    footer: T.Backup.encryptionPasswordDescription
                ),
                .init(
                    title: T.Backup.backupRemoval,
                    cells: [
                        .init(title: T.Backup.delete2fasBackup, action: .clear, isEnabled: canDelete)
                    ],
                    footer: T.Backup.warningIntroduction
                )
            ])
        }
        
        menu.append(contentsOf: [
            .init(
                title: "Encryption keys",
                cells: [
                    .init(
                        title: "Export",
                        action: .exportKeys,
                        isEnabled: true
                    ),
                    .init(
                        title: "Import",
                        action: .importKeys,
                        isEnabled: true
                    )
                ],
                footer: "iCloud Sync stores encryption keys in iCloud Keychain. If iCloud Keychain is disabled, export your keys manually — otherwise, restoring your data or syncing to other devices will not be possible. Note that importing keys will overwrite your current keys. If you are experiencing sync issues on multiple devices, export the keys from a device where sync is working and import them manually on the affected devices."
            )
        ])
        
        return menu
    }
}
