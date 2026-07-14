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

struct ComposeServiceAdvancedSummaryView: View {
    @ObservedObject
    var presenter: ComposeServiceAdvancedSummaryPresenter

    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            ZStack {
                HStack(spacing: .zero) {
                    TFLiquidGlassSymbolButton(symbol: .back) {
                        presenter.handleBack()
                    }
                    Spacer()
                }
                TFTitleView(title: T.Tokens.advanced)
            }
            .padding(.horizontal, .XL)
            .padding(.top, .XL)

            ScrollView(.vertical) {
                AdaptiveReadableContainer(horizontalMargin: Spacing.XL.rawValue) {
                    VStack(alignment: .leading, spacing: .zero) {
                        if !presenter.menu.title.isEmpty {
                            sectionHeader(presenter.menu.title)
                        }

                        VStack(alignment: .leading, spacing: .zero) {
                            ForEach(Array(presenter.menu.cells.enumerated()), id: \.offset) { index, cell in
                                row(for: cell)
                                if index < presenter.menu.cells.count - 1 {
                                    Divider()
                                        .foregroundStyle(.separatorsNonOpaque)
                                }
                            }
                        }
                        .groupedSectionBackground()
                    }
                    .padding(.top, .XXXXL)
                }
            }
        }
        .background(.backgroundsPrimaryElevated)
        .onAppear {
            presenter.viewWillAppear()
        }
    }

    @ViewBuilder
    private func row(for cell: ComposeServiceAdvancedSummaryMenuCell) -> some View {
        if cell.copyValue {
            Button {
                presenter.handleSelection(of: cell)
            } label: {
                rowContent(for: cell)
            }
        } else {
            rowContent(for: cell)
        }
    }

    @ViewBuilder
    private func rowContent(for cell: ComposeServiceAdvancedSummaryMenuCell) -> some View {
        HStack {
            Text(cell.title)
                .textStyle(.body)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let info = cell.info {
                Text(info)
                    .textStyle(.body)
                    .foregroundStyle(.labelsSecondary)
                    .frame(alignment: .trailing)
            }
        }
        .padding(.vertical, .XL)
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
}
