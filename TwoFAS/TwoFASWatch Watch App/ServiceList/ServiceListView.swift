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

struct ServiceListView: View {
    @ObservedObject var presenter: ServiceListPresenter
    
    var body: some View {
        Group {
            if presenter.list.isEmpty {
                VStack(alignment: .center, spacing: 4) {
                    Image(systemName: "folder")
                    Text("No services")
                }
            } else {
                NavigationStack {
                    List {
                        ForEach(presenter.list, id: \.self) { category in
                            Section(header: Text(category.name)) {
                                ForEach(category.services, id: \.self) { service in
                                    NavigationLink(
                                        destination: ServiceView(
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
                    }
                }
            }
        }
        .onAppear {
            presenter.onAppear()
        }
        .containerBackground(.red.gradient, for: .navigation)
        .listStyle(.carousel)
        .environment(\.defaultMinListRowHeight, 60)
        .navigationTitle("Services")
        .navigationBarTitleDisplayMode(.automatic)
        .listItemTint(.clear)
    }
}