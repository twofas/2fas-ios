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

struct IntroductionInfoSheetContent: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @State
    private var sheetHeight: CGFloat = 500
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack {
                        TFLiquidGlassSymbolButton(symbol: .close) { dismiss() }
                        Spacer()
                    }
                    
                    VStack(spacing: Spacing.XXXL) {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
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
                            
                            Text("It is enabled by default and can be turned off at any time in the backup settings in the app.")
                                .textStyle(.footnote)
                                .foregroundStyle(AppColor.labelsSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Spacing.XXXXXL)
                                .padding(.bottom, .M)
                            
                            TFButton("Understood", variant: .borderedProminent, size: .largeWide, applyGlass: true) {
                                dismiss()
                            }
                        }
                    }
                }
                .padding(.XL)
            }
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                sheetHeight = height
            }
        }
        .presentationDetents([.height(sheetHeight)])
        .presentationCornerRadius(TFCornerRadius.large.rawValue)
        .presentationDragIndicator(.visible)
    }
}
