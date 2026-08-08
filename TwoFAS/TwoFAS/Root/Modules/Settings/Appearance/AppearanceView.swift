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

struct AppearanceView: View {
    @Bindable
    var presenter: AppearancePresenter

    var body: some View {
        TFListScreen {
            ForEach(presenter.sections) { section in
                sectionView(section)
            }
        }
        .background(.backgroundsPrimary)
        .navigationTitle(T.Settings.appearance)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.viewWillAppear()
        }
    }

    @ViewBuilder
    private func sectionView(_ section: AppearanceSection) -> some View {
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
    private func row(for cell: AppearanceCell) -> some View {
        switch cell.accessory {
        case .picker(let value, let options):
            TFListMenuRow(title: cell.title, value: value) {
                Picker(selection: pickerSelectionBinding(from: options)) {
                    ForEach(options) { option in
                        Text(option.title).tag(option.kind)
                    }
                } label: {
                    Text(cell.title)
                }
            }
        case .toggle:
            rowContent(cell)
        }
    }

    @ViewBuilder
    private func rowContent(_ cell: AppearanceCell) -> some View {
        HStack(spacing: .ML) {
            Text(cell.title)
                .textStyle(.body)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            accessoryView(for: cell)
        }
        .padding(.vertical, .L)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func accessoryView(for cell: AppearanceCell) -> some View {
        switch cell.accessory {
        case .toggle(let isOn):
            Toggle(
                "",
                isOn: Binding(
                    get: { isOn },
                    set: { _ in presenter.handleToggle(for: cell.kind) }
                )
            )
            .labelsHidden()
            .tint(.accentsBrand)
        case .picker:
            EmptyView()
        }
    }

    private func pickerSelectionBinding(
        from options: [AppearanceCell.PickerOption]
    ) -> Binding<AppearanceCell.Kind> {
        Binding(
            get: {
                options.first(where: { $0.isSelected })?.kind ?? options.first!.kind
            },
            set: { newKind in
                presenter.handleRowSelection(for: newKind)
            }
        )
    }
}
