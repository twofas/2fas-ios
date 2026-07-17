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

public enum ToastStyle {
    case success
    case failure
    case info
    case warning
}

public struct ToastContentView: View {

    let text: Text
    let style: ToastStyle
    let icon: Image?

    public init(text: Text, style: ToastStyle, icon: Image? = nil) {
        self.text = text
        self.style = style
        self.icon = icon
    }

    @Environment(\.colorScheme)
    private var colorScheme

    public var body: some View {
        HStack(spacing: Spacing.M.value) {
            (icon ?? defaultIcon)
                .font(.system(size: 28))
                .foregroundStyle(iconColor)

            text
                .textStyle(.subheadline, .emphasized)
                .foregroundStyle(AppColor.labelsPrimary)
                .padding(.trailing, Spacing.XS.value)
                .lineLimit(3)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, Spacing.XL.value)
        .padding(.vertical, Spacing.M.value)
    }

    private var defaultIcon: Image {
        switch style {
        case .success:
            Image(systemName: "checkmark.circle.fill")
        case .failure:
            Image(systemName: "xmark.circle.fill")
        case .info:
            Image(systemName: "info.circle.fill")
        case .warning:
            Image(systemName: "exclamationmark.triangle.fill")
        }
    }

    private var iconColor: AppColor {
        switch style {
        case .success: return .accentsGreen
        case .warning: return .accentsOrange
        case .failure: return .accentsBrand
        case .info: return .accentsBlue
        }
    }
}

#Preview {
    VStack(spacing: 50) {
        ToastContentView(text: Text("Success"), style: .success)
        ToastContentView(text: Text("Warning"), style: .warning)
        ToastContentView(text: Text("Failure"), style: .failure)
        ToastContentView(text: Text("Info"), style: .info)
    }
}
