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
    @ObservedObject
    var presenter: BackupSetPasswordPresenter
    
    @State
    private var height: CGFloat = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
                    VStack(spacing: Theme.Metrics.standardSpacing) {
                        if presenter.isDone {
                            Spacer()
                                .frame(maxHeight: .infinity)
                            Label(T.Backup.passwordSet, systemImage: "checkmark.circle.fill"
                            )
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.green)
                        } else if !presenter.isApplyingChanges {
                            header()
                            inputs()
                                .padding(.bottom, Theme.Metrics.halfSpacing)
                        }
                    }
                    Spacer()
                        .frame(maxHeight: .infinity)
                    if presenter.isApplyingChanges {
                        VStack(spacing: Theme.Metrics.doubleSpacing) {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(Color(ThemeColor.theme))
                                .scaleEffect(1.5)
                            Text(
                                verbatim: presenter.isSettingPassword ?
                                T.Backup.settingPassword :
                                    T.Backup.changingPassword
                            )
                            .font(.body)
                            .multilineTextAlignment(.center)
                        }
                        Spacer()
                            .frame(maxHeight: .infinity)
                    } else {
                        VStack {
                            if let error = presenter.migrationError {
                                Label(error, systemImage: "xmark.circle.fill")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(Theme.Colors.Text.theme))
                            }
                            VStack {
                                Button {
                                    if presenter.isDone {
                                        presenter.close()
                                    } else {
                                        presenter.applyChanges()
                                    }
                                } label: {
                                    Text(verbatim: T.Commons.continue)
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                .modify {
                                    if presenter.continueButtonEnabled {
                                        $0.buttonStyle(RoundedFilledButtonStyle())
                                    } else {
                                        $0.buttonStyle(RoundedFilledInactiveButtonStyle())
                                    }
                                }
                                Button {
                                    presenter.close()
                                } label: {
                                    Text(T.Commons.close)
                                }
                                .buttonStyle(LinkButtonStyle())
                                .isHidden(presenter.isDone)
                            }
                            .padding(.top, Theme.Metrics.doubleMargin)
                        }
                    }
                }
                .background(Color(Theme.Colors.Fill.background))
                .frame(maxWidth: Theme.Metrics.componentWidth)
                .padding(.top, Theme.Metrics.doubleMargin)
            }
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .background(Color(Theme.Colors.Fill.background))
        }
        .scrollContentBackground(.hidden)
        .background(Color(Theme.Colors.Fill.background))
        .frame(maxHeight: .infinity)
        .observeHeight { height in
            if !presenter.isFocused1 && !presenter.isFocused2 {
                self.height = height
            }
        }
    }
    
    @ViewBuilder
    private func header() -> some View {
        Spacer()
            .frame(height: Theme.Metrics.doubleMargin)
        Text(verbatim: presenter.isSettingPassword ? T.Backup.setPassword : T.Backup.changePassword)
            .font(.title2)
            .multilineTextAlignment(.center)
        Text(verbatim: T.Backup.passwordSetDescription)
            .font(.caption)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        Spacer()
            .frame(height: 2 * Theme.Metrics.doubleSpacing)
    }
    
    @ViewBuilder
    private func inputs() -> some View {
        VStack(spacing: Theme.Metrics.standardSpacing) {
            VStack(spacing: Theme.Metrics.quaterSpacing) {
                PasswordTextField(
                    title: T.Backup.encryptionEnterPassword,
                    text: $presenter.password1,
                    isFocused: $presenter.isFocused1
                )
                .onSubmit {
                    DispatchQueue.main.async {
                        presenter.isFocused1 = false
                        presenter.isFocused2 = true
                    }
                }
                .submitLabel(.next)
                Divider()
                    .overlay {
                        Rectangle()
                            .foregroundStyle(Color(Theme.Colors.Line.primaryLine))
                    }
            }
            VStack(spacing: Theme.Metrics.quaterSpacing) {
                PasswordTextField(
                    title: T.Backup.repeatPassword,
                    text: $presenter.password2,
                    isFocused: $presenter.isFocused2
                )
                .onSubmit {
                    if presenter.continueButtonEnabled {
                        presenter.applyChanges()
                    }
                }
                .submitLabel(.return)
                Divider()
                    .overlay {
                        Rectangle()
                            .foregroundStyle(Color(Theme.Colors.Line.primaryLine))
                    }
            }
            Text(verbatim: T.Backup.passwordRulesDescription)
                .font(.caption)
                .foregroundStyle(Color(Theme.Colors.Text.subtitle))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            if let validationError = presenter.validationError {
                Label(validationError, systemImage: "xmark.circle.fill")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(Theme.Colors.Text.theme))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .disabled(presenter.isApplyingChanges)
    }
}
