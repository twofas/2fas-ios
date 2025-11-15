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

    @State
    private var isFocused = false
    
    @State
    private var height: CGFloat = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
                    if !presenter.isWorking && !presenter.isDone {
                    VStack(spacing: Theme.Metrics.standardSpacing) {
                        
                            Spacer()
                                .frame(height: Theme.Metrics.doubleMargin)
                            Text(verbatim: T.Commons.icloudBackupPassword)
                                .font(.title2)
                                .multilineTextAlignment(.center)
                            Text(
                                verbatim: presenter.isVerifyingPassword ? "iCloud backup is encrypted with your password. Enter it to apply changes." : T.Backup.enterPasswordDescription
                            )
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                                .frame(height: Theme.Metrics.doubleMargin)
                            input()
                                .padding(.bottom, Theme.Metrics.halfSpacing)
                        }
                        Spacer()
                            .frame(maxHeight: .infinity)
                    }

                    if presenter.isWorking {
                        Spacer()
                            .frame(maxHeight: .infinity)
                        VStack(spacing: Theme.Metrics.doubleSpacing) {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(Color(ThemeColor.theme))
                                .scaleEffect(1.5)
                            Text(verbatim: presenter.isRemovingPassword ? "Removing Password" : "Verifying password")
                                .font(.body)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                            .frame(maxHeight: .infinity)
                    } else {
                        VStack {
                            if let migrationFailureReason = presenter.migrationFailureReason {
                                Label(
                                    T.Backup.enterPasswordFailure(migrationFailureReason.description),
                                    systemImage: "xmark.circle.fill"
                                )
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(Theme.Colors.Text.theme))
                            } else {
                                if presenter.wrongPassword {
                                    Label(T.Backup.enterPasswordWrongPassword, systemImage: "xmark.circle.fill")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color(Theme.Colors.Text.theme))
                                } else if presenter.isDone {
                                    Spacer()
                                        .frame(maxHeight: .infinity)
                                    Label(T.Commons.successEx, systemImage: "checkmark.circle.fill")
                                        .font(.title3)
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(Color.green)
                                    Spacer()
                                        .frame(maxHeight: .infinity)
                                }
                            }
                            VStack {
                                Button {
                                    if presenter.isDone {
                                        presenter.close()
                                    } else {
                                        presenter.onCheckPassword()
                                    }
                                } label: {
                                    Text(doneLabel())
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                .modify {
                                    if presenter.checkPasswordEnabled {
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
            if !isFocused {
                self.height = height
            }
        }
    }
    
    @ViewBuilder
    private func input() -> some View {
        VStack(spacing: Theme.Metrics.quaterSpacing) {
            PasswordTextField(title: T.Backup.password, text: $presenter.password, isFocused: $isFocused)
                .onSubmit {
                    if presenter.checkPasswordEnabled {
                        presenter.onCheckPassword()
                    }
                }
                .submitLabel(presenter.checkPasswordEnabled ? .send : .return)
            Divider()
                .overlay {
                    Rectangle()
                        .foregroundStyle(presenter.isWorking ?
                                         Color(Theme.Colors.Text.inactive) :
                                            Color(Theme.Colors.Line.primaryLine))
                }
        }
        .disabled(presenter.isWorking)
        .frame(height: 20)
    }
    
    private func doneLabel() -> String {
        if presenter.isDone {
            return T.Commons.done
        } else {
            if presenter.isRemovingPassword {
                return "Remove password"
            } else if presenter.isVerifyingPassword {
                return T.Commons.continue
            } else {
                return T.Backup.checkPassword
            }
        }
    }
}
