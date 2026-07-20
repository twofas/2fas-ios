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

struct TrashView: View {
    @Bindable
    var presenter: TrashPresenter

    var body: some View {
        VStack(spacing: .zero) {
            TFScreenTitleBar(
                title: T.Settings.trash,
                showsBackButton: presenter.showsBackButton,
                onBack: presenter.showsBackButton ? presenter.handleBack : nil
            )

            if presenter.services.isEmpty {
                emptyState
            } else {
                trashList
            }
        }
        .background(.backgroundsPrimary)
        .onAppear {
            presenter.viewWillAppear()
        }
    }

    private var emptyState: some View {
        VStack(spacing: .XL) {
            Spacer()
            Image(systemName: "trash.fill")
                .textStyle(.iconLarge)
                .foregroundStyle(.accentsBrand)
            Text(T.Settings.trashIsEmpty)
                .textStyle(.headline)
                .foregroundStyle(.labelsSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .XL)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var trashList: some View {
        List {
            ForEach(presenter.services, id: \.secret) { service in
                trashCell(service)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: .S, leading: .XL, bottom: .S, trailing: .XL))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            presenter.handleDelete(service)
                        } label: {
                            Label(T.Commons.delete, systemImage: "trash.fill")
                        }
                        .tint(AppColor.accentsBrand)

                        Button {
                            presenter.handleRestore(service)
                        } label: {
                            Label(T.Settings.restore, systemImage: "arrow.clockwise")
                        }
                        .tint(AppColor.accentsBlue)
                    }
            }
        }
        .animation(.default, value: presenter.services.count)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private func trashCell(_ service: ServiceData) -> some View {
        HStack(spacing: .M) {
            ServiceIconView(icon: service.iconDetails, showBackground: false)

            VStack(alignment: .leading, spacing: 2) {
                Text(service.name)
                    .textStyle(.body)
                    .foregroundStyle(.labelsPrimary)

                if let additionalInfo = service.additionalInfo, !additionalInfo.isEmpty {
                    Text(additionalInfo)
                        .textStyle(.subheadline)
                        .foregroundStyle(.labelsSecondary)
                }
            }

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
