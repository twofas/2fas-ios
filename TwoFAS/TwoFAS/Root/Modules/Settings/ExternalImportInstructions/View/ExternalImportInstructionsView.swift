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

struct ExternalImportInstructionsView: View {
    private let spacing: CGFloat = Theme.Metrics.doubleSpacing
    
    let sourceLogo: Image
    let sourceName: String
    let info: String
    
    let action: Callback
    let cancel: Callback
    
    let actionName: String
    let secondaryActionName: String?
    let secondaryAction: Callback?
    
    private let minIconSpaceHeight: CGFloat = 90
    
    var body: some View {
        VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    sourceLogo
                    Asset.gaImport1.swiftUIImage
                    Asset.gaImport2.swiftUIImage
                }
                .frame(minHeight: minIconSpaceHeight, alignment: .center)
                Text(sourceName)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .layoutPriority(1)
                Text(info)
                    .font(.body)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .layoutPriority(1)
            
            VStack(spacing: Theme.Metrics.halfSpacing) {
                Button {
                    action()
                } label: {
                    Text(actionName)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                .buttonStyle(RoundedFilledButtonStyle())
                
                if let secondaryAction, let secondaryActionName {
                    Button {
                        secondaryAction()
                    } label: {
                        Text(secondaryActionName)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .buttonStyle(RoundedBorderButtonStyle())
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
        .background {
            Asset.introductionBackground.swiftUIImage
                .renderingMode(.template)
                .foregroundColor(Color(Theme.Colors.Line.secondaryLine))
        }
        .frame(maxWidth: Theme.Metrics.componentWidth)
    }
}

struct ExternalImportInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExternalImportInstructionsView(
                sourceLogo: Asset.externalImportRavio.swiftUIImage,
                sourceName: T.externalimportGoogleAuthenticator,
                info: T.Introduction.googleAuthenticatorImportProcess,
                action: {},
                cancel: {},
                actionName: T.Commons.scanQrCode,
                secondaryActionName: T.Tokens.selectFromGallery,
                secondaryAction: {}
            )
                .previewDevice("iPhone SE (1st generation)")
            
            ExternalImportInstructionsView(
                sourceLogo: Asset.externalImportGoogleAuth.swiftUIImage,
                sourceName: T.externalimportGoogleAuthenticator,
                info: T.Introduction.googleAuthenticatorImportProcess,
                action: {},
                cancel: {},
                actionName: T.Commons.scanQrCode,
                secondaryActionName: T.Tokens.selectFromGallery,
                secondaryAction: {}
            )
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 13 Pro Max")
        }
    }
}
