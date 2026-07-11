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
            titleBar()

            ScrollView(.vertical) {
                VStack(spacing: .XXXL) {
                    ForEach(presenter.sections) { section in
                        sectionView(section)
                    }
                }
                .padding(.horizontal, .XL)
                .padding(.top, .M)
                .padding(.bottom, .XXXL)
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
                if presenter.isSyncing {
                    ProgressView()
                        .padding(.trailing, .S)
                }
            }
            TFTitleView(title: presenter.title)
        }
        .padding(.horizontal, .XXXL)
        .padding(.top, .XL)
        .frame(alignment: .top)
    }

    @ViewBuilder
    private func sectionView(_ section: BackupAdvancedSection) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            if let title = section.title {
                sectionHeader(title)
            }

            VStack(alignment: .leading, spacing: .zero) {
                ForEach(Array(section.cells.enumerated()), id: \.element.id) { index, cell in
                    row(for: cell)
                    if index < section.cells.count - 1 {
                        separator()
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
    private func row(for cell: BackupAdvancedCell) -> some View {
        Button {
            presenter.handleSelection(cell.action)
        } label: {
            rowContent(cell)
        }
        .buttonStyle(.plain)
        .disabled(!cell.isEnabled)
    }

    @ViewBuilder
    private func rowContent(_ cell: BackupAdvancedCell) -> some View {
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

    @ViewBuilder
    private func separator() -> some View {
        Divider()
            .foregroundStyle(.separatorsNonOpaque)
            .padding(.leading, Self.iconLeadingInset)
    }

    private static let iconLeadingInset: CGFloat = 28 + Spacing.ML.value

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
}
