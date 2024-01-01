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
    private let paddingHorizontal: CGFloat = 3 * Theme.Metrics.standardSpacing
    private let paddingVertical: CGFloat = Theme.Metrics.doubleSpacing
    private let containerPadding: CGFloat = Theme.Metrics.standardSpacing
    private let spacing: CGFloat = Theme.Metrics.doubleSpacing
    
    private let image0 = Asset.externalImportLastPass.image
    private let image1 = Asset.gaImport1.image
    private let image2 = Asset.gaImport2.image
    
    let importedCount: Int
    let totalCount: Int

    let action: Callback
    let cancel: Callback
    
    var body: some View {
        Group {
            VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
                HStack(spacing: spacing) {
                    Image(uiImage: image0)
                        .frame(width: image0.size.width, height: image0.size.height)
                    Image(uiImage: image1)
                        .frame(width: image1.size.width, height: image1.size.height)
                    Image(uiImage: image2)
                        .frame(width: image2.size.width, height: image2.size.height)
                }
                .frame(maxHeight: .infinity, alignment: .center)
                
                VStack(spacing: spacing) {
                    Text(T.Tokens.lastPassImport)
                        .font(.title)
                        .multilineTextAlignment(.center)
                    Text(T.Tokens.lastPassImportSubtitle)
                        .font(.body)
                        .multilineTextAlignment(.center)
                    Text(T.Tokens.googleAuthOutOfTitle(importedCount, totalCount))
                        .font(.body.bold())
                        .multilineTextAlignment(.center)
                    Text(T.Tokens.googleAuthImportSubtitleEnd)
                        .font(.body)
                        .multilineTextAlignment(.center)
                }
                .frame(alignment: .center)
                .layoutPriority(1)
                
                VStack(spacing: 0) {
                    Button {
                        action()
                    } label: {
                        Text(T.Commons.continue)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .modify {
                        if importedCount == 0 {
                            $0.buttonStyle(RoundedFilledInactiveButtonStyle())
                        } else {
                            $0.buttonStyle(RoundedFilledButtonStyle())
                        }
                    }
                    
                    Button {
                        cancel()
                    } label: {
                        Text(T.Commons.cancel)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .buttonStyle(LinkButtonStyle())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .frame(maxWidth: Theme.Metrics.componentWidth)
            .padding(EdgeInsets(
                top: paddingVertical,
                leading: paddingHorizontal,
                bottom: 0,
                trailing: paddingHorizontal)
            )
            .background(Color(Theme.Colors.decoratedContainer))
            .cornerRadius(Theme.Metrics.cornerRadius)
        }
        .padding(containerPadding)
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
