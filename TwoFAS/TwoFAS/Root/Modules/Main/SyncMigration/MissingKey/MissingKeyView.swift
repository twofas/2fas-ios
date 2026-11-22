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

struct MissingKeyView: View {
    @ObservedObject
    var presenter: MissingKeyPresenter

    var body: some View {
        NavigationStack {
            Group {
                if presenter.isWorking {
                    AdaptiveReadableContainer {
                        TFLoadingView(title: T.Backup.syncStatusProgress)
                    }
                } else {
                    // The cards don't fit a small screen or a large text size
                    ScrollView {
                        AdaptiveReadableContainer {
                            content
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
            }
            .background(.backgroundsPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $presenter.isEnteringPassword) {
                MissingKeyPasswordView(presenter: presenter)
            }
            .closeToolbar {
                presenter.close()
            }
        }
    }

    private var content: some View {
        VStack(alignment: .center, spacing: .XXL) {
            VStack(spacing: .XL) {
                Image(icon: .lockIcloudFill)
                    .textStyle(.iconLarge)
                    .foregroundStyle(.accentsBrand)
                    .padding(.top, .XXL)

                Text(presenter.title)
                    .textStyle(.title1, .emphasized)
                    .foregroundStyle(.labelsPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: .L) {
                if presenter.canEnterPassword {
                    TFInstructionCard(
                        icon: .password,
                        title: T.Backup.missingKeyPasswordTitle,
                        description: T.Backup.missingKeyPasswordMsg,
                        primaryButton: TFInstructionCardButton(title: T.Backup.missingKeyPasswordAction) {
                            presenter.onEnterPassword()
                        }
                    )
                }

                TFInstructionCard(
                    icon: .iCloudSync,
                    title: T.Backup.missingKeyKeychainTitle,
                    description: T.Backup.missingKeyKeychainMsg
                )

                TFInstructionCard(
                    icon: .download,
                    title: T.Backup.missingKeyImportTitle,
                    description: T.Backup.missingKeyImportMsg,
                    primaryButton: TFInstructionCardButton(title: T.Backup.import) {
                        presenter.onImport()
                    }
                )

                TFInstructionCard(
                    icon: .link,
                    title: T.Backup.missingKeyClearTitle,
                    description: T.Backup.missingKeyClearMsg,
                    secondaryButton: TFInstructionCardButton(title: T.Backup.missingKeyClearAction) {
                        presenter.onClearBackup()
                    }
                )
            }
        }
    }
}

/// The step of `MissingKeyView` where the backup password is entered
private struct MissingKeyPasswordView: View {
    @ObservedObject
    var presenter: MissingKeyPresenter

    @FocusState
    private var isFocused: Bool?

    var body: some View {
        AdaptiveReadableContainer {
            if presenter.isVerifyingPassword {
                TFLoadingView(title: T.Backup.veryfingPassword)
            } else {
                form
            }
        }
        .dismissKeyboardOnTapOutside()
        .minimumBottomSpacing()
        .background(.backgroundsPrimaryElevated)
        .navigationTitle(T.Backup.missingKeyPasswordTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(presenter.isVerifyingPassword)
        .onAppear {
            isFocused = true
        }
    }

    private var form: some View {
        VStack(alignment: .center, spacing: .XL) {
            Text(T.Backup.missingKeyPasswordMsg)
                .textStyle(.body)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            TFFloatingTextField(
                placeHolder: T.Backup.password,
                text: $presenter.password,
                inputType: .password,
                focused: $isFocused,
                focusValue: true,
                submit: .init(buttonType: presenter.canCheckPassword ? .send : .return) {
                    presenter.onCheckPassword()
                }
            )
            .groupedSectionBackground(isElevated: true)

            if presenter.isPasswordWrong {
                Label(T.Backup.missingKeyPasswordWrong, icon: .xmarkCircleFill)
                    .textStyle(.callout, .emphasized)
                    .foregroundStyle(.accentsBrand)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
                .frame(maxHeight: .infinity)

            TFButton(T.Backup.checkPassword, variant: .borderedProminent, size: .large) {
                presenter.onCheckPassword()
            }
            .disabled(!presenter.canCheckPassword)
        }
    }
}
