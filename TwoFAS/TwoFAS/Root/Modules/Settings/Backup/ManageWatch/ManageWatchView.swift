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
//  along with this program. If not, see <https://w2ww.gnu.org/licenses/>
//

import SwiftUI

struct ManageWatchView: View {
    @ObservedObject
    var presenter: ManageWatchPresenter
    
    var body: some View {
        NavigationStack {
            mainView
            .onAppear {
                presenter.onAppear()
            }
            .navigationTitle(T.Backup.managePairedWatchesTitleShort)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(T.Commons.close) {
                        presenter.onClose()
                    }
                    .tint(Color(Theme.Colors.Icon.theme))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presenter.onPairWatch()
                    }, label: {
                        Label(T.Commons.add, systemImage: "plus")
                    })
                    .tint(Color(Theme.Colors.Icon.theme))
                }
            }
        }
    }
    
    @ViewBuilder
    private var mainView: some View {
        VStack {
            if presenter.isListAvailable {
                if presenter.list.isEmpty {
                    Text(T.Backup.managePairedWatchesEmptyList)
                        .font(.caption)
                        .fontWeight(.semibold)
                } else {
                    list()
                }
            } else {
                Text(verbatim: T.Backup.managePairedWatchesSyncing)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
    }
    
    @ViewBuilder
    private func list() -> some View {
        Spacer()
        List {
            ForEach(presenter.list) { item in
                Text(item.deviceName)
                    .padding(.vertical, Theme.Metrics.standardSpacing)
                    .font(.title2)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            presenter.onDelete(item)
                        } label: {
                            Label(T.Commons.delete, systemImage: "trash")
                        }
                        .tint(.red)
                        
                        Button {
                            presenter.onRename(item)
                        } label: {
                            Label(T.Commons.rename, systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
}
