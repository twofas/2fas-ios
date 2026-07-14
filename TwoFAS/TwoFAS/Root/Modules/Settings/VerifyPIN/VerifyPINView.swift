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

struct VerifyPINView: View {
    @Bindable
    var presenter: VerifyPINPresenter

    var body: some View {
        VStack(spacing: .zero) {
            TFScreenTitleBar(
                title: T.Backup.verifyPin,
                leadingSymbol: presenter.leadingSymbol,
                onLeadingTap: { presenter.handleCancel() }
            )

            VStack(spacing: .XXXL) {
                Text(presenter.info)
                    .textStyle(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(presenter.isError ? AppColor.accentsBrand : AppColor.labelsSecondary)
                    .animation(.easeInOut, value: presenter.info)
                    .padding(.horizontal, .XL)

                Spacer()

                PINDots(count: presenter.totalDigits, enteredCount: $presenter.enteredDigitCount)
                    .disabled(presenter.isLocked)
                    .shake(on: presenter.shake)
                    .sensoryFeedback(.error, trigger: presenter.shake) { _, new in new }

                PINKeyboard(action: presenter.onKeyPressed)
                    .disabled(presenter.isLocked)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.backgroundsPrimary)
        .onAppear {
            presenter.viewWillAppear()
        }
    }
}
