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

public enum LabelShapes {
    public static func generate(for size: CGSize) -> (backgroundCircle: UIBezierPath, upperRect: UIBezierPath) {
        let width = size.width / 62.0
        let height = size.height / 62.0
        let backgroundCircle = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let upperRect = UIBezierPath(
            roundedRect: CGRect(
                x: width * 8,
                y: height * 17,
                width: width * 46,
                height: height * 29
            ),
            cornerRadius: 14
        )
        
        return (backgroundCircle: backgroundCircle, upperRect: upperRect)
    }
}
