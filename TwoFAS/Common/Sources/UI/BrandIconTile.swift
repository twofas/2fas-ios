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

import SwiftUI

public struct BrandIconTile: View {
    private let image: UIImage
    private let size: CGFloat

    public init(image: UIImage, size: CGFloat = 28) {
        self.image = image
        self.size = size
    }

    public var body: some View {
        let corner = TFCornerRadius.small.value
        ZStack {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(AppColor.graysWhite)
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .inset(by: 0.5)
                .stroke(AppColor.bordersPrimary, lineWidth: 1)
            Image(uiImage: image)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .padding(4)
        }
        .frame(width: size, height: size)
    }
}
