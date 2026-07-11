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

struct AboutView: View {
    @Bindable
    var presenter: AboutPresenter
    
    private static let iconLeadingInset: CGFloat = 28 + Spacing.ML.value

    var body: some View {
        VStack(spacing: .zero) {
            titleBar()

            ScrollView(.vertical) {
                VStack(spacing: .XXXL) {
                    ForEach(presenter.sections) { section in
                        sectionView(section)
                    }

                    versionFooter()
                }
                .padding(.horizontal, .XL)
                .padding(.top, .M)
            }
        }
        .background(.backgroundsPrimaryElevated)
        .onAppear {
            presenter.viewWillAppear()
        }
    }

    @ViewBuilder
    private func titleBar() -> some View {
        ZStack {
            HStack(spacing: .zero) {
                if presenter.showsBackButton {
                    TFLiquidGlassSymbolButton(symbol: .back) {
                        presenter.handleBack()
                    }
                }
                Spacer()
            }
            TFTitleView(title: T.Settings.about)
        }
        .padding(.horizontal, .XXXL)
        .padding(.top, .XL)
        .frame(alignment: .top)
    }

    @ViewBuilder
    private func sectionView(_ section: AboutSection) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            if let title = section.title {
                sectionHeader(title)
            }

            VStack(alignment: .leading, spacing: .zero) {
                ForEach(Array(section.cells.enumerated()), id: \.element.id) { index, cell in
                    row(for: cell)
                    if index < section.cells.count - 1 {
                        separator(insetForIcon: cell.icon != nil)
                    }
                }
            }
            .groupedSectionBackground()

            if let footer = section.footer {
                sectionFooter(footer)
            }
        }
    }

    @ViewBuilder
    private func row(for cell: AboutCell) -> some View {
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

    @ViewBuilder
    private func rowContent(_ cell: AboutCell) -> some View {
        HStack(spacing: .ML) {
            if let icon = cell.icon {
                BrandIconTile(image: icon)
                    .accessibilityHidden(true)
            }

            Text(cell.title)
                .textStyle(.body)
                .foregroundStyle(titleColor(for: cell))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            accessoryView(cell.accessory)
        }
        .padding(.vertical, .L)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func accessoryView(_ accessory: AboutCell.Accessory) -> some View {
        switch accessory {
        case .external:
            Image(systemName: "arrow.up.right")
                .textStyle(.subheadline, .emphasized)
                .foregroundStyle(.accentsBrand)
                .accessibilityHidden(true)
        case .share:
            Image(systemName: "square.and.arrow.up")
                .textStyle(.subheadline, .emphasized)
                .foregroundStyle(.accentsBrand)
                .accessibilityHidden(true)
        case .noAccessory:
            EmptyView()
        case .toggle(let isOn):
            Toggle(
                "",
                isOn: Binding(
                    get: { isOn },
                    set: { _ in presenter.handleToggle() }
                )
            )
            .labelsHidden()
            .tint(.accentsBrand)
        }
    }

    @ViewBuilder
    private func separator(insetForIcon: Bool) -> some View {
        Divider()
            .foregroundStyle(.separatorsNonOpaque)
            .padding(.leading, insetForIcon ? Self.iconLeadingInset : 0)
    }

    @ViewBuilder
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .textStyle(.headline)
            .foregroundStyle(.labelsSecondary)
            .accessibilityAddTraits(.isHeader)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, .ML)
            .padding(.horizontal, .XL)
    }

    @ViewBuilder
    private func sectionFooter(_ text: String) -> some View {
        Text(text)
            .textStyle(.footnote, .regular, .tight)
            .foregroundStyle(.labelsSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, .M)
            .padding(.horizontal, .XL)
    }

    @ViewBuilder
    private func versionFooter() -> some View {
        VStack(spacing: .L) {
            Image(uiImage: Asset.aboutLogo.image)
                .accessibilityHidden(true)
            Text(T.Settings.version(presenter.appVersion))
                .textStyle(.footnote, .regular, .tight)
                .foregroundStyle(.labelsSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
        .padding(.bottom, 40)
    }

    private func titleColor(for cell: AboutCell) -> AppColor {
        if case .noAccessory = cell.accessory, cell.action != nil {
            return .accentsBrand
        }
        return .labelsPrimary
    }
}
