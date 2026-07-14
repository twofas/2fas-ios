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

struct ExporterPINView: View {
    @Bindable
    var presenter: ExporterPINPresenter

    var body: some View {
        VStack(spacing: .S) {
            titleBar()

            VStack(spacing: .S) {
                Spacer()
                header()
                Spacer()
            }

            PINDots(count: presenter.totalDigits, enteredCount: $presenter.enteredDigitCount)
                .shake(on: presenter.shake)
                .sensoryFeedback(.error, trigger: presenter.shake) { _, new in new }

            PINKeyboard(action: presenter.onKeyPressed)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.backgroundsPrimary)
        .onAppear {
            presenter.viewWillAppear()
        }
    }

    @ViewBuilder
    private func titleBar() -> some View {
        ZStack {
            HStack(spacing: .zero) {
                TFLiquidGlassSymbolButton(symbol: .close) {
                    presenter.handleCancel()
                }
                Spacer()
            }
            TFTitleView(title: T.Backup.verifyPin)
        }
        .padding(.horizontal, .XXXL)
        .padding(.top, .XL)
        .frame(alignment: .top)
    }

    @ViewBuilder
    private func header() -> some View {
        VStack(spacing: .M) {
            Asset.pinLogo.swiftUIImage
            Text(presenter.info)
                .textStyle(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(presenter.isError ? AppColor.accentsBrand : AppColor.labelsSecondary)
                .animation(.easeInOut, value: presenter.info)
        }
    }
}
