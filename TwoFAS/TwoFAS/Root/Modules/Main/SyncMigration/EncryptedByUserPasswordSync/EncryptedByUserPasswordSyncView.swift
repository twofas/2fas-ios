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

struct EncryptedByUserPasswordSyncView: View {
    @ObservedObject
    var presenter: EncryptedByUserPasswordSyncPresenter

    @FocusState
    private var isFocused: Bool?
    
    var body: some View {
        NavigationStack {
            AdaptiveReadableContainer {
                VStack(alignment: .center) {
                    VStack(alignment: .center, spacing: Spacing.M) {
                        if !presenter.isWorking && !presenter.isDone {
                            VStack(spacing: .ML) {
                                Text(
                                    verbatim: presenter.isVerifyingPassword ?
                                    T.Backup.verifyPasswordDescription :
                                        T.Backup.enterPasswordDescription
                                )
                                .textStyle(.body)
                                .foregroundStyle(.labelsPrimary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                                    .frame(height: Spacing.XL.rawValue)

                                TFFloatingTextField(
                                    placeHolder: T.Backup.password,
                                    text: $presenter.password,
                                    inputType: .password,
                                    focused: $isFocused,
                                    focusValue: true,
                                    submit: .init(
                                        buttonType: presenter.checkPasswordEnabled ? .send : .return, action: {
                                        if presenter.checkPasswordEnabled {
                                            presenter.onCheckPassword()
                                        }
                                    })
                                )
                                .disabled(presenter.isWorking)
                                .groupedSectionBackground(isElevated: true)
                            }
                            Spacer()
                                .frame(maxHeight: .infinity)
                        }
                        
                        if presenter.isWorking {
                            TFLoadingView(
                                title: presenter.isRemovingPassword ?
                                T.Backup.removingPassword :
                                    T.Backup.veryfingPassword
                            )
                        } else {
                            VStack {
                                if let migrationFailureReason = presenter.migrationFailureReason {
                                    labelFail(migrationFailureReason.description)
                                } else {
                                    if presenter.wrongPassword {
                                        labelWrongPassword
                                    } else if presenter.isDone {
                                        TFSuccessView(title: T.Commons.successEx)
                                    }
                                }
                                if isFocused == nil || isFocused == false {
                                    VStack {
                                        TFButton(doneLabel(), variant: .borderedProminent, size: .large) {
                                            if presenter.isDone {
                                                presenter.close()
                                            } else {
                                                presenter.onCheckPassword()
                                            }
                                        }
                                        .disabled(!presenter.checkPasswordEnabled)
                                    }
                                    .padding(.top, Spacing.XL)
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .dismissKeyboardOnTapOutside()
            .minimumBottomSpacing()
            .background(.backgroundsPrimaryElevated)
            .navigationTitle(presenter.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presenter.close()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
    
    private func doneLabel() -> String {
        if presenter.isDone {
            T.Commons.done
        } else {
            if presenter.isRemovingPassword {
                T.backupSettingsPasswordRemoveTitle
            } else if presenter.isVerifyingPassword {
                T.Commons.continue
            } else {
                T.Backup.checkPassword
            }
        }
    }
    @ViewBuilder
    private func labelFail(_ description: String) -> some View {
        Label(
            T.Backup.enterPasswordFailure(description),
            systemImage: "xmark.circle.fill"
        )
        .textStyle(.callout, .emphasized)
        .foregroundStyle(.accentsBrand)
    }
    
    @ViewBuilder
    private var labelWrongPassword: some View {
        Label(T.Backup.enterPasswordWrongPassword, systemImage: "xmark.circle.fill")
            .textStyle(.callout, .emphasized)
            .foregroundStyle(.accentsBrand)
    }
}
