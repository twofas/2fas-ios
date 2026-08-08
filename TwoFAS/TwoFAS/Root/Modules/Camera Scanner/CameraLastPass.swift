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

struct CameraLastPass: View {
    private let paddingHorizontal: Spacing = .XXXL
    private let paddingVertical: Spacing = .XL
    private let containerPadding: Spacing = .M
    private let spacing: Spacing = .XL
    
    private let image0 = Asset.externalImportLastPass.image
    private let image2 = Asset.gaImport2.image
    
    let importedCount: Int
    let totalCount: Int

    let action: Callback
    let cancel: Callback
    
    var body: some View {
        TFInfoView {
            HStack(spacing: spacing) {
                Image(uiImage: image0)
                    .frame(width: image0.size.width, height: image0.size.height)
                ArrowIcon()
                Image(uiImage: image2)
                    .frame(width: image2.size.width, height: image2.size.height)
            }
        } texts: {
            Text(T.Tokens.lastPassImport)
                .textStyle(.title1, .emphasized)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.center)
            Text(T.Tokens.lastPassImportSubtitle)
                .textStyle(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.labelsPrimary)
            Text(T.Tokens.googleAuthOutOfTitle(importedCount, totalCount))
                .textStyle(.body, .emphasized)
                .multilineTextAlignment(.center)
                .foregroundStyle(.labelsPrimary)
            Text(T.Tokens.googleAuthImportSubtitleEnd)
                .textStyle(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.labelsPrimary)
        } buttons: {
            TFButton(T.Commons.continue, variant: .borderedProminent, size: .large, action: action)
                .disabled(importedCount == 0)
            TFButton(T.Commons.cancel, variant: .borderless, size: .large, action: cancel)
        }
        .navigationBarHidden(true)
    }
}

struct CameraLastPass_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CameraLastPass(
                importedCount: 1,
                totalCount: 8,
                action: { print("Action!") },
                cancel: { print("Cancel!") }
            )
                .previewDevice("iPhone SE (1st generation)")
            CameraLastPass(
                importedCount: 7,
                totalCount: 8,
                action: { print("Action!") },
                cancel: { print("Cancel!") }
            )
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 13 Pro Max")
        }
        .background(Color.white)
    }
}
