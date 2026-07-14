//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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

struct ManageWatchView: View {
    @ObservedObject
    var presenter: ManageWatchPresenter

    private let minHeight: CGFloat = 68

    var body: some View {
        VStack(spacing: .zero) {
            TFScreenTitleBar(
                title: T.Backup.managePairedWatchesTitleShort,
                leadingSymbol: .close,
                onLeadingTap: presenter.onClose
            ) {
                TFLiquidGlassSymbolButton(symbol: .add) {
                    presenter.onPairWatch()
                }
                .accessibilityLabel(T.Commons.add)
            }

            content
        }
        .background(.backgroundsPrimaryElevated)
        .onAppear {
            presenter.onAppear()
        }
    }

    @ViewBuilder
    private var content: some View {
        if !presenter.isListAvailable {
            syncingState
        } else if presenter.list.isEmpty {
            emptyState
        } else {
            watchList
        }
    }

    private var emptyState: some View {
        VStack(spacing: .XL) {
            Spacer()
            Image(systemName: "applewatch")
                .textStyle(.iconLarge)
                .foregroundStyle(.accentsBrand)
            Text(T.Backup.managePairedWatchesEmptyList)
                .textStyle(.headline)
                .foregroundStyle(.labelsSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .XL)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var syncingState: some View {
        VStack(spacing: .XL) {
            Spacer()
            ProgressView()
            Text(T.Backup.managePairedWatchesSyncing)
                .textStyle(.headline)
                .foregroundStyle(.labelsSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .XL)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var watchList: some View {
        List {
            ForEach(presenter.list) { item in
                watchCell(item)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: .S, leading: .XL, bottom: .S, trailing: .XL))
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            presenter.onDelete(item)
                        } label: {
                            Label(T.Commons.delete, systemImage: "trash.fill")
                        }
                        .tint(AppColor.accentsBrand)

                        Button {
                            presenter.onRename(item)
                        } label: {
                            Label(T.Commons.rename, systemImage: "pencil")
                        }
                        .tint(AppColor.accentsBlue)
                    }
            }
        }
        .animation(.default, value: presenter.list.count)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private func watchCell(_ item: PairedWatch) -> some View {
        HStack(spacing: .M) {
            Image(systemName: "applewatch")
                .textStyle(.title3)
                .foregroundStyle(.accentsBrand)
                .frame(width: 28)

            Text(item.deviceName)
                .textStyle(.body)
                .foregroundStyle(.labelsPrimary)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, .XL)
        .padding(.vertical, .L)
        .background(
            RoundedRectangle(cornerRadius: TFCornerRadius.large.rawValue, style: .continuous)
                .foregroundStyle(.backgroundsSecondaryElevated)
        )
        .frame(minHeight: minHeight)
    }
}
