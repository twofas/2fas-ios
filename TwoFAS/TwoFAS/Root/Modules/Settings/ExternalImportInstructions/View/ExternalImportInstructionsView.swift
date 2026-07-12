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

struct ExternalImportInstructionsView: View {
    let sourceLogo: AnyView
    let sourceName: String
    let info: String

    let action: Callback
    let cancel: Callback

    let actionName: String
    let secondaryActionName: String?
    let secondaryAction: Callback?

    private let image2 = Asset.gaImport2.image

    var body: some View {
        TFInfoView {
            HStack(spacing: .XL) {
                sourceLogo
                ArrowIcon()
                Image(uiImage: image2)
                    .frame(width: image2.size.width, height: image2.size.height)
            }
        } texts: {
            Text(sourceName)
                .textStyle(.title1, .emphasized)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.center)
            Text(info)
                .textStyle(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.labelsPrimary)
        } buttons: {
            TFButton(actionName, variant: .borderedProminent, size: .large, action: action)

            if let secondaryAction, let secondaryActionName {
                TFButton(secondaryActionName, variant: .bordered, size: .large, action: secondaryAction)
            }

            TFButton(T.Commons.cancel, variant: .borderless, size: .large, action: cancel)
        }
    }
}
