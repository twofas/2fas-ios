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

struct GuideMenuView: View {
    let presenter: GuideMenuPresenter
    
    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            Spacer()
            
            AdaptiveReadableContainer {
                VStack(spacing: .XL) {
                    Image(uiImage: presenter.serviceIcon)
                        .accessibilityHidden(true)
                    VStack(spacing: .M) {
                        Text(verbatim: presenter.serviceName)
                            .textStyle(.title1, .emphasized)
                            .foregroundStyle(.labelsPrimary)
                            .accessibilityAddTraits(.isHeader)
                        Text(verbatim: presenter.header)
                            .textStyle(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.labelsSecondary)
                    }
                }
            }
            
            Spacer()
            
            AdaptiveReadableContainer(verticalMargin: .zero) {
                VStack(spacing: .L) {
                    ForEach(presenter.menuPositions, id: \.self) { menuPosition in
                        TFButton(menuPosition.title, variant: .borderedSecondary, size: .medium) {
                            presenter.handleSelectedMenuPosition(menuPosition)
                        }
                    }
                }
            }
        }
        .navigationTitle(T.Guides.guideTitle(presenter.serviceName))
        .navigationBarTitleDisplayMode(.inline)
    }
}
