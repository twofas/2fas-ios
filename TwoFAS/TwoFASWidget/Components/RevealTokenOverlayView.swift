//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
//  Contributed by Grzegorz Machnio. All rights reserved.
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

struct RevealTokenOverlayView: View {
    enum RevealTokenMessageType {
        case short, long
        
        var message: String {
            switch self {
            case .short: "Reveal for 60 seconds"
            case .long: "Reveal your 2FAS tokens for 60 seconds"
            }
        }
    }
    
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            VStack {
                Spacer()
                RevealTokenImage()
                    .frame(width: 40, height: 40)
                Spacer()
                revealText(type: .short)
            }
        case .systemMedium:
            VStack {
                Spacer()
                RevealTokenImage()
                    .frame(width: 40, height: 40)
                Spacer()
                revealText(type: .long)
            }
            .padding(.bottom, 14)
        case .systemLarge, .systemExtraLarge:
            VStack(spacing: 12) {
                Spacer()
                RevealTokenImage()
                    .frame(width: 40, height: 40)
                revealText(type: .long)
                Spacer()
            }
        default:
            VStack {
                Spacer()
                RevealTokenImage()
                Spacer()
                revealText(type: .short)
            }
        }
    }
    
    private func revealText(type: RevealTokenMessageType) -> some View {
        Text(type.message)
            .foregroundStyle(Color.primaryBlack)
            .font(.caption2)
    }
}
