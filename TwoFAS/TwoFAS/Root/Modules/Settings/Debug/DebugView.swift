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

#if DEV
import SwiftUI
import UIKit
import Common

struct DebugView: View {
    @Bindable
    var presenter: DebugPresenter

    var body: some View {
        content
            .background(AppColor.backgroundsPrimary)
            .onAppear { presenter.viewWillAppear() }
            .modifier(ActionAlertModifier(presenter: presenter))
            .modifier(GenerateAlertModifier(presenter: presenter))
            .overlay { runningOverlay }
    }

    @ViewBuilder
    private var content: some View {
        TFListScreen {
            stateSections
            actionsSection
            generatorSection
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.backgroundsPrimary)
        .navigationTitle("Debug")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var runningOverlay: some View {
        if presenter.isRunning {
            ZStack {
                Rectangle()
                    .fill(AppColor.overlaysDefault)
                    .ignoresSafeArea()
                TFLoadingView(title: presenter.runningMessage)
                    .background(AppColor.backgroundsPrimary)
            }
            .transition(.opacity)
        }
    }

    // MARK: - State

    @ViewBuilder
    private var stateSections: some View {
        ForEach(presenter.stateSections) { section in
            TFListSection(title: section.title) {
                ForEach(Array(section.rows.enumerated()), id: \.element.id) { index, row in
                    stateRow(row)
                    if index < section.rows.count - 1 {
                        TFListSeparator()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func stateRow(_ row: DebugStateRow) -> some View {
        Button {
            copyValue(row.value)
        } label: {
            HStack(alignment: .top, spacing: .ML) {
                Text(row.name)
                    .textStyle(.body)
                    .foregroundStyle(AppColor.labelsPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(row.value)
                    .textStyle(.body)
                    .foregroundStyle(AppColor.labelsSecondary)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, .L)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(minHeight: .normal)
    }

    private func copyValue(_ value: String) {
        UIPasteboard.general.string = value
        ToastPresenter.shared.presentCopied()
    }

    // MARK: - Actions

    private var allActions: [DebugAction] {
        [.trashAllServices, .restoreAllServices, .emptyTrash, .reloadPushToken,
         .unpairAllBrowsers, .wipeDatabase, .resetApp, .wipeAndReset]
    }

    @ViewBuilder
    private var actionsSection: some View {
        TFListSection(title: "Actions") {
            ForEach(Array(allActions.enumerated()), id: \.element) { index, action in
                actionRow(action)
                if index < allActions.count - 1 {
                    TFListSeparator()
                }
            }
        }
    }

    @ViewBuilder
    private func actionRow(_ action: DebugAction) -> some View {
        Button {
            presenter.requestAction(action)
        } label: {
            HStack(spacing: .ML) {
                Text(action.displayTitle)
                    .textStyle(.body)
                    .foregroundStyle(action.isDestructive ? AppColor.accentsBrand : AppColor.labelsPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, .L)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(minHeight: .normal)
    }

    // MARK: - Generator

    @ViewBuilder
    private var generatorSection: some View {
        TFListSection(
            title: "Generate random services",
            footer: "Cloud is disabled before generation."
        ) {
            distributeToggleRow
            TFListSeparator()
            countButtonsGrid
        }
    }

    @ViewBuilder
    private var distributeToggleRow: some View {
        HStack(spacing: .ML) {
            Text("Random categories")
                .textStyle(.body)
                .foregroundStyle(AppColor.labelsPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: $presenter.distributeIntoCategories)
                .labelsHidden()
                .tint(AppColor.accentsBrand)
        }
        .padding(.vertical, .L)
    }

    @ViewBuilder
    private var countButtonsGrid: some View {
        let counts = DebugGenerateCount.allCases
        let columns = [
            GridItem(.flexible(), spacing: Spacing.M.value),
            GridItem(.flexible(), spacing: Spacing.M.value),
            GridItem(.flexible(), spacing: Spacing.M.value),
            GridItem(.flexible(), spacing: Spacing.M.value)
        ]

        LazyVGrid(columns: columns, spacing: Spacing.M.value) {
            ForEach(counts) { count in
                TFButton(
                    count.label,
                    variant: .bordered,
                    size: .small,
                    useWideLayout: true
                ) {
                    presenter.requestGeneration(count)
                }
            }
        }
        .padding(.vertical, .L)
    }

    fileprivate func generateAlertMessage(count: Int) -> String {
        let base = "Cloud sync will be disabled, then \(count) random services will be added."
        if presenter.distributeIntoCategories {
            return base + " Random categories will be created and services distributed."
        }
        return base
    }
}

private struct ActionAlertModifier: ViewModifier {
    let presenter: DebugPresenter

    func body(content: Content) -> some View {
        content.alert(
            presenter.pendingAction?.displayTitle ?? "",
            isPresented: Binding(
                get: { presenter.pendingAction != nil },
                set: { newValue in if !newValue { presenter.cancelAction() } }
            ),
            presenting: presenter.pendingAction
        ) { action in
            Button("Cancel", role: .cancel) { presenter.cancelAction() }
            Button(
                "Confirm",
                role: action.isDestructive ? .destructive : nil
            ) {
                presenter.confirmAction()
            }
        } message: { action in
            Text(action.confirmationMessage)
        }
    }
}

private struct GenerateAlertModifier: ViewModifier {
    let presenter: DebugPresenter

    func body(content: Content) -> some View {
        content.alert(
            "Generate services",
            isPresented: Binding(
                get: { presenter.pendingGenerationCount != nil },
                set: { newValue in if !newValue { presenter.cancelGeneration() } }
            ),
            presenting: presenter.pendingGenerationCount
        ) { _ in
            Button("Cancel", role: .cancel) { presenter.cancelGeneration() }
            Button("Generate") { presenter.confirmGeneration() }
        } message: { count in
            Text(message(for: count))
        }
    }

    private func message(for count: Int) -> String {
        let base = "Cloud sync will be disabled, then \(count) random services will be added."
        if presenter.distributeIntoCategories {
            return base + " Random categories will be created and services distributed."
        }
        return base
    }
}
#endif
