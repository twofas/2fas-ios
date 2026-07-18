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

struct ExporterPasswordProtectionView: View {
    @Bindable
    var presenter: ExporterPasswordProtectionPresenter

    @FocusState
    private var focusedField: Field?
    private enum Field: Int, Hashable {
        case first
        case second
    }

    var body: some View {
        VStack(spacing: .zero) {
            TFScreenTitleBar(
                title: T.backupSettingsPasswordSetTitle,
                showsBackButton: presenter.showsBackButton,
                onBack: presenter.showsBackButton ? presenter.handleBack : nil
            )

            ScrollView(.vertical) {
                AdaptiveReadableContainer {
                    Text(T.Backup.setPasswordTitle)
                        .foregroundStyle(.labelsPrimary)
                        .textStyle(.callout)
                    
                    VStack(spacing: .XXXL) {
                        VStack(spacing: .zero) {
                            TFFloatingTextField(
                                placeHolder: T.Backup.password,
                                text: $presenter.password1,
                                inputType: .password,
                                keyboardType: .asciiCapable,
                                focused: $focusedField,
                                focusValue: .first,
                                errorMessage: $presenter.password1Error,
                                submit: .init(buttonType: .next, action: {
                                    focusedField = .second
                                })
                            )

                            Divider()
                                .foregroundStyle(.separatorsNonOpaque)

                            TFFloatingTextField(
                                placeHolder: T.Backup.repeatPassword,
                                text: $presenter.password2,
                                inputType: .password,
                                keyboardType: .asciiCapable,
                                focused: $focusedField,
                                focusValue: .second,
                                errorMessage: $presenter.password2Error,
                                submit: .init(buttonType: .done, action: {
                                    focusedField = nil
                                    presenter.handleExport()
                                })
                            )
                        }
                        .groupedSectionBackground()
                    }
                    .padding(.horizontal, .XL)
                }
            }
            .scrollDismissesKeyboard(.interactively)

            AdaptiveReadableContainer {
                VStack(spacing: .L) {
                    TFButton(
                        T.Backup.saveAndExport,
                        variant: .borderedProminent,
                        size: .large
                    ) {
                        focusedField = nil
                        presenter.handleExport()
                    }
                    .disabled(!presenter.isExportEnabled)

                    TFButton(T.Commons.cancel, variant: .borderless, size: .large) {
                        presenter.handleCancel()
                    }
                }
                .padding(.horizontal, .XL)
                .padding(.bottom, .XL)
            }
        }
        .background(.backgroundsPrimaryElevated)
        .onChange(of: presenter.password1) { _, newValue in
            presenter.handleFirstChanged(newValue)
        }
        .onChange(of: presenter.password2) { _, newValue in
            presenter.handleSecondChanged(newValue)
        }
        .onAppear {
            DispatchQueue.main.async {
                focusedField = .first
            }
        }
        .dismissKeyboardOnTapOutside()
    }
}
