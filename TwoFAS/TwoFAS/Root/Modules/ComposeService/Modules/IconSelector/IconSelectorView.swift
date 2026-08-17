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

struct IconSelectorView: View {
    @ObservedObject
    var presenter: IconSelectorPresenter
    
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    
    @State
    private var didScrollToSelected = false
    
    private let columnsPerRow = 4
    private let maxWidth: CGFloat = 400
    
    var body: some View {
        Group {
            if presenter.sections.isEmpty {
                emptyView
            } else {
                content
            }
        }
        .background(AppColor.backgroundsPrimaryElevated)
        .navigationTitle(T.Tokens.changeBrandIcon)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $presenter.searchPhrase, prompt: Text(T.Commons.search))
        .onChange(of: presenter.searchPhrase) { _, newValue in
            presenter.handleSearchChange(newValue)
        }
        .onAppear {
            presenter.viewDidAppear()
        }
    }
    
    @ViewBuilder
    private var emptyView: some View {
        TFEmptyScreen(
            icon: .systemImage("magnifyingglass"),
            title: T.Commons.noResults
        )
    }
    
    @ViewBuilder
    private var content: some View {
        ScrollViewReader { proxy in
            List {
                if !presenter.isSearching {
                    orderIconSection
                }
                ForEach(Array(presenter.sections.enumerated()), id: \.offset) { index, section in
                    sectionView(index: index, section: section)
                        .padding(.trailing, .XL)
                }
            }
            .listStyle(.plain)
            .padding(.leading, .XL)
            .tint(AppColor.accentsBrand.color(for: colorScheme))
            .onAppear {
                scrollToSelectedIcon(using: proxy)
            }
        }
    }
    
    private func scrollToSelectedIcon(using proxy: ScrollViewProxy) {
        guard !didScrollToSelected,
              let selectedID = presenter.selectedIconTypeID,
              let targetRowID = rowID(containing: selectedID) else { return }
        didScrollToSelected = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut) {
                proxy.scrollTo(targetRowID, anchor: .center)
            }
        }
    }
    
    private func rowID(containing iconTypeID: IconTypeID) -> IconTypeID? {
        for section in presenter.sections {
            let rows = section.cells.chunked(into: columnsPerRow)
            for row in rows where row.contains(where: { $0.iconTypeID == iconTypeID }) {
                return row.first?.iconTypeID
            }
        }
        return nil
    }
    
    @ViewBuilder
    private var orderIconSection: some View {
        let sectionContent = Section {
            IconSelectorOrderCell(
                maxWidth: maxWidth,
                onUserIcon: { presenter.handleOrderIconUser() },
                onCompanyIcon: { presenter.handleOrderIconCompany() }
            )
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        } header: {
            IconSelectorSectionHeader(title: "#")
                .listRowInsets(EdgeInsets())
        }
        if #available(iOS 26.0, *) {
            sectionContent.sectionIndexLabel(Text("#"))
        } else {
            sectionContent
        }
    }
    
    @ViewBuilder
    private func sectionView(index: Int, section: IconSelectorSection) -> some View {
        let columns = columnsPerRow
        let rows = section.cells.chunked(into: columns)
        let sectionContent = Section {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                rowView(row: row, columns: columns)
            }
        } header: {
            IconSelectorSectionHeader(title: section.title)
                .listRowInsets(EdgeInsets())
        }
        if #available(iOS 26.0, *) {
            sectionContent.sectionIndexLabel(Text(section.title.prefix(1)))
        } else {
            sectionContent
        }
    }
    
    @ViewBuilder
    private func rowView(row: [IconSelectorCell], columns: Int) -> some View {
        AdaptiveReadableContainer(iphoneMaxWidth: maxWidth, horizontalMargin: .zero, verticalMargin: .zero) {
            HStack(spacing: .zero) {
                HStack(spacing: .M) {
                    ForEach(row, id: \.iconTypeID) { cell in
                        IconSelectorCellView(
                            cell: cell,
                            isSelected: presenter.selectedIconTypeID == cell.iconTypeID
                        ) {
                            presenter.handleSelection(iconTypeID: cell.iconTypeID)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    ForEach(0..<max(0, columns - row.count), id: \.self) { _ in
                        Color.clear.frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .id(row.first?.iconTypeID)
    }
}

// MARK: - Cell

private struct IconSelectorCellView: View {
    let cell: IconSelectorCell
    let isSelected: Bool
    let onTap: () -> Void
    
    private let iconDimension: CGFloat = 42
    private let circleDimension: CGFloat = 65
    private let circleLineWidth: CGFloat = 2
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: .S) {
                ZStack {
                    Image(uiImage: cell.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconDimension, height: iconDimension)
                    
                    if isSelected {
                        Circle()
                            .inset(by: 1)
                            .stroke(AppColor.accentsBrand, lineWidth: circleLineWidth)
                            .frame(width: circleDimension, height: circleDimension)
                    }
                }
                .frame(width: circleDimension, height: circleDimension)
                
                if cell.showTitle {
                    Text(cell.title)
                        .minimumScaleFactor(0.75)
                        .allowsTightening(true)
                        .textStyle(.caption1, .emphasized)
                        .foregroundStyle(.labelsPrimary)
                        .lineLimit(1)
                        .frame(maxWidth: iconDimension)
                }
            }
            .contentShape(Rectangle())
            .accessibilityLabel(cell.title)
            .accessibilityAddTraits(.isButton)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section header

private struct IconSelectorSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .textStyle(.headline)
            .foregroundStyle(.labelsSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, .L)
    }
}

// MARK: - Order icon cell (# section)

private struct IconSelectorOrderCell: View {
    let maxWidth: CGFloat
    let onUserIcon: () -> Void
    let onCompanyIcon: () -> Void

    private let iconSize: CGFloat = 64
    
    var body: some View {
        HStack(spacing: .zero) {
            Spacer()
            
            VStack(spacing: .XXL) {
                HStack(spacing: .L) {
                    Image(systemName: "photo")
                        .textStyle(.title3)
                        .foregroundStyle(.accentsBrand)
                        .frame(height: iconSize)
                    
                    VStack(spacing: .S) {
                        Text(T.Tokens.orderIconDescription)
                            .textStyle(.body, .emphasized)
                            .foregroundStyle(.labelsPrimary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(T.Tokens.orderIconTitle)
                            .textStyle(.footnote)
                            .foregroundStyle(.labelsSecondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Menu {
                    Button(action: onUserIcon) {
                        Label(T.Tokens.orderMenuOptionUser, systemImage: "person")
                    }
                    Button(action: onCompanyIcon) {
                        Label(T.Tokens.orderMenuOptionCompany, systemImage: "briefcase")
                    }
                } label: {
                    TFButton(
                        T.Tokens.orderIconLink,
                        variant: .borderedSecondary,
                        size: .small
                    ) {}
                }
            }
            .padding(.XL)
            .frame(maxWidth: maxWidth, alignment: .center)
            .background(.backgroundsPrimary)
            .cornerRadius(TFCornerRadius.large.rawValue)
            .overlay(
                RoundedRectangle(cornerRadius: TFCornerRadius.large.rawValue)
                    .inset(by: 0.75)
                    .stroke(.bordersPrimary, lineWidth: 1.5)
            )
            .padding(.trailing, .XXL)
            
            Spacer()
        }
    }
}
