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

struct ImporterEnterPasswordView: View {
    @Bindable
    var presenter: ImporterEnterPasswordPresenter

    @FocusState
    private var focusedField: Field?
    private enum Field: Int, Hashable {
        case password
    }

    var body: some View {
        VStack(spacing: .zero) {
            ScrollView(.vertical) {
                AdaptiveReadableContainer {
                    VStack(spacing: .XXXL) {
                        Text(T.Backup.enterPasswordTitle)
                            .textStyle(.callout)
                            .foregroundStyle(.labelsPrimary)

                        TFFloatingTextField(
                            placeHolder: T.Backup.password,
                            text: $presenter.password,
                            inputType: .password,
                            keyboardType: .asciiCapable,
                            focused: $focusedField,
                            focusValue: .password,
                            errorMessage: $presenter.errorMessage,
                            submit: .init(buttonType: .done, action: {
                                focusedField = nil
                                presenter.handlePreimport()
                            })
                        )
                        .groupedSectionBackground()
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)

            AdaptiveReadableContainer {
                VStack(spacing: .L) {
                    TFButton(
                        T.Commons.continue,
                        variant: .borderedProminent,
                        size: .large
                    ) {
                        focusedField = nil
                        presenter.handlePreimport()
                    }
                    .disabled(!presenter.isDecryptEnabled)

                    TFCancelButton(T.Commons.cancel) {
                        presenter.handleCancel()
                    }
                }
            }
        }
        .background(.backgroundsPrimary)
        .navigationTitle(T.Backup.encryptionEnterPassword)
        .navigationBarTitleDisplayMode(.inline)
        .closeToolbar {
            presenter.handleCancel()
        }
        .onChange(of: presenter.password) { _, newValue in
            presenter.handleChange(newValue)
        }
        .onAppear {
            DispatchQueue.main.async {
                focusedField = .password
            }
        }
        .dismissKeyboardOnTapOutside()
        .minimumBottomSpacing()
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
