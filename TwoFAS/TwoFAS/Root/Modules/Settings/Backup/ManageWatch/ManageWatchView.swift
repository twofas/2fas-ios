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

    var body: some View {
        content
        .background(.backgroundsPrimaryElevated)
        .navigationTitle(T.Backup.managePairedWatchesTitleShort)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    presenter.onClose()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.onPairWatch()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(T.Commons.add)
            }
        }
        .onAppear {
            presenter.onAppear()
        }
    }

    @ViewBuilder
    private var content: some View {
        if !presenter.isListAvailable {
            TFLoadingView(title: T.Backup.managePairedWatchesSyncing)
        } else if presenter.list.isEmpty {
            emptyState
        } else {
            watchList
        }
    }

    private var emptyState: some View {
        TFEmptyScreen(
            systemImage: "applewatch",
            title: T.Backup.managePairedWatchesEmptyList
        )
    }

    private var watchList: some View {
        List {
            ForEach(presenter.list) { item in
                watchCell(item)
                    .padding(.bottom, .XL)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
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
        AdaptiveReadableContainer(horizontalMargin: .zero, verticalMargin: .zero) {
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
                    .foregroundStyle(.backgroundsSecondary)
            )
            .frame(minHeight: .list)
        }
    }
}
