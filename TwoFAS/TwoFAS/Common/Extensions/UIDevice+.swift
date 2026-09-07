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
import DeviceKit

extension UIDevice {
    static var isiPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    /// Face ID animates in the island on these phones; elsewhere the biometry prompt is an
    /// alert over the screen centre. DeviceKit knows the models it was built with; a newer
    /// one it reports as unknown is judged by its top safe area instead, which only the
    /// island makes this deep.
    static var hasDynamicIsland: Bool {
        let device = Device.current
        if case .unknown = device.realDevice {
            let topInset = UIApplication.keyWindow?.safeAreaInsets.top ?? 0
            return !isiPad && topInset >= dynamicIslandTopInset
        }
        return device.hasDynamicIsland
    }

    /// Smallest top safe area of a phone with a Dynamic Island (59 pt on the first ones); a
    /// notch reaches 50 pt at most.
    private static let dynamicIslandTopInset: CGFloat = 51
    static var isSmallScreen: Bool {
        guard Device.current.diagonal > 0 else { return false }
        return Device.current.diagonal <= 4.1
    }
}
