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

struct AppReset: View {
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(maxHeight: .infinity)
                
                AdaptiveReadableContainer {
                    TFInfoContent(
                        icon: .view(view: AnyView(
                            BorderShield(showDeleteIcon: true)
                                .padding(.bottom, .M)
                        )),
                        title: T.Restore.Reset.title,
                        description: T.Restore.resetPinTitle
                    )
                }
                
                Spacer()
                    .frame(maxHeight: .infinity)
                
                AdaptiveReadableContainer {
                    VStack(spacing: .XXXL) {
                        infoFrame
                        
                        TFButton(
                            T.Commons.dismiss,
                            variant: .borderedProminent,
                            size: .large,
                            applyGlass: true
                        ) {
                            dismiss()
                        }
                    }
                }
                .frame(alignment: .bottom)
            }
            .closeToolbar {
                dismiss()
            }
        }
        .background(.backgroundsPrimaryElevated)
        .minimumBottomSpacing()
        .presentationDetents([.large])
        .presentationCornerRadius(TFCornerRadius.large.rawValue)
        .presentationDragIndicator(.hidden)
    }
    
    @ViewBuilder
    private var infoFrame: some View {
        VStack(spacing: .M) {
            Image(icon: .exclamationmarkTriangle)
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
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.XL)
        .background(.backgroundsSecondaryElevated)
        .cornerRadius(TFCornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: TFCornerRadius.large.rawValue)
                .inset(by: 1)
                .stroke(AppColor.bordersPrimary, lineWidth: 1)
        )
    }
}
