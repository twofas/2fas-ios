//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//

import Foundation

extension BackupManageKeysPresenter {
    func buildMenu() -> [BackupManageKeysSection] {
        [
            .init(
                title: T.Backup.encryptionTitle,
                cells: [
                    .init(title: T.Backup.export, action: .exportKeys, isEnabled: true),
                    .init(title: T.Backup.import, action: .importKeys, isEnabled: true)
                ],
                footer: T.Backup.sectionNote
            )
        ]
    }
}
