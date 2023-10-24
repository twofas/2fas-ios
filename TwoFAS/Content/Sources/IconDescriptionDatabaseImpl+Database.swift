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
import Common

// swiftlint:disable all
final class IconDescriptionDatabaseGenerated {
    lazy var icons: [IconDescription] = {
        IconDescriptionDatabaseImpl+Database0.icons +
        IconDescriptionDatabaseImpl+Database1.icons +
        IconDescriptionDatabaseImpl+Database2.icons +
        IconDescriptionDatabaseImpl+Database3.icons +
        IconDescriptionDatabaseImpl+Database4.icons +
        IconDescriptionDatabaseImpl+Database5.icons +
        IconDescriptionDatabaseImpl+Database6.icons +
        IconDescriptionDatabaseImpl+Database7.icons +
        IconDescriptionDatabaseImpl+Database8.icons +
        IconDescriptionDatabaseImpl+Database9.icons
    }()
}
