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

struct SettingsMenuView: View {
    @Bindable
    var presenter: SettingsMenuPresenter

    var body: some View {
        VStack(spacing: .zero) {
            TFScreenTitleBar(
                title: T.Settings.settings,
                leadingSymbol: presenter.showsSidebarButton ? .sidebar : nil,
                onLeadingTap: presenter.showsSidebarButton ? presenter.handleSidebarTap : nil
            )

            TFListScreen {
                ForEach(presenter.sections) { section in
                    sectionView(section)
                }
            }
        }
        .background(.backgroundsPrimary)
        .onAppear {
            presenter.viewWillAppear()
        }
    }

    @ViewBuilder
    private func sectionView(_ section: SettingsMenuSection) -> some View {
        TFListSection(title: section.title, footer: section.footer) {
            ForEach(Array(section.cells.enumerated()), id: \.element.id) { index, cell in
                row(for: cell, isFirst: index == 0, isLast: index == section.cells.count - 1)
                if index < section.cells.count - 1 {
                    TFListSeparator(hasLeadingIcon: cell.icon != nil)
                }
            }
        }
    }

    @ViewBuilder
    private func row(for cell: SettingsMenuCell, isFirst: Bool, isLast: Bool) -> some View {
        if let action = cell.action {
            Button {
                presenter.handleSelection(action, rememberPosition: cell.rememberPosition)
            } label: {
                rowContent(cell, isFirst: isFirst, isLast: isLast)
            }
            .buttonStyle(.plain)
            .disabled(!cell.isEnabled)
        } else {
            rowContent(cell, isFirst: isFirst, isLast: isLast)
        }
    }

    @ViewBuilder
    private func rowContent(_ cell: SettingsMenuCell, isFirst: Bool, isLast: Bool) -> some View {
        HStack(spacing: .ML) {
            leadingIcon(for: cell.icon)

            Text(cell.title)
                .textStyle(.body)
                .foregroundStyle(titleColor(for: cell))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            accessoryView(for: cell)
        }
        .padding(.vertical, .L)
        .contentShape(Rectangle())
        .opacity(cell.isEnabled ? 1 : 0.6)
        .background(alignment: .center) {
            if isSelected(cell) {
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: isFirst ? TFCornerRadius.large.value : 0,
                        bottomLeading: isLast ? TFCornerRadius.large.value : 0,
                        bottomTrailing: isLast ? TFCornerRadius.large.value : 0,
                        topTrailing: isFirst ? TFCornerRadius.large.value : 0
                    ),
                    style: .continuous
                )
                .fill(AppColor.backgroundsSecondary)
                .padding(.horizontal, -Spacing.XL.value)
            }
        }
    }

    @ViewBuilder
    private func leadingIcon(for icon: SettingsMenuCell.Icon?) -> some View {
        switch icon {
        case .symbol(let name):
            GradientIconTile(systemName: name)
                .accessibilityHidden(true)
        case .brand(let image):
            BrandIconTile(image: image)
                .accessibilityHidden(true)
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private func accessoryView(for cell: SettingsMenuCell) -> some View {
        if let accessory = cell.accessory {
            switch accessory {
            case .arrow:
                HStack(spacing: .S) {
                    if let info = cell.info {
                        Text(info)
                            .textStyle(.body)
                            .foregroundStyle(.labelsSecondary)
                    }
                    Image(systemName: "chevron.right")
                        .textStyle(.subheadline, .emphasized)
                        .foregroundStyle(.labelsTertiary)
                        .accessibilityHidden(true)
                }
            case .toggle(let kind, let isOn):
                Toggle(
                    "",
                    isOn: Binding(
                        get: { isOn },
                        set: { _ in presenter.handleToggle(kind) }
                    )
                )
                .labelsHidden()
                .tint(.accentsBrand)
            case .external:
                Image(systemName: "arrow.up.right")
                    .textStyle(.subheadline, .emphasized)
                    .foregroundStyle(.accentsBrand)
                    .accessibilityHidden(true)
            case .warning:
                EmptyView()
            }
        } else if let info = cell.info {
            Text(info)
                .textStyle(.body)
                .foregroundStyle(.labelsSecondary)
        }
    }

    private func titleColor(for cell: SettingsMenuCell) -> AppColor {
        if case .warning = cell.accessory {
            return .accentsBrand
        }
        return .labelsPrimary
    }

    private func isSelected(_ cell: SettingsMenuCell) -> Bool {
        guard !presenter.isCollapsed,
              let module = cell.module,
              let selected = presenter.selectedModule
        else { return false }
        return module == selected && cell.rememberPosition
    }
}
