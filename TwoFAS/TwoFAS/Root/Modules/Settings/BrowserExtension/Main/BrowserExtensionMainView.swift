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

struct BrowserExtensionMainView: View {
    @Bindable
    var presenter: BrowserExtensionMainPresenter

    var body: some View {
        VStack(spacing: .zero) {
            TFScreenTitleBar(
                title: T.Browser.browserExtension,
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
        .overlay {
            if presenter.isLoading {
                ZStack {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                        .tint(.accentsBrand)
                }
                .allowsHitTesting(true)
            }
        }
        .onAppear {
            presenter.viewWillAppear()
        }
        .getName(
            $presenter.showRenameNickname,
            title: T.Browser.deviceName,
            message: T.Browser.thisDeviceFooter,
            placeholder: presenter.currentNickname,
            defaultText: presenter.currentNickname,
            confirmTitle: T.Commons.save
        ) { newName in
            presenter.handleNameChange(newName)
        } onVerify: { value in
            presenter.isNicknameValid(value)
        }
    }

    @ViewBuilder
    private func sectionView(_ section: BrowserExtensionMainSection) -> some View {
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
    private func row(for cell: BrowserExtensionMainCell) -> some View {
        Button {
            presenter.handleTap(cell)
        } label: {
            rowContent(cell)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func rowContent(_ cell: BrowserExtensionMainCell) -> some View {
        switch cell.kind {
        case .service(let name, let date, _):
            serviceRow(name: name, date: date)
        case .addNew:
            simpleRow(title: T.Browser.addNew, titleColor: .accentsBrand, showChevron: false)
        case .nickname(let nick):
            simpleRow(title: nick, titleColor: .labelsPrimary, showChevron: true)
        }
    }

    private func serviceRow(name: String, date: String) -> some View {
        HStack(spacing: .ML) {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .textStyle(.body)
                    .foregroundStyle(.labelsPrimary)
                    .multilineTextAlignment(.leading)
                Text(date)
                    .textStyle(.caption1)
                    .foregroundStyle(.labelsSecondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .textStyle(.footnote)
                .foregroundStyle(.labelsTertiary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, .L)
        .contentShape(Rectangle())
    }

    private func simpleRow(title: String, titleColor: AppColor, showChevron: Bool) -> some View {
        HStack(spacing: .ML) {
            Text(title)
                .textStyle(.body)
                .foregroundStyle(titleColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            if showChevron {
                Image(systemName: "chevron.right")
                    .textStyle(.footnote)
                    .foregroundStyle(.labelsTertiary)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, .L)
        .contentShape(Rectangle())
    }
}
