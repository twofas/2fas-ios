//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

struct IconSelectorView: View {
    @ObservedObject
    var presenter: IconSelectorPresenter
    
    var body: some View {
        Group {
            if presenter.sections.isEmpty {
                emptyView
            } else {
                content
            }
        }
        .background(AppColor.backgroundsPrimaryElevated)
        .navigationTitle(T.Tokens.changeBrandIcon)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $presenter.searchPhrase, prompt: Text(T.Commons.search))
        .onChange(of: presenter.searchPhrase) { _, newValue in
            presenter.handleSearchChange(newValue)
        }
        .onAppear {
            presenter.viewDidAppear()
        }
    }
    
    @ViewBuilder
    private var emptyView: some View {
        TFEmptyScreen(
            icon: .systemImage(.magnifyingglass, bounces: true),
            title: T.Commons.noResults
        )
    }
    
    @ViewBuilder
    private var content: some View {
        IconSelectorList(
            sections: presenter.sections,
            selectedIconTypeID: presenter.selectedIconTypeID,
            showsOrderIcon: !presenter.isSearching,
            onSelect: { presenter.handleSelection(iconTypeID: $0) },
            onUserIcon: { presenter.handleOrderIconUser() },
            onCompanyIcon: { presenter.handleOrderIconCompany() }
        )
    }
}
