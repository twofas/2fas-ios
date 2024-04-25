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

struct ServiceCellView: View {
    let service: Service
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            UnevenRoundedRectangle(
                cornerRadii:
                        .init(
                            topLeading: 4,
                            bottomLeading: 4,
                            bottomTrailing: 0,
                            topTrailing: 0
                        ),
                style: .continuous
            )
            .fill(service.badgeColor)
            .frame(width: 5)
            
            IconRenderer(service: service)
            VStack(alignment: .leading, spacing: 0) {
                Text(service.name)
                    .font(.callout)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                if let additionalInfo = service.additionalInfo {
                    Text(additionalInfo)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.vertical, 4)
        }
        .padding(.trailing, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Material.ultraThinMaterial,
            in: UnevenRoundedRectangle(
                cornerRadii:
                        .init(
                            topLeading: 4,
                            bottomLeading: 4,
                            bottomTrailing: 8,
                            topTrailing: 8
                        ),
                style: .continuous
            )
        )
        .listItemTint(.clear)
    }
}

#Preview {
    NavigationStack {
        List {
            ServiceCellView(service: .init(
                id: "ID",
                name: "2FAS Service",
                additionalInfo: "contact@2fas.com",
                iconType: .label,
                iconTypeID: .default,
                labelColor: TintColor.green.color,
                labelTitle: "2F",
                badgeColor: TintColor.default.color
            ))
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .containerBackground(.red.gradient, for: .navigation)
        .environment(\.defaultMinListRowHeight, WatchConsts.minRowHeight)
        .listRowBackground(Color.clear)
    }
}
