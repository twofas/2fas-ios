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
import Common

struct ServiceIconPreview: View {
    static let defaultDimension: CGFloat = 90

    let icon: IconDetails
    var dimension: CGFloat = Self.defaultDimension

    var body: some View {
        content()
            .frame(width: dimension, height: dimension)
    }

    @ViewBuilder
    private func content() -> some View {
        switch icon {
        case .brand:
            if #available(iOS 26.0, *) {
                ServiceIconView(icon: icon, showBackground: false, dimension: dimension)
                    .frame(width: dimension, height: dimension)
                    .glassEffect(.regular, in: Circle())
            } else {
                ServiceIconView(icon: icon, dimension: dimension)
                    .shadow(.glass)
            }
        case .label:
            ServiceIconView(icon: icon, dimension: dimension)
                .shadow(.glass)
        }
    }
}

#Preview {
    HStack(spacing: .XXL) {
        ServiceIconPreview(icon: .brand(iconTypeID: .default))
        ServiceIconPreview(icon: .label(title: "MN", tintColor: .lightBlue))
    }
}
