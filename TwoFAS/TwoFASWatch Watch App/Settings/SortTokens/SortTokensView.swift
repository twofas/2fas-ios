//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
//  Contributed by Grzegorz Machnio. All rights reserved.
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

protocol SortTokensPresenting: ObservableObject {
    func onAppear()
}

final class SortTokensPresenter: SortTokensPresenting {
    func onAppear() {

    }
}

struct SortTokensView<Presenter: SortTokensPresenting>: View {
    @ObservedObject
    var presenter: Presenter

    var body: some View {
        List {

        }
        .containerBackground(.red.gradient, for: .navigation)
        .listStyle(.carousel)
        .environment(\.defaultMinListRowHeight, WatchConsts.minRowHeight)
        .navigationTitle(T.Settings.sortTokens)
        .navigationBarTitleDisplayMode(.automatic)
        .listItemTint(.clear)
    }
}

#Preview {
    final class SortTokensPresenterMock: SortTokensPresenting {
        func onAppear() {}
    }

    return SortTokensView(presenter: SortTokensPresenterMock())
}
