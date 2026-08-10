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

struct LabelComposeView: View {
    @ObservedObject
    var presenter: LabelComposePresenter

    @FocusState
    private var isTitleFocused: Bool?

    var body: some View {
        ScrollView {
            AdaptiveReadableContainer {
                VStack(spacing: .XXXXL) {
                    ServiceIconView(
                        icon: .label(title: presenter.title, TintColor: presenter.color)
                    )
                    .shadow(.glass)

                    VStack(alignment: .leading, spacing: .zero) {
                        TFFloatingTextField(
                            placeHolder: T.Tokens.labelCharactersTitle,
                            text: $presenter.title,
                            inputType: .other,
                            keyboardType: .default,
                            autocapitalization: .characters,
                            focused: $isTitleFocused,
                            focusValue: true
                        )

                        Divider()
                            .foregroundStyle(.separatorsNonOpaque)

                        TFColorPickerMenu(
                            title: T.Tokens.pickBackgroundColor,
                            selectedColor: $presenter.color
                        )
                    }
                    .groupedSectionBackground(isElevated: true)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .background(.backgroundsPrimaryElevated)
        .navigationTitle(T.Tokens.changeLabel)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(T.Commons.save) {
                    presenter.handleSave()
                }
                .disabled(!presenter.isSaveEnabled)
            }
        }
        .onChange(of: presenter.title) { _, newValue in
            let sanitized = presenter.sanitize(newValue)
            if sanitized != newValue {
                presenter.title = sanitized
            }
        }
        .onAppear {
            if !UIAccessibility.isVoiceOverRunning {
                DispatchQueue.main.async {
                    isTitleFocused = true
                }
            }
        }
    }
}
