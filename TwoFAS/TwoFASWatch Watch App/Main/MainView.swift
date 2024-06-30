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

struct MainView: View {
    @ObservedObject var presenter: MainPresenter
    @State private var selectedService: Service?
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !presenter.favoriteList.isEmpty {
                    Section(header:
                                HStack(alignment: .center) {
                        Image(systemName: "star.fill")
                        Text(T.Tokens.favoriteServices)
                    }
                    ) {
                        ForEach(presenter.favoriteList, id: \.self) { service in
                            NavigationLink(value: MainPath.favorite(service)) {
                                ServiceCellView(service: service)
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .listSectionSpacing(WatchConsts.listSectionRowSpacing)
                        }
                    }
                }
                Section {
                    NavigationLink(value: MainPath.tokens) {
                        HStack(alignment: .center) {
                            Image(systemName: "folder")
                            Text(T.Commons.tokens)
                                .font(.callout)
                                .padding(4)
                                .foregroundStyle(.primary)
                        }
                    }
                    
                    NavigationLink(value: MainPath.settings) {
                        HStack(alignment: .center) {
                            Image(systemName: "gear")
                            Text(T.Settings.settings)
                                .font(.callout)
                                .padding(4)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .navigationDestination(for: MainPath.self) { route in
                switch route {
                case .settings: SettingsView(path: $path)
                case .tokens: ServiceListView(presenter: ServiceListPresenter(
                    interactor: InteractorFactory.shared.serviceListInteractor()
                ))
                case .favorite(let service):
                    ServiceView(
                        presenter: ServicePresenter(
                        interactor: InteractorFactory.shared.serviceInteractor(service: service)
                        )
                    )
                }
            }
            .onAppear {
                presenter.onAppear()
            }
            .containerBackground(.red.opacity(0.7).gradient, for: .navigation)
            .listStyle(.carousel)
            .environment(\.defaultMinListRowHeight, WatchConsts.minRowHeight)
            .navigationTitle(T.Commons._2fasToolbar)
            .navigationBarTitleDisplayMode(.automatic)
            .listItemTint(.clear)
        }
    }
}

enum MainPath: Hashable {
    case settings
    case tokens
    case favorite(Service)
}
