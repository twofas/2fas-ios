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

struct IconSelectorList: View {
    let sections: [IconSelectorSection]
    let selectedIconTypeID: IconTypeID?
    let showsOrderIcon: Bool
    let onSelect: (IconTypeID) -> Void
    let onUserIcon: () -> Void
    let onCompanyIcon: () -> Void

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    @State
    private var didScrollToSelected = false

    private let columnsPerRow = 4
    private let maxWidth: CGFloat = 400

    var body: some View {
        ScrollViewReader { proxy in
            List {
                if showsOrderIcon {
                    orderIconSection
                }
                ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
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
              let selectedIconTypeID,
              let targetRowID = rowID(containing: selectedIconTypeID) else { return }
        didScrollToSelected = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut) {
                proxy.scrollTo(targetRowID, anchor: .center)
            }
        }
    }

    private func rowID(containing iconTypeID: IconTypeID) -> IconTypeID? {
        for section in sections {
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
                onUserIcon: onUserIcon,
                onCompanyIcon: onCompanyIcon
            )
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
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
                            isSelected: selectedIconTypeID == cell.iconTypeID
                        ) {
                            onSelect(cell.iconTypeID)
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
            .textStyle(.body, .medium)
            .foregroundStyle(.labelsSecondary)
            .lineLimit(1)
            .allowsTightening(true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, .M)
            .background(.backgroundsPrimaryElevated)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Order icon cell (# section)

private struct IconSelectorOrderCell: View {
    let maxWidth: CGFloat
    let onUserIcon: () -> Void
    let onCompanyIcon: () -> Void

    @Environment(\.colorScheme)
    private var colorScheme

    private let orderButtonHeight: CGFloat = 36

    private var borderColor: AppColor {
        colorScheme == .dark ? .separatorsOpaque : .bordersPrimary
    }

    var body: some View {
        HStack(spacing: .zero) {
            Spacer(minLength: 0)

            VStack(spacing: .XXXL) {
                HStack(spacing: .L) {
                    Image(icon: .photo)
                        .textStyle(.title2)
                        .foregroundStyle(.accentsBlue)
                        .accessibilityHidden(true)

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
                .frame(maxWidth: .infinity, alignment: .leading)

                Menu {
                    Button(action: onUserIcon) {
                        Label(T.Tokens.orderMenuOptionUser, icon: .person)
                    }
                    Button(action: onCompanyIcon) {
                        Label(T.Tokens.orderMenuOptionCompany, icon: .briefcase)
                    }
                } label: {
                    Text(T.Tokens.orderIconLink)
                        .textStyle(.body, .medium)
                        .foregroundStyle(.labelsPrimary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, .M)
                        .padding(.horizontal, .L)
                        .frame(minHeight: orderButtonHeight)
                        .background {
                            Capsule()
                                .foregroundStyle(.fillsTertiary)
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.XL)
            .frame(maxWidth: maxWidth, alignment: .center)
            .background(.backgroundsPrimary)
            .cornerRadius(TFCornerRadius.large.rawValue)
            .overlay(
                RoundedRectangle(cornerRadius: TFCornerRadius.large.rawValue)
                    .inset(by: 0.75)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .padding(.trailing, .XL)

            Spacer(minLength: 0)
        }
    }
}
