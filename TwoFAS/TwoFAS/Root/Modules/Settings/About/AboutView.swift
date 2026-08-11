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

    var body: some View {
        TFListScreen {
            ForEach(presenter.sections) { section in
                sectionView(section)
            }

            versionFooter()
        }
        .background(.backgroundsPrimary)
        .navigationTitle(T.Settings.about)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.viewWillAppear()
        }
        .alert(T.About.generateLogsAlertTitle, isPresented: $presenter.isGenerateLogsAlertPresented) {
            Button(T.Commons.cancel, role: .cancel) {}
            Button(T.About.generateLogsAlertAction) {
                presenter.handleGenerateLogsConfirmed()
            }
        } message: {
            Text(T.About.generateLogsAlertMessage)
        }
        .overlay {
            if presenter.isGeneratingLogs {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    TFLoadingView(title: T.About.generateLogs)
                        .background(.backgroundsPrimary)
                }
                .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private func sectionView(_ section: AboutSection) -> some View {
        TFListSection(title: section.title, footer: section.footer) {
            ForEach(Array(section.cells.enumerated()), id: \.element.id) { index, cell in
                row(for: cell)
                if index < section.cells.count - 1 {
                    TFListSeparator(hasLeadingIcon: cell.icon != nil)
                }
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
        TFRowContent(title: cell.title, isActive: isActive(for: cell)) {
            if let icon = cell.icon {
                BrandIconTile(image: icon)
                    .accessibilityHidden(true)
            }
        } accessory: {
            accessoryView(cell.accessory)
        }
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

    private func isActive(for cell: AboutCell) -> Bool {
        if case .noAccessory = cell.accessory, cell.action != nil {
            return true
        }
        return false
    }
}
