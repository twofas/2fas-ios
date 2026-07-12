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

struct WidgetWarning: View {
    private let icon = Asset.widgetWarningIcon.image

    let action: Callback
    let cancel: Callback

    var body: some View {
        TFInfoView {
            Image(uiImage: icon)
                .resizable()
                .frame(width: icon.size.width / 2.0, height: icon.size.height / 2.0)
        } texts: {
            Text("\(T.Commons.warning.uppercased())!")
                .textStyle(.title1, .emphasized)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.center)
            Text(T.Settings.widgetsTitle)
                .textStyle(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.labelsPrimary)
        } buttons: {
            TFButton(T.Commons.continue, variant: .borderedProminent, size: .large, action: action)
            TFButton(T.Commons.cancel, variant: .borderless, size: .large, action: cancel)
        }
    }
}

struct WidgetWarning_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetWarning(
                action: { print("Action!") },
                cancel: { print("Cancel!") }
            )
            .previewDevice("iPhone SE (1st generation)")
            WidgetWarning(
                action: { print("Action!") },
                cancel: { print("Cancel!") }
            )
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 13 Pro Max")
        }
    }
}
