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

struct AskForAuthView: View {
    private let image = Asset.authRequestQuestion.image
    
    let action: Callback
    let cancel: Callback
    let domain: String
    
    var body: some View {
        AdaptiveReadableContainer {
            VStack(alignment: .center) {
                Spacer()
                
                VStack(spacing: .XL) {
                    Image(uiImage: image)
                        .renderingMode(.original)
                        .frame(width: image.size.width, height: image.size.height)
                        .scaleEffect(0.75)
                    
                    VStack(spacing: .M) {
                        Text(T.Browser._2faTokenRequestTitle)
                            .textStyle(.title1, .emphasized)
                            .foregroundStyle(.labelsPrimary)
                            .multilineTextAlignment(.center)
                        Group {
                            Text(T.Browser._2faTokenRequestContent)
                            + Text(domain + "?")
                                .bold()
                        }
                        .textStyle(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.labelsPrimary)
                    }
                }
                
                Spacer()
                
                VStack(spacing: .L) {
                    TFButton(T.Commons.approve, variant: .bordered, size: .large) {
                        action()
                    }
                    TFButton(T.Commons.deny, variant: .bordered, size: .large) {
                        cancel()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
            }
        }
        .navigationBarHidden(true)
        .background(.backgroundsPrimaryElevated)
    }
}

#Preview {
    AskForAuthView(action: {}, cancel: {}, domain: "2fas.com")
}
