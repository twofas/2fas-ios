//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//

import UIKit
import Data

struct BackupManageKeysSection: TableViewSection {
    let title: String?
    var cells: [BackupManageKeysCell]
    let footer: String?
    
    init(title: String? = nil, cells: [BackupManageKeysCell], footer: String? = nil) {
        self.title = title
        self.cells = cells
        self.footer = footer
    }
}

struct BackupManageKeysCell: Hashable {
    enum Action: Hashable {
        case exportKeys
        case importKeys
    }
    
    let title: String
    let action: Action
    let isEnabled: Bool
    var icon: UIImage {
        action.icon
    }
    
    init(title: String, action: Action, isEnabled: Bool) {
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
    }
}

extension BackupManageKeysCell.Action {
    var icon: UIImage {
        switch self {
        case .exportKeys: UIImage(systemName: "arrow.up.document.fill")!
        case .importKeys: UIImage(systemName: "square.and.arrow.down.on.square.fill")!
        }
    }
}
