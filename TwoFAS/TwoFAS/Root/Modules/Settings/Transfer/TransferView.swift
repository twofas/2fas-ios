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

struct TransferView: View {
    @Bindable
    var presenter: TransferPresenter

    var body: some View {
        TFListScreen {
            ForEach(presenter.sections) { section in
                sectionView(section)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.backgroundsPrimary)
        .allowsHitTesting(!presenter.isLocked)
        .navigationTitle(T.Settings.transfer)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if presenter.isExporting {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                }
            }
        }
        .onAppear {
            presenter.viewWillAppear()
        }
    }

    @ViewBuilder
    private func sectionView(_ section: TransferSection) -> some View {
        TFListSection(title: section.title, footer: section.footer) {
            ForEach(Array(section.cells.enumerated()), id: \.element.id) { index, cell in
                row(for: cell)
                if index < section.cells.count - 1 {
                    TFListSeparator(hasLeadingIcon: true)
                }
            }
        }
    }

    @ViewBuilder
    private func row(for cell: TransferCell) -> some View {
        Button {
            presenter.handleSelection(cell.action)
        } label: {
            rowContent(cell)
        }
        .buttonStyle(.plain)
        .disabled(!cell.isActive)
    }

    @ViewBuilder
    private func rowContent(_ cell: TransferCell) -> some View {
        TFRowContent(title: cell.title, icon: { leadingIcon(for: cell.icon) }, accessory: { CheveronIcon() })
            .opacity(cell.isActive ? 1 : 0.4)
    }

    @ViewBuilder
    private func leadingIcon(for icon: TransferCell.Icon) -> some View {
        switch icon {
        case .brand(let image):
            BrandIconTile(image: image)
                .accessibilityHidden(true)
        case .symbol(let name):
            GradientIconTile(systemName: name)
                .accessibilityHidden(true)
        }
    }
}
