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

struct BackupAdvancedView: View {
    @Bindable
    var presenter: BackupAdvancedPresenter

    var body: some View {
        VStack(spacing: .zero) {
            TFScreenTitleBar(
                title: presenter.title,
                showsBackButton: presenter.showsBackButton,
                onBack: presenter.showsBackButton ? presenter.handleBack : nil
            ) {
                if presenter.isSyncing {
                    ProgressView()
                        .padding(.trailing, .S)
                }
            }

            TFListScreen {
                ForEach(presenter.sections) { section in
                    sectionView(section)
                }
            }
        }
        .background(.backgroundsPrimaryElevated)
        .onAppear {
            presenter.viewWillAppear()
        }
    }

    @ViewBuilder
    private func sectionView(_ section: BackupAdvancedSection) -> some View {
        TFListSection(title: section.title, footer: section.footer) {
            ForEach(Array(section.cells.enumerated()), id: \.element.id) { index, cell in
                row(for: cell)
                if index < section.cells.count - 1 {
                    TFListSeparator(hasLeadingIcon: true)
                }
            }
        }
    }

    @ViewBuilder
    private func row(for cell: BackupAdvancedCell) -> some View {
        Button {
            presenter.handleSelection(cell.action)
        } label: {
            HStack(spacing: .ML) {
                GradientIconTile(systemName: cell.iconSystemName)
                    .accessibilityHidden(true)

                Text(cell.title)
                    .textStyle(.body)
                    .foregroundStyle(.labelsPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, .L)
            .contentShape(Rectangle())
            .opacity(cell.isEnabled ? 1 : 0.4)
        }
        .buttonStyle(.plain)
        .disabled(!cell.isEnabled)
    }
}
