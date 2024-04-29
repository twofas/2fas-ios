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
                VStack(alignment: .center, spacing: 8) {
                    Image(systemName: "folder")
                        .font(.system(size: 40))
                    Text(T.Tokens.tokensListIsEmpty)
                }
            } else {
                List {
                    ForEach(presenter.list, id: \.self) { category in
                        Section(header: Text(category.name)) {
                            ForEach(category.services, id: \.self) { service in
                                NavigationLink(value: ServiceListPath.service(service)) {
                                    ServiceCellView(service: service)
                                }
                                .listRowBackground(Color.clear)
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .listSectionSpacing(WatchConsts.listSectionRowSpacing)
                            }
                        }
                    }
                }
            }
        }
        .navigationDestination(for: ServiceListPath.self, destination: { route in
            switch route {
            case .service(let service):
                ServiceView(
                    presenter: ServicePresenter(
                        interactor: InteractorFactory.shared.serviceInteractor(service: service)
                    )
                )
            }
        })
        .onAppear {
            presenter.onAppear()
        }
        .containerBackground(.red.gradient, for: .navigation)
        .listStyle(.carousel)
        .environment(\.defaultMinListRowHeight, WatchConsts.minRowHeight)
        .navigationTitle(T.Commons.tokens)
        .navigationBarTitleDisplayMode(.automatic)
        .listItemTint(.clear)
    }
}

enum ServiceListPath: Hashable {
    case service(Service)
}
