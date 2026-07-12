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

struct AppSecurityView: View {
    @Bindable
    var presenter: AppSecurityPresenter

    var body: some View {
        VStack(spacing: .zero) {
            TFScreenTitleBar(
                title: T.Settings.appSecurity,
                showsBackButton: presenter.showsBackButton,
                onBack: presenter.showsBackButton ? presenter.handleBack : nil
            )

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
    private func sectionView(_ section: AppSecurityMenuSection) -> some View {
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
    private func row(for cell: AppSecurityMenuCell) -> some View {
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
        default:
            if let action = cell.action {
                Button {
                    presenter.handleSelection(action)
                } label: {
                    rowContent(cell)
                }
                .buttonStyle(.plain)
            } else {
                rowContent(cell)
            }
        }
    }

    @ViewBuilder
    private func rowContent(_ cell: AppSecurityMenuCell) -> some View {
        HStack(spacing: .ML) {
            Text(cell.title)
                .textStyle(.body)
                .foregroundStyle(titleColor(for: cell))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            accessoryView(for: cell)
        }
        .padding(.vertical, .L)
        .contentShape(Rectangle())
        .opacity(isDisabled(cell) ? 0.4 : 1)
    }

    @ViewBuilder
    private func accessoryView(for cell: AppSecurityMenuCell) -> some View {
        switch cell.accessory {
        case .none:
            EmptyView()
        case .toggle(let toggle):
            Toggle(
                "",
                isOn: Binding(
                    get: { toggle.isOn },
                    set: { _ in presenter.handleToggle(toggle.kind) }
                )
            )
            .labelsHidden()
            .tint(.accentsBrand)
            .disabled(toggle.isBlocked)
        case .picker:
            EmptyView()
        }
    }

    private func titleColor(for cell: AppSecurityMenuCell) -> AppColor {
        if case .changePIN = cell.action {
            return .accentsBrand
        }
        return .labelsPrimary
    }

    private func isDisabled(_ cell: AppSecurityMenuCell) -> Bool {
        if case .toggle(let toggle) = cell.accessory, toggle.isBlocked {
            return true
        }
        return false
    }

    private func pickerSelectionBinding(
        from options: [AppSecurityMenuCell.PickerOption]
    ) -> Binding<AppSecurityMenuCell.PickerKind> {
        Binding(
            get: {
                options.first(where: { $0.isSelected })?.kind ?? options.first!.kind
            },
            set: { newKind in
                presenter.handlePickerSelection(newKind)
            }
        )
    }
}
