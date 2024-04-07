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
    @State private var path: [Destination] = []
    
    private enum Destination: Hashable {
        case service(Service)
        case allServices
        case settings
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !presenter.favoriteList.isEmpty {
                    Section(header: Text("Favorite Services")) {
                        ForEach(presenter.favoriteList, id: \.self) { service in
                            NavigationLink(value: Destination.service(service)) {
                                VStack(alignment: .leading) {
                                    Text(service.name)
                                        .font(.callout)
                                        .padding(4)
                                        .foregroundStyle(.primary)
                                    if let additionalInfo = service.additionalInfo {
                                        Text(additionalInfo)
                                            .padding(.horizontal, 4)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                Section {
                    NavigationLink(value: Destination.allServices) {
                        VStack(alignment: .leading) {
                            Text("All Services")
                                .font(.callout)
                                .padding(4)
                                .foregroundStyle(.primary)
                        }
                    }
                    
                    NavigationLink(value: Destination.settings) {
                        VStack(alignment: .leading) {
                            Text("Settings")
                                .font(.callout)
                                .padding(4)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .containerBackground(.red.gradient, for: .navigation)
            .listStyle(.carousel)
            .environment(\.defaultMinListRowHeight, 70)
            .navigationTitle("2FAS")
            .navigationBarTitleDisplayMode(.automatic)
            .listItemTint(.clear)
            .navigationDestination(for: Destination.self, destination: { value in
                switch value {
                case .allServices: ServiceListView()
                case .service(let service): ServiceView(service: service)
                case .settings: SettingsView()
                }
            })
        }
    }
}
