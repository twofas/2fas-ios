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
import CommonUI

struct AppReset: View {
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    TFLiquidGlassSymbolButton(symbol: .close) { dismiss() }
                    Spacer()
                }
                .frame(alignment: .top)
                
                Spacer()
                    .frame(maxHeight: .infinity)
                
                VStack(spacing: .XXXL) {
                    infoFrame
                    
                    TFButton(
                        T.Commons.dismiss,
                        variant: .borderedProminent,
                        size: .largeWide,
                        applyGlass: true
                    ) {
                        dismiss()
                    }
                }
                .frame(alignment: .bottom)
            }
            
            VStack(spacing: 0) {
                VStack(spacing: .XXXL) {
                    BorderShield()
                    VStack(spacing: .M) {
                        Text(T.Restore.Reset.title)
                            .textStyle(.title2, .emphasized)
                            .foregroundStyle(AppColor.labelsPrimary)

                        Text(T.Restore.resetPinTitle)
                            .textStyle(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AppColor.labelsPrimary)
                    }
                }
                .frame(maxWidth: .infinity)

                Spacer()
                    .containerRelativeFrame(.vertical) { size, _ in size * 0.3 }
            }
        }
        .padding(.XL)
        .presentationDetents([.large])
        .presentationCornerRadius(TFCornerRadius.large.rawValue)
        .presentationDragIndicator(.hidden)
    }
    
    @ViewBuilder
    private var infoFrame: some View {
        VStack(spacing: .M) {
            Image(systemName: "exclamationmark.triangle")
                .textStyle(.title2)
                .foregroundStyle(AppColor.labelsPrimary)
            
            Text(T.Commons.warning)
                .textStyle(.headline)
                    .foregroundStyle(AppColor.labelsPrimary)
            
            Text(T.Restore.backupAdvice)
                .multilineTextAlignment(.center)
                .textStyle(.footnote)
                .foregroundStyle(AppColor.labelsPrimary)
                .padding(.horizontal, .XL)
        }
        .frame(maxWidth: .infinity)
        .padding(.XL)
        .background(.backgroundsPrimaryElevated)
        .cornerRadius(TFCornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: TFCornerRadius.large.rawValue)
                .stroke(AppColor.bordersPrimary, lineWidth: 1)
        )
    }
}
