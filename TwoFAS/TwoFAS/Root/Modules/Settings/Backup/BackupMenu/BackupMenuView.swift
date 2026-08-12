//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
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

struct BackupMenuView: View {
    @Bindable
    var presenter: BackupMenuPresenter

    var body: some View {
        TFListScreen {
            ForEach(presenter.sections) { section in
                sectionView(section)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.backgroundsPrimary)
        .navigationTitle(T.Backup._2fasBackup)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.viewWillAppear()
        }
        .onDisappear {
            presenter.viewWillDisappear()
        }
    }

    @ViewBuilder
    private func sectionView(_ section: BackupMenuSection) -> some View {
        TFListSection(title: section.title, footer: section.footer) {
            ForEach(Array(section.cells.enumerated()), id: \.element.id) { index, cell in
                row(for: cell)
                if index < section.cells.count - 1 {
                    TFListSeparator()
                }
            }
        }
    }

    @ViewBuilder
    private func row(for cell: BackupMenuCell) -> some View {
        if let action = cell.action {
            Button {
                presenter.handleSelection(action)
            } label: {
                rowContent(cell)
            }
            .buttonStyle(.plain)
            .disabled(!cell.isEnabled)
        } else {
            rowContent(cell)
        }
    }

    @ViewBuilder
    private func rowContent(_ cell: BackupMenuCell) -> some View {
        TFRowContent(title: cell.title, isActive: isActive(for: cell)) {
            accessoryView(for: cell)
        }
        .opacity(cell.isEnabled ? 1 : 0.4)
    }

    @ViewBuilder
    private func accessoryView(for cell: BackupMenuCell) -> some View {
        if let toggle = cell.accessory {
            Toggle(
                "",
                isOn: Binding(
                    get: { toggle.isOn },
                    set: { _ in presenter.handleToggle(toggle.kind) }
                )
            )
            .labelsHidden()
            .tint(.accentsBrand)
            .disabled(!toggle.isActive)
        }
    }

    private func isActive(for cell: BackupMenuCell) -> Bool {
        if cell.action != nil, cell.accessory == nil {
            return true
        }
        return false
    }
}
