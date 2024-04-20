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
                                    Text("Favorite Services")
                                }
                        ) {
                        ForEach(presenter.favoriteList, id: \.self) { service in
                            NavigationLink(destination: ServiceView(
                                presenter: ServicePresenter(
                                    interactor: InteractorFactory.shared.serviceInteractor(service: service)
                                )
                            )
                            ) {
                                ServiceCellView(service: service)
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        }
                    }
                }
                Section {
                    NavigationLink(destination: ServiceListView(
                        presenter: ServiceListPresenter(
                            interactor: InteractorFactory.shared.serviceListInteractor()
                        )
                    )) {
                        HStack(alignment: .center) {
                            Image(systemName: "folder")
                            Text("All Services")
                                .font(.callout)
                                .padding(4)
                                .foregroundStyle(.primary)
                        }
                    }
                    
                    NavigationLink(value: MainPath.settings) {
                        HStack(alignment: .center) {
                            Image(systemName: "gear")
                            Text("Settings")
                                .font(.callout)
                                .padding(4)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .navigationDestination(for: MainPath.self) { route in
                SettingsView(path: $path)
            }
            .onAppear {
                presenter.onAppear()
            }
            .containerBackground(.red.gradient, for: .navigation)
            .listStyle(.carousel)
            .environment(\.defaultMinListRowHeight, 50)
            .navigationTitle("2FAS")
            .navigationBarTitleDisplayMode(.automatic)
            .listItemTint(.clear)
        }
    }
}

enum MainPath: Hashable {
    case settings
}
