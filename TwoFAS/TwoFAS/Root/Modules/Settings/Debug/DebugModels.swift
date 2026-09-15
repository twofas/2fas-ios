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

struct DebugStateRow: Identifiable {
    let id = UUID()
    let name: String
    let value: String
}

struct DebugStateSection: Identifiable {
    let id = UUID()
    let title: String
    let rows: [DebugStateRow]
}

enum DebugAction: Hashable {
    case wipeDatabase
    case resetApp
    case wipeAndReset
    case trashAllServices
    case restoreAllServices
    case emptyTrash
    case reloadPushToken
    case unpairAllBrowsers
}

enum DebugGenerateCount: Int, CaseIterable, Identifiable {
    case five = 5
    case ten = 10
    case twenty = 20
    case fifty = 50
    case hundred = 100
    case twoHundred = 200
    case fiveHundred = 500
    case thousand = 1000

    var id: Int { rawValue }
    var label: String { "\(rawValue)" }
}
#endif
