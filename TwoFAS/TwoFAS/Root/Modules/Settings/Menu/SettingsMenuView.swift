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
        TFListScreen {
            ForEach(presenter.sections) { section in
                sectionView(section)
            }
        }
        .background(.backgroundsPrimary)
        .navigationTitle(T.Settings.settings)
        .navigationBarTitleDisplayMode(titleDisplayMode)
        .onAppear {
            presenter.viewWillAppear()
        }
    }

    /// On iOS 26+ the compact (collapsed, single-column) layout uses a large
    /// title to match the rest of the app; the expanded two-column layout and
    /// earlier systems keep the inline title.
    private var titleDisplayMode: NavigationBarItem.TitleDisplayMode {
        if #available(iOS 26.0, *), presenter.isCollapsed {
            return .large
        }
        return .inline
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
        TFRowContent(title: cell.title, isActive: isActive(for: cell)) {
            leadingIcon(for: cell.icon)
        } accessory: {
            accessoryView(for: cell)
        }
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
                .fill(selectionHighlightColor)
                .padding(.horizontal, -Spacing.XL.value)
                .frame(minHeight: .normal)
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

    private func isActive(for cell: SettingsMenuCell) -> Bool {
        if case .warning = cell.accessory {
            return true
        }
        return false
    }

    private var selectionHighlightColor: AppColor {
        if #available(iOS 26.0, *) {
            return .backgroundsSecondary
        } else {
            return .fillsSecondary
        }
    }

    private func isSelected(_ cell: SettingsMenuCell) -> Bool {
        guard !presenter.isCollapsed,
              let module = cell.module,
              let selected = presenter.selectedModule
        else { return false }
        return module == selected && cell.rememberPosition
    }
}
