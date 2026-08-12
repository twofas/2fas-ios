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

struct SelectServiceView: View {
    @ObservedObject
    var presenter: SelectServicePresenter

    var body: some View {
        NavigationStack {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        TFSymbolButton(symbol: .close) {
                            presenter.handleCancel()
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        TFTitleView(title: T.Browser.request)
                    }
                }
                .searchable(text: $presenter.searchPhrase, prompt: Text(T.Commons.search))
                .onChange(of: presenter.searchPhrase) { _, newValue in
                    presenter.handleSearchChange(newValue)
                }
                .onAppear {
                    presenter.viewWillAppear()
                }
                .toolbarBackground(AppColor.backgroundsPrimaryElevated, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
        .background(.backgroundsPrimaryElevated)
    }

    @ViewBuilder
    private var content: some View {
        if presenter.list.isEmpty && !presenter.searchPhrase.isEmpty {
            emptyView
                .background(.backgroundsPrimaryElevated)
        } else {
            listView
                .padding(.top, .XXL)
                .background(.backgroundsPrimaryElevated)
        }
    }

    @ViewBuilder
    private var listView: some View {
        ScrollView {
            AdaptiveReadableContainer {
                VStack(alignment: .leading, spacing: .XXXXXL) {
                    if presenter.showTableViewHeader {
                        SelectServiceListHeader(
                            extensionName: presenter.browserName,
                            domain: presenter.domain,
                            isOn: $presenter.saveSwitchValue
                        )
                    }
                    
                    ForEach(Array(presenter.list.enumerated()), id: \.offset) { _, section in
                        VStack(alignment: .leading, spacing: .zero) {
                            ListSectionHeaderView(title: titleString(for: section.title))
                            
                            VStack(spacing: .zero) {
                                ForEach(Array(section.cells.enumerated()), id: \.offset) { index, cell in
                                    Button {
                                        presenter.handleSelection(cell)
                                    } label: {
                                        SelectServiceRow(
                                            cell: cell,
                                            showSeparator: index < section.cells.count - 1
                                        )
                                        .frame(minHeight: .list)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .groupedSectionBackground(isElevated: true)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var emptyView: some View {
        TFEmptyScreen(
            systemImage: "magnifyingglass",
            title: T.Commons.noResults
        )
    }

    private func titleString(for type: SelectServiceSection.TitleType) -> String {
        switch type {
        case .noTitle: return T.Tokens.myTokens
        case .bestMatch: return T.Commons.bestMatch
        case .title(let title): return title
        }
    }
}

private struct SelectServiceRow: View {
    let cell: SelectServiceCell
    let showSeparator: Bool

    private let dimension: CGFloat = 45
    private let iconSize: CGFloat = 52

    var body: some View {
        VStack(spacing: .zero) {
            HStack(spacing: .L) {
                ServiceIconView(icon: cell.icon, showBackground: false)
                VStack(alignment: .leading, spacing: .SM) {
                    AddingServiceTitleView(text: cell.title)
                    if let subtitle = cell.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .textStyle(.footnote)
                            .foregroundStyle(.labelsSecondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
            }
            .padding(.vertical, .L)

            if showSeparator {
                Divider()
                    .foregroundStyle(.separatorsNonOpaque)
                    .padding(.leading, iconSize + Spacing.L.value)
            }
        }
        .contentShape(Rectangle())
    }
}

private struct SelectServiceListHeader: View {
    let extensionName: String
    let domain: String
    @Binding var isOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: .XL) {
            VStack(alignment: .center, spacing: .S) {
                Text(extensionName)
                    .textStyle(.title2, .emphasized)
                    .foregroundStyle(.labelsPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text(
                    String(
                    format: "requested a 2FA Token for %@. Select the service to authorize and save with this domain.",
                    domain
                    )
                )
                    .textStyle(.subheadline)
                    .foregroundStyle(.labelsSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            HStack {
                Text(T.Browser.saveChoice)
                    .textStyle(.body)
                    .foregroundStyle(.labelsPrimary)
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(.accentsBrand)
            }
            .padding(.vertical, .L)
            .groupedSectionBackground(isElevated: true)
        }
        .frame(minHeight: .normal)
    }
}
