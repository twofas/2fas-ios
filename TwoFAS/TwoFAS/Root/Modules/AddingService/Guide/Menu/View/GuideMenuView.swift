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

struct GuideMenuView: View {
    let presenter: GuideMenuPresenter
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 2 * Theme.Metrics.doubleMargin) {
                Image(uiImage: presenter.serviceIcon)
                Text(verbatim: presenter.serviceName)
                    .font(Font(Theme.Fonts.Text.title))
                    .foregroundStyle(Color(Theme.Colors.Text.main))
                Text(verbatim: presenter.header)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(Theme.Colors.Text.main))
            }
            .padding(2 * Theme.Metrics.doubleMargin)
            .padding(.top, 4 * Theme.Metrics.doubleMargin)
            .frame(alignment: .top)
            
            Spacer()
            
            VStack {
                Text(verbatim: presenter.menuTitle)
                    .font(.footnote)
                    .textCase(.uppercase)
                    .foregroundStyle(Color(Theme.Colors.inactiveInverted))
                    .padding(.horizontal, Theme.Metrics.doubleMargin)
                    .frame(maxWidth: .infinity, alignment: .leading)
                AddingServiceDividerView()
                VStack {
                    ForEach(presenter.menuPositions, id: \.self) { menuPosition in
                        Button(action: {
                            presenter.handleSelectedMenuPosition(menuPosition)
                        }, label: {
                            VStack {
                                HStack {
                                    Text(verbatim: menuPosition.title)
                                        .font(.body)
                                        .foregroundStyle(Color(Theme.Colors.Text.main))
                                        .padding(.leading, Theme.Metrics.doubleMargin)
                                        .padding(.vertical, Theme.Metrics.doubleMargin)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color(Theme.Colors.Line.secondarySeparator))
                                        .font(.system(size: 18))
                                        .padding(.trailing, Theme.Metrics.doubleMargin)
                                        .frame(alignment: .trailing)
                                }
                                AddingServiceDividerView()
                            }
                        })
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
        }
    }
}
