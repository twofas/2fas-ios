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

struct ComposeServiceCategorySelectionView: View {
    @ObservedObject
    var presenter: ComposeServiceCategorySelectionPresenter

    var body: some View {
        ScrollView {
            AdaptiveReadableContainer {
                VStack(spacing: .zero) {
                    ForEach(Array(presenter.rows.enumerated()), id: \.element.id) { index, row in
                        Button {
                            presenter.handleSelection(row)
                        } label: {
                            CategoryRow(
                                row: row,
                                showSeparator: index < presenter.rows.count - 1
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .groupedSectionBackground(isElevated: true)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .background(.backgroundsPrimaryElevated)
        .navigationTitle(T.Tokens.selectGroup)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.handleShowAddSection()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(T.Voiceover.addGroup)
            }
        }
        .onAppear {
            presenter.viewWillAppear()
        }
        .alert(
            T.Tokens.addGroup,
            isPresented: $presenter.isAddSectionAlertPresented
        ) {
            TextField(T.Tokens.groupName, text: $presenter.newSectionName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
            Button(T.Commons.cancel, role: .cancel) {}
            Button(T.Commons.add) {
                presenter.handleConfirmAddSection()
            }
            .disabled(!presenter.isNewSectionNameValid)
        } message: {
            Text(T.Tokens.groupName)
        }
    }
}

private struct CategoryRow: View {
    let row: ComposeServiceCategorySelectionRow
    let showSeparator: Bool

    var body: some View {
        VStack(spacing: .zero) {
            HStack(spacing: .L) {
                Text(row.title)
                    .textStyle(.body)
                    .foregroundStyle(.labelsPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if row.checkmark {
                    Image(systemName: "checkmark")
                        .textStyle(.body, .emphasized)
                        .foregroundStyle(.accentsBrand)
                        .accessibilityLabel(T.Voiceover.selected)
                        .frame(alignment: .trailing)
                }
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
