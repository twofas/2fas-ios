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
import UIKit
import CommonWatch

struct SortTokensView<Presenter: SortTokensPresenting>: View {
    @ObservedObject
    var presenter: Presenter

    var body: some View {
        List {
            ForEach(presenter.sortTypes, id: \.rawValue) { sortType in
                HStack {
                    Image(uiImage: sortType.image(
                        forSelectedOption: sortType,
                        configuration: (UIImage.SymbolConfiguration(weight: presenter.currentSortType == sortType ? .heavy : .regular)))
                    )
                    .foregroundColor(.primary)

                    Text(sortType.localized)
                        .font(.callout)
                        .fontWeight(presenter.currentSortType == sortType ? .heavy : .regular)
                        .padding(4)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    presenter.set(sortType)
                }
            }
        }
        .containerBackground(.red.gradient, for: .navigation)
        .listStyle(.carousel)
        .environment(\.defaultMinListRowHeight, WatchConsts.minRowHeight)
        .navigationTitle(T.Settings.sortTokens)
        .navigationBarTitleDisplayMode(.automatic)
        .listItemTint(.clear)
        .onAppear {
            presenter.onAppear()
        }
    }

    private func sortOptionRow(image: Image, title: String) -> some View {
        HStack {
            image
                .foregroundColor(.primary)
            Text(title)
                .font(.callout)
                .padding(4)
                .foregroundStyle(.primary)
        }
    }
}

extension SortType {
    var localized: String {
        switch self {
        case .az: return T.Tokens.sortByAToZ
        case .za: return T.Tokens.sortByZToA
        case .manual: return T.Tokens.sortByManual
        }
    }

    func image(forSelectedOption option: Self, configuration: UIImage.SymbolConfiguration) -> UIImage {
        var image: UIImage?
        switch self {
        case .az: image = UIImage(systemName: "arrow.down")
        case .za: image = UIImage(systemName: "arrow.up")
        case .manual: image = UIImage(systemName: "line.3.horizontal")
        }

        if self == option {
            image = image?.withConfiguration(configuration)
        }
        return image?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    }
}

#Preview {
    final class SortTokensPresenterMock: SortTokensPresenting {
        var currentSortType: CommonWatch.SortType = .manual
        var sortTypes: [CommonWatch.SortType] = CommonWatch.SortType.allCases

        func onAppear() {}
        func set(_ sortType: SortType) {}
    }

    return SortTokensView(presenter: SortTokensPresenterMock())
}
