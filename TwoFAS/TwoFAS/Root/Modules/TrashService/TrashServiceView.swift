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
                    Image(uiImage: Asset.trashIcon.image)
                        .renderingMode(.original)
                        .accessibilityHidden(true)

                    VStack(spacing: .M) {
                        Text("\(T.Tokens.deleteToken) \(presenter.serviceName)")
                            .textStyle(.title2, .emphasized)
                            .foregroundStyle(.labelsPrimary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(T.Tokens.signInNotPossibleTitle(presenter.serviceName, presenter.serviceName))
                            .textStyle(.callout)
                            .foregroundStyle(.labelsPrimary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, .M)

                Spacer()
                    .frame(height: Spacing.XXL.rawValue)

                VStack(spacing: .M) {
                    TFButton(
                        T.Tokens.moveToTrash,
                        variant: .borderedProminent,
                        size: .large,
                        applyGlass: true,
                    ) {
                        presenter.handleTrashing()
                    }

                    TFButton(
                        T.Commons.cancel,
                        variant: .borderlessNeutral,
                        size: .large
                    ) {
                        presenter.handleCancel()
                    }
                }
            }
            .frame(maxWidth: Theme.Metrics.modalPreferredWidth)
            .padding(.horizontal, .XL)
            .padding(.top, .XL)
            .padding(.bottom, 0)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                presenter.handleContentHeight(height)
            }
        }
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
    }
}
