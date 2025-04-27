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

struct BackupChangeEncryptionView: View {
    @ObservedObject
    var presenter: BackupChangeEncryptionPresenter
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
                    List {
                        Section(T.Backup.encryptionType) {
                            Picker(T.Backup.encryptionSelect, selection: $presenter.selectedEncryption) {
                                ForEach(CloudEncryptionType.allCases, id: \.self) { type in
                                    Text(type.localized)
                                        .tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color(Theme.Colors.Fill.theme))
                        }
                        if presenter.selectedEncryption == .user {
                            Section(
                                content: {
                                    SecureField(T.Backup.encryptionEnterPassword, text: $presenter.password)
                                },
                                header: {
                                    presenter.changingPassword ?
                                    Text(verbatim: T.Backup.encryptionChangePassword) :
                                    Text(verbatim: T.Backup.encryptionEnterPassword)
                                },
                                footer: {
                                    Text(verbatim: T.Backup.encryptionPasswordDescription)
                                        .font(.caption2)
                                        .minimumScaleFactor(0.8)
                                })
                        }
                    }
                    Spacer()
                        .frame(maxHeight: Theme.Metrics.doubleMargin)
                    if presenter.isChangingEncryption {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        VStack(spacing: Theme.Metrics.doubleMargin) {
                            if let migrationFailureReason = presenter.migrationFailureReason {
                                Label(T.Backup.enterPasswordFailure(migrationFailureReason.description), systemImage: "xmark.circle.fill")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(Theme.Colors.Text.theme))
                            }
                            Button {
                                dismissKeyboard()
                                presenter.applyChange()
                            } label: {
                                Text(verbatim: T.Commons.apply)
                                    .frame(maxWidth: .infinity)
                            }
                            .modify {
                                if presenter.changePasswordEnabled {
                                    $0.buttonStyle(RoundedFilledButtonStyle())
                                } else {
                                    $0.buttonStyle(RoundedFilledInactiveButtonStyle())
                                }
                            }
                            .frame(maxWidth: Theme.Metrics.componentWidth)
                            .padding(.bottom, Theme.Metrics.doubleMargin)
                            .disabled(!presenter.changePasswordEnabled)
                        }
                    }
                }
                .disabled(presenter.isChangingEncryption)
                .padding(.vertical, Theme.Metrics.doubleMargin)
                .navigationTitle(T.Backup.encryptionChangeTitle)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            presenter.close()
                        }) {
                            Text(T.Commons.close)
                                .tint(Color(Theme.Colors.Text.theme))
                        }
                        .disabled(presenter.isChangingEncryption)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity)
        .background(Color(Theme.Colors.Fill.System.third))
        .onAppear {
            presenter.onAppear()
        }
    }
}
