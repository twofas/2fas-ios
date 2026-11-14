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

import Foundation
import Common
import Data

protocol IconEditorModuleInteracting: AnyObject {
    var defaultIconTypeID: IconTypeID { get }
    func iconGroups(matching phrase: String) -> [IconDescriptionGroup]
    func sanitizeLabelTitle(_ value: String) -> String
}

final class IconEditorModuleInteractor {
    private let iconInteractor: IconInteracting
    private let serviceDefinitionInteractor: ServiceDefinitionInteracting

    init(
        iconInteractor: IconInteracting,
        serviceDefinitionInteractor: ServiceDefinitionInteracting
    ) {
        self.iconInteractor = iconInteractor
        self.serviceDefinitionInteractor = serviceDefinitionInteractor
    }
}

extension IconEditorModuleInteractor: IconEditorModuleInteracting {
    var defaultIconTypeID: IconTypeID {
        .default
    }

    func iconGroups(matching phrase: String) -> [IconDescriptionGroup] {
        let groups = iconInteractor.grouppedList()
        let trimmed = phrase.trim()
        guard !trimmed.isEmpty else { return groups }

        let phraseFormatted = trimmed.uppercased()
        let tagged = Set(serviceDefinitionInteractor.findServices(byTag: trimmed).map { $0.iconTypeID })
        return groups.compactMap { group in
            let icons = group.icons.filter { icon in
                icon.name.uppercased().contains(phraseFormatted) || tagged.contains(icon.iconTypeID)
            }
            guard !icons.isEmpty else { return nil }
            return IconDescriptionGroup(title: group.title, icons: icons)
        }
    }

    func sanitizeLabelTitle(_ value: String) -> String {
        let filtered = value.filter { char in
            char.isASCII || char.isLetter || char.isNumber || char.isSymbol || char.isEmoji
        }
        return String(filtered.prefix(ServiceRules.labelMaxLength))
            .uppercased()
    }
}
