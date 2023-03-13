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

struct UploadLogsFailureView: View {
    private let spacing: CGFloat = Theme.Metrics.doubleSpacing
    
    private let image = Asset.errorIcon.image
    
    let close: Callback
    let retry: Callback
    let reason: String
    let canRetry: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
            HStack(spacing: spacing) {
                Image(uiImage: image)
                    .renderingMode(.original)
                    .frame(width: image.size.width, height: image.size.height)
            }
            .frame(maxHeight: .infinity, alignment: .center)
            
            VStack(spacing: spacing) {
                Text(verbatim: T.Settings.sendLogsErrorTitle)
                    .font(.title)
                    .multilineTextAlignment(.center)
                Text(reason)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .frame(alignment: .top)
            }
            .frame(alignment: .center)
            .layoutPriority(1)
            
            VStack(spacing: 0) {
                Button {
                    close()
                } label: {
                    Text(T.Commons.close)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                .buttonStyle(RoundedFilledButtonStyle())
                
                if canRetry {
                    Button {
                        retry()
                    } label: {
                        Text(T.Commons.retry)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .buttonStyle(LinkButtonStyle())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(maxWidth: Theme.Metrics.componentWidth)
        .navigationBarHidden(true)
    }
}

struct UploadLogsFailureView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UploadLogsFailureView(
                close: {},
                retry: {},
                reason: UploadLogsModuleInteractorError.expired.reason,
                canRetry: true
            )
                .previewDevice("iPhone SE (1st generation)")
            UploadLogsFailureView(
                close: {},
                retry: {},
                reason: UploadLogsModuleInteractorError.notExists.reason,
                canRetry: false
            )
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 13 Pro Max")
        }
    }
}
