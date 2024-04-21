//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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

struct SettingsView: View {
    @Binding
    var path: NavigationPath
    
    var body: some View {
            List {
                NavigationLink(value: SettingsPath.security) {
                    HStack {
                        Image(systemName: "lock.fill")
                        Text(T.Settings.security)
                            .font(.callout)
                            .padding(4)
                            .foregroundStyle(.primary)
                    }
                }
                
                NavigationLink(value: SettingsPath.about) {
                    HStack {
                        Image(systemName: "info.bubble.fill")
                        Text(T.Settings.about)
                            .font(.callout)
                            .padding(4)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .navigationDestination(for: SettingsPath.self) { route in
                switch route {
                case .security: SecurityView(
                    path: $path,
                    presenter: SecurityPresenter(
                        interactor: InteractorFactory.shared.securityInteractor()
                    )
                )
                case .about: AboutView()
                }
            }
        .containerBackground(.red.gradient, for: .navigation)
        .listStyle(.carousel)
        .environment(\.defaultMinListRowHeight, WatchConsts.minRowHeight)
        .navigationTitle(T.Settings.settings)
        .navigationBarTitleDisplayMode(.automatic)
        .listItemTint(.clear)
    }
}

enum SettingsPath: Hashable {
    case security
    case about
}
