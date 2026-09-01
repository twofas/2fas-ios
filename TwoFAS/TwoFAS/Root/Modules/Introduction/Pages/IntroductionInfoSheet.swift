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

struct IntroductionInfoSheetContent: View {
    
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        SheetContent(
            sizing: .fitContent,
            onClose: { dismiss() }
        ) {
            AdaptiveReadableContainer(verticalMargin: .zero) {
                VStack(spacing: Spacing.XXXL) {
                    Image(icon: .arrowTrianglehead2ClockwiseRotate90)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(AppColor.accentsBrand)

                    VStack(spacing: Spacing.M) {
                        Text(T.Introduction.backupIcloudTitle)
                            .textStyle(.title2, .emphasized)
                            .foregroundStyle(AppColor.labelsPrimary)
                            .multilineTextAlignment(.center)

                        Text(T.Introduction.backupIcloudDescription)
                            .textStyle(.callout)
                            .foregroundStyle(AppColor.labelsPrimary)
                            .multilineTextAlignment(.center)

                        Spacer()
                            .frame(height: Spacing.XXXXXL.rawValue)

                        Text(T.Introduction.backupIcloudDescriptionNote)
                            .textStyle(.footnote)
                            .foregroundStyle(AppColor.labelsSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.XXXXXL)
                    }
                }
            }
            .padding(.bottom, .XXL)
        } buttons: {
            TFButton(
                T.Commons.understood,
                variant: .borderedProminent,
                size: .large,
                applyGlass: true
            ) {
                dismiss()
            }
        }
        .balancedBottomSpacing(false)
    }
}
