//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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
import CommonWatch

struct IconRenderer: View {
    let service: Service
    
    @ViewBuilder
    var body: some View {
        Group {
            switch service.iconType {
            case .brand:
                Image(uiImage: ServiceIcon.for(iconTypeID: service.iconTypeID))
                    .resizable()
            case .label:
                ZStack(alignment: .center) {
                    Circle()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(service.labelColor)
                    RoundedRectangle(cornerRadius: 14, style: .circular)
                        .frame(width: 17.8, height: 11.22, alignment: .center)
                        .foregroundStyle(Color("ColorLabelTextBackground"))
                    Text(verbatim: service.labelTitle)
                        .foregroundStyle(Color("ColorLabelText"))
                        .font(Font(UIFont.systemFont(ofSize: 6, weight: .bold)))
                        .multilineTextAlignment(.center)
                        .frame(width: 22, height: 6, alignment: .center)
                }
            }
        }
        .frame(width: 24, height: 24)
        .aspectRatio(contentMode: .fit)
    }
}
