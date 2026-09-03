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
    let action: Callback
    let cancel: Callback
    
    var body: some View {
        NavigationStack {
            TFInfoView(
                icon: .systemImage(.exclamationmarkTriangle),
                title: "\(T.Commons.warning.uppercased())!",
                description: T.Settings.widgetsTitle,
                buttons: {
                    TFButton(T.Commons.continue, variant: .borderedProminent, size: .large, action: action)
                    TFCancelButton(T.Commons.cancel, action: cancel)
                })
            .navigationBarTitleDisplayMode(.inline)
            .closeToolbar {
                cancel()
            }
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

#Preview {
    WidgetWarning(action: {}, cancel: {})
}
