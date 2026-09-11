//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

struct TrashServiceView: View {
    @ObservedObject
    var presenter: TrashServicePresenter

    // The sheet detent is the sum of the scrollable content, the pinned bottom bar and the
    // device safe area; when that exceeds the maximum detent only the content scrolls, so the
    // buttons never leave the screen.
    @State private var contentHeight: CGFloat = 0
    @State private var bottomBarHeight: CGFloat = 0
    @State private var bottomSafeArea: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack(spacing: .zero) {
                HStack(spacing: .zero) {
                    TFLiquidGlassSymbolButton(symbol: .close) {
                        presenter.handleCancel()
                    }
                    Spacer()
                }

                VStack(spacing: .XXXL) {
                    TFInfoContent(
                        icon: .image(Asset.trashIcon.image, .original),
                        title: "\(T.Tokens.deleteToken) \(presenter.serviceName)",
                        subtitle: nil,
                        description: T.Tokens.signInNotPossibleTitle(presenter.serviceName, presenter.serviceName)
                    )
                }
                .padding(.top, .M)

                Spacer()
                    .frame(height: Spacing.XXL.rawValue)
            }
            .frame(maxWidth: Theme.Metrics.modalPreferredWidth)
            .padding(.horizontal, .XL)
            .padding(.top, .XL)
            .frame(maxWidth: .infinity)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                contentHeight = height
                reportHeight()
            }
        }
        .scrollContentBackground(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom, spacing: .zero) {
            VStack(spacing: .M) {
                TFButton(
                    T.Tokens.moveToTrash,
                    variant: .borderedProminent,
                    size: .large,
                    applyGlass: true,
                ) {
                    presenter.handleTrashing()
                }

                TFCancelButton(T.Commons.cancel, action: presenter.handleCancel)
            }
            .frame(maxWidth: Theme.Metrics.modalPreferredWidth)
            .padding(.horizontal, .XL)
            .frame(maxWidth: .infinity)
            .minimumBottomSpacing()
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                bottomBarHeight = height
                reportHeight()
            }
        }
        .background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear { bottomSafeArea = proxy.safeAreaInsets.bottom }
                    .onChange(of: proxy.safeAreaInsets.bottom) { _, newValue in
                        bottomSafeArea = newValue
                        reportHeight()
                    }
            }
            .ignoresSafeArea()
        }
    }

    private func reportHeight() {
        guard contentHeight > 0, bottomBarHeight > 0 else { return }
        presenter.handleContentHeight(contentHeight + bottomBarHeight + bottomSafeArea)
    }
}
