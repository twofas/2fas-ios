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
import Data

struct GuideSelectorView: View {
    private static let itemWidth: CGFloat = 148
    private static let itemHeight: CGFloat = 118
    private let columns = [GridItem(.fixed(Self.itemWidth)), GridItem(.fixed(Self.itemWidth))]
    let presenter: GuideSelectorPresenter
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: Theme.Metrics.standardSpacing) {
                Text(T.Guides.selectDescription)
                    .font(.footnote)
                    .textCase(.uppercase)
                    .foregroundStyle(Color(Theme.Colors.inactiveInverted))
                    .padding(.vertical, Theme.Metrics.doubleMargin)
                LazyVGrid(columns: columns, spacing: Theme.Metrics.doubleMargin) {
                    ForEach(presenter.guides.chunked(into: 2), id: \.self) { values in
                        if let first = values.first {
                            serviceGuide(first)
                        }
                        if let last = values.last {
                            serviceGuide(last)
                        }
                    }
                }
            }
        }
        VStack(alignment: .center) {
            Text(verbatim: T.Guides.selectProvideGuide)
                .font(.footnote)
                .foregroundStyle(Color(Theme.Colors.Line.active))
                .padding(.vertical, Theme.Metrics.doubleMargin)
            Link(destination: URL(string: "https://2fas.com/your-2fa-guide/")!) {
                HStack(spacing: Theme.Metrics.halfSpacing) {
                    Text(verbatim: T.Guides.selectProvideGuideCta)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(Theme.Colors.Text.theme))
                    Asset.externalLinkIcon.swiftUIImage
                        .foregroundStyle(Color(Theme.Colors.Text.theme))
                }
            }
        }
        .padding(.bottom, Theme.Metrics.doubleMargin)
        .frame(maxWidth: .infinity)
        .background(Color(Theme.Colors.Fill.notification))
    }
    
    @ViewBuilder
    private func serviceGuide(_ guide: GuideDescription) -> some View {
        VStack(alignment: .center, spacing: Theme.Metrics.mediumMargin) {
            Image(uiImage: guide.serviceIcon)
            Text(verbatim: guide.serviceName)
                .foregroundStyle(Color(Theme.Colors.Text.main))
                .font(.footnote)
                .padding(.horizontal, Theme.Metrics.doubleMargin)
        }
        .padding(.vertical, Theme.Metrics.doubleMargin)
        .frame(width: Self.itemWidth, height: Self.itemHeight)
        .background {
            let size = CGSize(width: Theme.Metrics.modalCornerRadius, height: Theme.Metrics.modalCornerRadius)
            RoundedRectangle(cornerSize: size)
                .stroke(Color(Theme.Colors.Line.secondarySeparator), lineWidth: 1)
        }
        .onTapGesture {
            presenter.handleShowGuideMenu(guide)
        }
    }
}
