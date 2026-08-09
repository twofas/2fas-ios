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

struct BrowserExtensionServiceView: View {
    @Bindable
    var presenter: BrowserExtensionServicePresenter

    var body: some View {
        TFListScreen {
            ForEach(presenter.sections) { section in
                sectionView(section)
            }
        }
        .background(.backgroundsPrimary)
        .navigationTitle(T.Browser.browserExtension)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.viewWillAppear()
        }
        .alert(
            T.Browser.deletingPairedDeviceTitle,
            isPresented: $presenter.showUnpairAlert
        ) {
            Button(T.Commons.cancel, role: .cancel) {}
            Button(T.Commons.delete, role: .destructive) {
                presenter.handleConfirmUnpair()
            }
        } message: {
            Text(T.Browser.deletingPairedDeviceContent)
        }
    }

    @ViewBuilder
    private func sectionView(_ section: BrowserExtensionServiceSection) -> some View {
        TFListSection {
            ForEach(Array(section.cells.enumerated()), id: \.element.id) { index, cell in
                row(for: cell)
                if index < section.cells.count - 1 {
                    TFListSeparator()
                }
            }
        }
    }

    @ViewBuilder
    private func row(for cell: BrowserExtensionServiceCell) -> some View {
        switch cell.kind {
        case .name(let name):
            infoRow(title: T.Browser.name, value: name)
        case .date(let date):
            infoRow(title: T.Browser.pairingDate, value: date)
        case .unpair:
            Button {
                presenter.handleUnpairTap()
            } label: {
                actionRow(title: T.Browser.forgetThisBrowser)
            }
            .buttonStyle(.plain)
        }
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack(spacing: .ML) {
            Text(title)
                .textStyle(.body)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(value)
                .textStyle(.body)
                .foregroundStyle(.labelsSecondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, .L)
        .contentShape(Rectangle())
    }

    private func actionRow(title: String) -> some View {
        Text(title)
            .textStyle(.body)
            .foregroundStyle(.accentsBrand)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, .L)
            .contentShape(Rectangle())
    }
}
