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

struct ComposeServiceWebExtensionView: View {
    @ObservedObject
    var presenter: ComposeServiceWebExtensionPresenter

    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            ZStack {
                HStack(spacing: .zero) {
                    TFLiquidGlassSymbolButton(symbol: .back) {
                        presenter.handleBack()
                    }
                    Spacer()
                }
                TFTitleView(title: T.Browser.browserExtension)
            }
            .padding(.horizontal, .XL)
            .padding(.top, .XL)

            ScrollView {
                AdaptiveReadableContainer {
                    VStack(alignment: .leading, spacing: .XXXL) {
                        Text(T.Browser.pairedDomainsListTitle)
                            .textStyle(.title2, .emphasized)
                            .foregroundStyle(.labelsPrimary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, .L)

                        ForEach(presenter.sections) { section in
                            VStack(alignment: .leading, spacing: .zero) {
                                ListSectionHeaderView(title: section.title)

                                VStack(spacing: .zero) {
                                    ForEach(Array(section.cells.enumerated()), id: \.element.id) { index, row in
                                        Button {
                                            presenter.handleSelection(row)
                                        } label: {
                                            PairedDomainRow(
                                                row: row,
                                                showSeparator: index < section.cells.count - 1
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .groupedSectionBackground(isElevated: true)
                            }
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(.backgroundsPrimaryElevated)
        .onAppear {
            presenter.viewWillAppear()
        }
        .alert(
            T.Browser.deletingExtensionPairingTitle,
            isPresented: $presenter.isDeleteAlertPresented,
            presenting: presenter.pendingDeletion
        ) { _ in
            Button(T.Commons.cancel, role: .cancel) {}
            Button(T.Commons.delete, role: .destructive) {
                presenter.handleConfirmDeletion()
            }
        } message: { row in
            Text(T.Browser.deletingExtensionPairingContent(row.authRequest.domain))
        }
    }
}

private struct PairedDomainRow: View {
    let row: ComposeServiceWebExtensionSection.Row
    let showSeparator: Bool

    var body: some View {
        VStack(spacing: .zero) {
            HStack(alignment: .top, spacing: .L) {
                Text(row.title)
                    .textStyle(.body)
                    .foregroundStyle(.labelsPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "trash")
                    .textStyle(.body)
                    .foregroundStyle(.accentsBrand)
                    .accessibilityLabel(T.Commons.delete)
                    .frame(alignment: .trailing)
            }
            .padding(.vertical, .L)

            if showSeparator {
                Divider()
                    .foregroundStyle(.separatorsNonOpaque)
            }
        }
        .contentShape(Rectangle())
    }
}
