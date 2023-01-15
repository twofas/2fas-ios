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

struct BrowserExtensionIntroView: View {
    private let spacing: CGFloat = Theme.Metrics.doubleSpacing
    
    private let image = Asset.aboutExtension.image
    
    let action: Callback
    let cancel: Callback?
    let info: Callback
    
    private let columns = [
        GridItem(.flexible(maximum: 20), alignment: .top),
        GridItem(.flexible())
    ]
    
    private let data = [
        "1.", T.Browser.infoDescriptionFirst,
        "2.", T.Browser.infoDescriptionSecond
    ]
    
    var body: some View {
        VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
            Group {
                Image(uiImage: image)
                    .renderingMode(.original)
                    .frame(width: image.size.width, height: image.size.height)
            }
            .frame(maxHeight: .infinity, alignment: .center)
            
            VStack(spacing: spacing) {
                Text(T.Browser.infoTitle)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: Theme.Metrics.standardSpacing) {
                    ForEach(data, id: \.self) { item in
                        Group {
                            Text(item)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .frame(alignment: .top)
                        }
                    }
                }
                
                HStack(spacing: Theme.Metrics.halfSpacing) {
                    Text(T.Browser.moreInfo)
                        .foregroundColor(Color(Theme.Colors.Text.main))
                        .multilineTextAlignment(.trailing)
                    Button {
                        info()
                    } label: {
                        Text(T.Browser.moreInfoLinkTitle)
                            .multilineTextAlignment(.leading)
                    }
                    .buttonStyle(NoPaddingLinkButtonStyle())
                }
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .frame(alignment: .center)
            .layoutPriority(1)
            
            VStack(spacing: 0) {
                Button {
                    action()
                } label: {
                    Text(T.Browser.pairWithWebBrowser)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                .buttonStyle(RoundedFilledButtonStyle())
                
                if let cancel {
                    Button {
                        cancel()
                    } label: {
                        Text(T.Commons.cancel)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .buttonStyle(LinkButtonStyle())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom)
        }
        .frame(maxWidth: Theme.Metrics.componentWidth)
        .navigationBarHidden(true)
    }
}

struct BrowserExtensionIntroView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BrowserExtensionIntroView(action: {}, cancel: {}, info: {})
                .previewDevice("iPhone SE (1st generation)")
            BrowserExtensionIntroView(action: {}, cancel: nil, info: {})
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 13 Pro Max")
        }
    }
}
