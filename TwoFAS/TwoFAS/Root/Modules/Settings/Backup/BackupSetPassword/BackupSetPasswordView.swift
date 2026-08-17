//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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

struct BackupSetPasswordView: View {
    @Bindable
    var presenter: BackupSetPasswordPresenter

    /// When `true`, the screen owns its navigation and wraps its content in a
    /// native `NavigationStack` (title + Close button). When `false`, it's a
    /// destination pushed into a navigation stack that already exists, so it
    /// relies on that stack's bar and native back button instead.
    let embedsNavigationStack: Bool

    @FocusState
    private var focusedField: Field?
    private enum Field: Int, Hashable {
        case first
        case second
    }

    var body: some View {
        if embedsNavigationStack {
            NavigationStack {
                content
            }
        } else {
            content
                .chevronOnlyBackButton()
        }
    }

    private var content: some View {
        VStack(spacing: .zero) {
            ScrollView {
                AdaptiveReadableContainer {
                    if presenter.isDone {
                        TFSuccessView(title: T.Backup.passwordSet)
                    } else if presenter.isApplyingChanges {
                        TFLoadingView(title: presenter.applyingChangesText)
                            .padding(.top, .XXXXXL)
                    } else {
                        formContent
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)

            if !presenter.isApplyingChanges {
                AdaptiveReadableContainer {
                    VStack(spacing: .L) {
                        TFButton(
                            T.Commons.continue,
                            variant: .borderedProminent,
                            size: .large
                        ) {
                            focusedField = nil
                            presenter.handleContinue()
                        }
                        .disabled(!presenter.isDone && !presenter.isContinueEnabled)
                    }
                }
            }
        }
        .dismissKeyboardOnTapOutside()
        .background(.backgroundsPrimaryElevated)
        .navigationTitle(presenter.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if embedsNavigationStack, showsCloseInTitleBar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presenter.handleClose()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: presenter.password1) { _, newValue in
            presenter.handleFirstChanged(newValue)
        }
        .onChange(of: presenter.password2) { _, newValue in
            presenter.handleSecondChanged(newValue)
        }
        .onAppear {
            guard !presenter.isApplyingChanges, !presenter.isDone else { return }
            DispatchQueue.main.async {
                focusedField = .first
            }
        }
    }

    private var showsCloseInTitleBar: Bool {
        !presenter.isApplyingChanges && !presenter.isDone
    }

    @ViewBuilder
    private var formContent: some View {
        VStack(spacing: .XXXL) {
            Text(T.Backup.passwordSetDescription)
                .textStyle(.callout)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: .zero) {
                TFFloatingTextField(
                    placeHolder: T.Backup.encryptionEnterPassword,
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
                        presenter.handleContinue()
                    })
                )
            }
            .groupedSectionBackground(isElevated: true)

            if let error = presenter.migrationError {
                Label(error, systemImage: "xmark.circle.fill")
                    .textStyle(.footnote)
                    .foregroundStyle(.accentsOrange)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
