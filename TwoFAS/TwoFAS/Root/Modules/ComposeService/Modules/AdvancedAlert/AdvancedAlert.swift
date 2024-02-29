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

struct AdvancedAlert: View {
    private let spacing: CGFloat = Theme.Metrics.doubleSpacing
    
    private let alertImage = Asset.alertIcon.image
    private let alertSize = CGSize(width: 140, height: 100)
    
    let action: Callback
    let cancel: Callback
    
    var body: some View {
        VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
            Group {
                Image(uiImage: alertImage)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: alertSize.width, height: alertSize.height)
            }
            .frame(maxHeight: .infinity, alignment: .center)
            
            VStack(spacing: spacing) {
                Text(T.Tokens.advancedAlert.uppercased())
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .layoutPriority(1)
                Text(T.Tokens.advancedAlertDescriptionTitle)
                    .font(.body)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
            }
            .frame(alignment: .center)
            
            VStack(spacing: 0) {
                Button {
                    action()
                } label: {
                    Text(T.Commons.continue)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                .buttonStyle(RoundedFilledButtonStyle())
                
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
    }
}

struct AdvancedAlert_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AdvancedAlert(action: {}, cancel: {})
                .previewDevice("iPhone SE (1st generation)")
            AdvancedAlert(action: {}, cancel: {})
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 13 Pro Max")
        }
    }
}
