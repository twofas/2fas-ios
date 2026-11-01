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

struct AddingServiceAdvancedSettingsView: View {
    @ObservedObject
    var presenter: AddingServiceAdvancedSettingsPresenter

    var body: some View {
        ScrollView(.vertical) {
            AdaptiveReadableContainer {
                VStack(spacing: .XXXL) {
                    typeSelector()

                    VStack(spacing: .ML) {
                        if presenter.selectedTokenType != .steam {
                            advancedParametersBuilder()
                        }

                        AddServiceAdvancedWarningView()
                    }
                }
            }
        }
        .navigationTitle(T.Tokens.addManualOtherSettings)
        .navigationBarTitleDisplayMode(.inline)
        .background(.backgroundsPrimaryElevated)
    }

    @ViewBuilder
    private func separator() -> some View {
        Divider()
            .foregroundStyle(.separatorsNonOpaque)
    }

    @ViewBuilder
    private func typeSelector() -> some View {
        HStack(spacing: .XL) {
            TokenTypeOption(
                tokenType: .totp,
                name: T.Tokens.totp,
                selectedTokenType: $presenter.selectedTokenType
            )
            Spacer()
            TokenTypeOption(
                tokenType: .steam,
                name: T.Tokens.steam,
                selectedTokenType: $presenter.selectedTokenType
            )
            Spacer()
            TokenTypeOption(
                tokenType: .hotp,
                name: T.Tokens.hotp,
                selectedTokenType: $presenter.selectedTokenType
            )
        }
        .padding(.horizontal, .XXXXXL)
        .padding(.vertical, .XXL)
        .groupedSectionBackground(isElevated: true)
    }

    @ViewBuilder
    private func advancedParametersBuilder() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            switch presenter.selectedTokenType {
            case .totp:
                advancedMenu(
                    title: T.Tokens.algorithm,
                    selection: $presenter.selectedAlgorithm,
                    display: { $0.rawValue }
                )
                separator()
                advancedMenu(
                    title: T.Tokens.refreshTime,
                    selection: $presenter.selectedRefreshTime,
                    display: { T.Tokens.second($0.rawValue) }
                )
                separator()
                advancedMenu(
                    title: T.Tokens.numberOfDigits,
                    selection: $presenter.selectedDigits,
                    display: { "\($0.rawValue)" }
                )
            case .steam:
                EmptyView()
            case .hotp:
                initialCounterRow()
                separator()
                advancedMenu(
                    title: T.Tokens.numberOfDigits,
                    selection: $presenter.selectedDigits,
                    display: { "\($0.rawValue)" }
                )
            }
        }
        .groupedSectionBackground(isElevated: true)
    }

    @ViewBuilder
    private func advancedMenu<Value: Hashable & CaseIterable>(
        title: String,
        selection: Binding<Value>,
        display: @escaping (Value) -> String
    ) -> some View {
        TFListMenuRow(title: title, value: display(selection.wrappedValue)) {
            Picker(selection: selection) {
                ForEach(Array(Value.allCases), id: \.self) { value in
                    Text(display(value)).tag(value)
                }
            } label: {
                Text(title)
            }
        }
    }

    @ViewBuilder
    private func initialCounterRow() -> some View {
        Button {
            presenter.handleShowInitialCounterAlert()
        } label: {
            HStack(spacing: .ML) {
                Text(T.Tokens.initialCounter)
                    .textStyle(.body)
                    .foregroundStyle(.labelsPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(presenter.initialCounter)")
                    .textStyle(.body)
                    .foregroundStyle(.labelsSecondary)

                Image(icon: .pencil)
                    .textStyle(.body)
                    .foregroundStyle(.labelsSecondary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, .L)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .alert(T.Tokens.initialCounter, isPresented: $presenter.isInitialCounterAlertPresented) {
            TextField("", text: $presenter.initialCounterInput)
                .keyboardType(.numberPad)
            Button(T.Commons.cancel, role: .cancel) {}
            Button(T.Commons.save) {
                presenter.handleSaveInitialCounterFromAlert()
            }
            .disabled(Int(presenter.initialCounterInput).map { $0 < 0 } ?? true)
        }
    }
}

private struct TokenTypeOption: View {
    let tokenType: TokenType
    let name: String
    @Binding
    var selectedTokenType: TokenType

    private let circleSize: CGFloat = 22

    @GestureState
    private var isPressed = false

    var body: some View {
        Button(action: {
            selectedTokenType = tokenType
        }) {
            VStack(spacing: .ML) {
                Text(name)
                    .textStyle(.body)
                    .foregroundStyle(.labelsPrimary)

                if selectedTokenType == tokenType {
                    Image(icon: .checkmark)
                        .textStyle(.footnote, .emphasized)
                        .foregroundStyle(.graysWhite)
                        .frame(width: circleSize, height: circleSize, alignment: .center)
                        .background(.accentsBrand)
                        .cornerRadius(100)
                } else {
                    Circle()
                        .inset(by: 0.75)
                        .stroke(.graysGray3, lineWidth: 1.5)
                        .frame(width: circleSize, height: circleSize)
                }
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in state = true }
        )
        .sensoryFeedback(.selection, trigger: isPressed) { _, new in new }
    }
}

private struct AddServiceAdvancedWarningView: View {
    @Environment(\.colorScheme)
    private var colorScheme

    var body: some View {
        let attributedString: AttributedString = {
            var result = AttributedString(T.Tokens.addManualAdvancedDescription)
            result.foregroundColor = AppColor.labelsSecondary.color(for: colorScheme)

            if let range = result.range(of: T.Tokens.addManualAdvancedDescriptionHighlight) {
                result[range].foregroundColor = AppColor.labelsPrimary.color(for: colorScheme)
            }
            return result
        }()
        Text(attributedString)
            .textStyle(.footnote)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, .L)
    }
}
