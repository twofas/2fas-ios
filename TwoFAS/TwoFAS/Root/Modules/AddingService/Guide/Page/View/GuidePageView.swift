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

struct GuidePageView: View {
    let presenter: GuidePagePresenter
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .center, spacing: 3 * Theme.Metrics.doubleMargin) {
                Image(uiImage: presenter.image)
                Text(presenter.content)
                    .font(.body)
                    .foregroundStyle(Color(Theme.Colors.Text.main))
                    .frame(maxWidth: Theme.Metrics.componentWidth)
                    .padding(2 * Theme.Metrics.doubleMargin)
            }
            .frame(alignment: .center)

            Spacer()
            
            VStack(spacing: Theme.Metrics.doubleMargin) {
                PageIndicator(totalPages: presenter.totalPages, pageNumber: presenter.pageNumber)
                Button {
                    presenter.handleAction()
                } label: {
                    if let buttonIcon = presenter.buttonIcon {
                        HStack {
                            Image(uiImage: buttonIcon)
                                .tint(.white)
                            Text(verbatim: presenter.buttonTitle)
                        }
                    } else {
                        Text(verbatim: presenter.buttonTitle)
                    }
                }
                .buttonStyle(RoundedFilledConstantWidthButtonStyle())
            }
            .padding(.bottom, 2 * Theme.Metrics.doubleMargin)
            .frame(maxWidth: .infinity, alignment: .bottom)
        }
    }
}

private struct PageIndicator: View {
    private let dotSize: CGFloat = 6
    
    // Settings
    let totalPages: Int
    let pageNumber: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: Theme.Metrics.halfSpacing) {
            ForEach(0 ..< totalPages, id: \.self) {
                Circle()
                    .foregroundColor(
                        pageNumber == $0 ? Color(Theme.Colors.Fill.theme) : Color(Theme.Colors.Controls.pageIndicator)
                )
                .frame(width: dotSize, height: dotSize)
            }
        }
    }
}
