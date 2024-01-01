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

struct SelectFromGalleryAdvice: View {
    private let paddingHorizontal: CGFloat = 3 * Theme.Metrics.standardSpacing
    private let paddingVertical: CGFloat = Theme.Metrics.doubleSpacing
    private let topSpacing: CGFloat = 6 * Theme.Metrics.standardSpacing
    private let containerPadding: CGFloat = Theme.Metrics.standardSpacing
    private let spacing: CGFloat = Theme.Metrics.doubleSpacing
    
    let action: Callback
    private let image = Asset.selectFromGalleryAdviceIcon.image
    
    var body: some View {
        Group {
            VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
                Group {
                    Image(uiImage: image)
                        .foregroundColor(Color(Theme.Colors.Fill.theme))
                        .frame(width: image.size.width, height: image.size.height)
                }
                .frame(maxHeight: .infinity, alignment: .center)
                
                VStack(spacing: Theme.Metrics.doubleSpacing) {
                    Text(T.Tokens.galleryAdviceTitle)
                        .font(.title)
                        .multilineTextAlignment(.center)
                    Group {
                        Text(T.Tokens.galleryAdviceContentFirst)
                        + Text(T.Tokens.galleryAdviceContentMiddleBold)
                            .fontWeight(.semibold)
                        + Text(T.Tokens.galleryAdviceContentLast)
                    }
                    .font(.body)
                    .multilineTextAlignment(.center)
                }
                .frame(alignment: .center)
                .layoutPriority(1)
                
                VStack(spacing: 0) {
                    Button {
                        action()
                    } label: {
                        Text(T.Commons.gotIt)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .buttonStyle(RoundedFilledButtonStyle())
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: spacing, trailing: 0))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .frame(maxWidth: Theme.Metrics.componentWidth)
            .background(Color(Theme.Colors.Fill.background))
        }
    }
}

struct SelectFromGalleryAdvice_Previews: PreviewProvider {
    static var previews: some View {
        SelectFromGalleryAdvice {}
            .previewDevice("iPhone SE (1st generation)")
            .background(Color.pink)
            .preferredColorScheme(.dark)
        
        SelectFromGalleryAdvice {}
            .previewDevice("iPhone 13 Pro")
            .background(Color.pink)
            .preferredColorScheme(.light)
    }
}
