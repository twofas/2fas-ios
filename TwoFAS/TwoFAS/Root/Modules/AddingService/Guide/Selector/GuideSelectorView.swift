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
import Common

struct GuideSelectorView: View {
    @Environment(\.colorScheme)
    private var colorScheme
    
    private static let itemWidth: CGFloat = 148
    private static let itemHeight: CGFloat = 118
    
    private let columns = [GridItem(.fixed(Self.itemWidth)), GridItem(.fixed(Self.itemWidth))]
    
    @ObservedObject
    var presenter: GuideSelectorPresenter

    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            ZStack {
                HStack(spacing: .zero) {
                    TFLiquidGlassSymbolButton(symbol: .close) {
                        presenter.handleClose()
                    }
                    Spacer()
                    TFLiquidGlassTextButton(T.Guides.requestService) {
                        UIApplication.shared.open(URL(string: "https://2fas.com/your-2fa-guide/")!)
                    }
                }
                TFTitleView(title: T.Guides.selectTitle)
            }
            ScrollView(.vertical) {
                VStack(spacing: .L) {
                    Text(T.Guides.selectDescription)
                        .textStyle(.title2, .emphasized)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.labelsPrimary)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.vertical, .XXXXXL)
                        .frame(maxWidth: .infinity, alignment: .center)
                    LazyVGrid(columns: columns, spacing: Spacing.L.rawValue) {
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
        }
        .padding(.horizontal, .XL)
        .padding(.top, .XL)
        .onAppear {
            presenter.viewDidLoad()
        }
    }

    @ViewBuilder
    private func serviceGuide(_ guide: GuideDescription) -> some View {
        VStack(alignment: .center, spacing: .M) {
            Image(uiImage: guide.serviceIcon)
                .accessibilityHidden(true)
            Text(verbatim: guide.serviceName)
                .textStyle(.body, .medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundStyle(.labelsPrimary)
                .padding(.horizontal, .XL)
        }
        .accessibilityAddTraits(.isButton)
        .padding(.vertical, Spacing.XL)
        .frame(height: Self.itemHeight)
        .frame(minWidth: Self.itemWidth, maxWidth: .infinity)
        .background(.backgroundsPrimaryElevated)
        .overlay {
            RoundedRectangle(cornerRadius: TFCornerRadius.large.rawValue)
                .inset(by: 0.75)
                .stroke(.bordersPrimary, lineWidth: 1.5)
        }
        .onTapGesture {
            presenter.handleShowGuideMenu(guide)
        }
    }
}
