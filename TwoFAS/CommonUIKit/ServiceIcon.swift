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
#if os(iOS)
import Common
import Content
#elseif os(watchOS)
import CommonWatch
import ContentWatch
#endif

// swiftlint:disable convenience_type
public final class ServiceIcon {
    public static var log: ((String) -> Void)?
        
    public static func `for`(iconTypeID: IconTypeID) -> UIImage {
        if let img = UIImage(
            named: iconTypeID.uuidString,
            in: IconDescriptionDatabaseImpl.bundle,
            with: nil
        ) {
            return img
        } else {
            Log("Can't find icon for iconTypeID \(iconTypeID.uuidString)")
            log?(iconTypeID.uuidString)
            // assert(false, "Can't find icon for service \(iconTypeID.uuidString)")
            return UIImage(
                named: IconTypeID.default.uuidString,
                in: IconDescriptionDatabaseImpl.bundle,
                with: nil
            )!
        }
    }
    
    public static func present(for iconTypeID: IconTypeID) -> Bool {
        UIImage(named: iconTypeID.uuidString, in: Bundle(for: Self.self), with: nil) != nil
    }
}
// swiftlint:enable convenience_type
