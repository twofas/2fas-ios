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
        AdaptiveReadableContainer {
                VStack(alignment: .center) {
                    VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
                        if !presenter.isWorking && !presenter.isDone {
                            VStack(spacing: .ML) {
                                Spacer()
                                    .frame(height: Spacing.XL.rawValue)
                                Text(verbatim: T.Commons.icloudBackupPassword)
                                    .textStyle(.title2)
                                    .foregroundStyle(.labelsPrimary)
                                    .multilineTextAlignment(.center)
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
                                .groupedSectionBackground()
                            }
                            Spacer()
                                .frame(maxHeight: .infinity)
                        }
                        
                        if presenter.isWorking {
                            Spacer()
                                .frame(maxHeight: .infinity)
                            VStack(spacing: .XL) {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.accentsBrand)
                                    .scaleEffect(1.5)
                                Text(
                                    verbatim: presenter.isRemovingPassword ?
                                    T.Backup.removingPassword :
                                        T.Backup.veryfingPassword
                                )
                                .textStyle(.body)
                                .foregroundStyle(.labelsPrimary)
                                .multilineTextAlignment(.center)
                            }
                            Spacer()
                                .frame(maxHeight: .infinity)
                        } else {
                            VStack {
                                if let migrationFailureReason = presenter.migrationFailureReason {
                                    labelFail(migrationFailureReason.description)
                                } else {
                                    if presenter.wrongPassword {
                                        labelWrongPassword
                                    } else if presenter.isDone {
                                        Spacer()
                                            .frame(maxHeight: .infinity)
                                        labelSuccess
                                        Spacer()
                                            .frame(maxHeight: .infinity)
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
                                        
                                        TFButton(T.Commons.close, variant: .borderedSecondary, size: .large) {
                                            presenter.close()
                                        }
                                        .isHidden(presenter.isDone)
                                    }
                                    .padding(.top, Theme.Metrics.doubleMargin)
                                }
                            }
                        }
                    }
                    .padding(.top, .XL)
                }
            .frame(maxHeight: .infinity)
        }
        .dismissKeyboardOnTapOutside()
        .background(.backgroundsPrimaryElevated)
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
    
    @ViewBuilder
    private var labelSuccess: some View {
        Label(T.Commons.successEx, systemImage: "checkmark.circle.fill")
            .textStyle(.title3)
            .multilineTextAlignment(.center)
            .foregroundStyle(.accentsMint)
    }
}
