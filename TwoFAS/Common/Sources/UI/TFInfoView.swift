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

public struct TFInfoView<VImage: View, VTexts: View, VButtons: View>: View {
    private let image: VImage
    private let texts: VTexts
    private let buttons: VButtons

    public init(
        @ViewBuilder image: () -> VImage,
        @ViewBuilder texts: () -> VTexts,
        @ViewBuilder buttons: () -> VButtons
    ) {
        self.image = image()
        self.texts = texts()
        self.buttons = buttons()
    }

    public var body: some View {
        AdaptiveReadableContainer {
            VStack(alignment: .center) {
                Spacer()

                VStack(spacing: .XL) {
                    image

                    VStack(spacing: .M) {
                        texts
                    }
                }

                Spacer()

                VStack(spacing: .L) {
                    buttons
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
            }
        }
        .navigationBarHidden(true)
        .background(.backgroundsPrimaryElevated)
    }
}
