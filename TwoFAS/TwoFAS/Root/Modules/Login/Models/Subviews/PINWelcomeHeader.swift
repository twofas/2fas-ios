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

struct PINWelcomeHeader: View {
    let loginType: LoginType
    
    @Binding
    var info: String?
    
    var body: some View {
        VStack(spacing: .zero) {
            Asset.pinLogo.swiftUIImage
                .padding(.bottom, .M)
                .alignmentGuide(.centerAlign) { d in d[VerticalAlignment.center] }
            VStack(spacing: .S) {
                if loginType == .login {
                    Text(T.Login.helloHeader)
                        .textStyle(.title2, .emphasized)
                        .foregroundStyle(.labelsPrimary)
                        .isHidden(info != nil, remove: false)
                        .animation(.easeInOut, value: info)
                } else {
                    Spacer()
                        .frame(height: Spacing.XL.rawValue)
                }
                let text = info ?? T.Security.enterPinShort
                Text(text)
                    .textStyle(.body)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .foregroundStyle(.labelsSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .animation(.easeInOut, value: text)
            }
            .alignmentGuide(.centerAlign) { d in d[VerticalAlignment.top] }
            .padding(.top, .S)
        }
    }
}

private struct CenterAlignID: AlignmentID {
    static func defaultValue(in d: ViewDimensions) -> CGFloat { d[VerticalAlignment.center] }
}
private extension VerticalAlignment { static let centerAlign = VerticalAlignment(CenterAlignID.self) }
