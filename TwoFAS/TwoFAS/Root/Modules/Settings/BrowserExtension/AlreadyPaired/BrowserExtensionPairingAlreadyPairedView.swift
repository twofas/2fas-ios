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

import SwiftUI
import Common

struct BrowserExtensionPairingAlreadyPairedView: View {
    let action: Callback

    private let image = Asset.pairingAlreadyPaired.image

    var body: some View {
        TFInfoView(background: .backgroundsPrimary) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: image.size.width / 2, height: image.size.height / 2)
        } texts: {
            Text(T.Browser.alreadyPairedTitle)
                .textStyle(.title1, .emphasized)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.center)
            Text(T.Browser.alreadyPairedDescription)
                .textStyle(.body)
                .foregroundStyle(.labelsSecondary)
                .multilineTextAlignment(.center)
        } buttons: {
            TFButton(
                T.Commons.continue,
                variant: .borderedProminent,
                size: .large,
                action: action
            )
        }
    }
}

#Preview {
    BrowserExtensionPairingAlreadyPairedView(action: {})
}
