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

struct IconEditorView: View {
    @ObservedObject
    var presenter: IconEditorPresenter

    @FocusState
    private var isLabelTitleFocused: Bool?

    private var isIconMode: Bool {
        presenter.iconType == .brand
    }

    var body: some View {
        VStack(spacing: .zero) {
            header()

            ZStack {
                iconContent()
                    .opacity(isIconMode ? 1 : 0)
                    .allowsHitTesting(isIconMode)
                    .accessibilityHidden(!isIconMode)

                if !isIconMode {
                    labelContent()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.backgroundsPrimaryElevated)
        .navigationTitle(T.Tokens.editIcon)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                TFSaveButton(T.Commons.save, isEnabled: presenter.isSaveEnabled) {
                    presenter.handleSave()
                }
            }
        }
        .onChange(of: presenter.iconType) { _, _ in
            dismissKeyboard()
        }
        .onChange(of: presenter.labelTitle) { _, newValue in
            let sanitized = presenter.sanitizeLabelTitle(newValue)
            if sanitized != newValue {
                presenter.labelTitle = sanitized
            }
        }
    }

    @ViewBuilder
    private func header() -> some View {
        AdaptiveReadableContainer(verticalMargin: .zero) {
            VStack(spacing: .zero) {
                ServiceIconPreview(icon: presenter.previewIcon)
                    .padding(.top, .XXXXXL)
                    .padding(.bottom, .XXL)

                TFSegmentedControl(
                    selection: $presenter.iconType,
                    segments: [
                        .init(value: .brand, title: T.Tokens.iconEditorIcon),
                        .init(value: .label, title: T.Tokens.label)
                    ]
                )

                if isIconMode {
                    TFSearchField(text: $presenter.searchPhrase, prompt: T.Tokens.iconEditorSearch)
                        .padding(.horizontal, .L)
                        .padding(.top, .XXXXL)
                }
            }
            .padding(.bottom, .XL)
        }
    }

    @ViewBuilder
    private func iconContent() -> some View {
        if presenter.sections.isEmpty {
            TFEmptyScreen(
                icon: .systemImage(.magnifyingglass, bounces: true),
                title: T.Commons.noResults
            )
        } else {
            IconSelectorList(
                sections: presenter.sections,
                selectedIconTypeID: presenter.selectedIconTypeID,
                showsOrderIcon: !presenter.isSearching,
                onSelect: { presenter.handleSelection(iconTypeID: $0) },
                onUserIcon: { presenter.handleOrderIconUser() },
                onCompanyIcon: { presenter.handleOrderIconCompany() }
            )
            .scrollDismissesKeyboard(.immediately)
        }
    }

    @ViewBuilder
    private func labelContent() -> some View {
        ScrollView {
            AdaptiveReadableContainer {
                VStack(alignment: .leading, spacing: .zero) {
                    TFInlineTextField(
                        label: T.Tokens.label,
                        placeholder: T.Tokens.iconEditorLabelPlaceholder,
                        text: $presenter.labelTitle,
                        inputType: .other,
                        keyboardType: .default,
                        autocapitalization: .characters,
                        focused: $isLabelTitleFocused,
                        focusValue: true,
                        submit: .init(buttonType: .done, action: {
                            isLabelTitleFocused = nil
                        })
                    )

                    Divider()
                        .foregroundStyle(.separatorsNonOpaque)
                        .padding(.trailing, -Spacing.XL.value)

                    TFColorPickerMenu(
                        title: T.Tokens.pickBackgroundColor,
                        selectedColor: $presenter.labelColor
                    )
                }
                .groupedSectionBackground(isElevated: true)
                .tfInlineLabelAlignment()
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
