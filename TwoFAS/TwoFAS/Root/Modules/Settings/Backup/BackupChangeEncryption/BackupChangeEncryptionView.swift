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
    @State
    var presenter: BackupChangeEncryptionPresenter
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
                    List {
                        Section("Encryption type") {
                            Picker("Select encryption", selection: $presenter.selectedEncryption) {
                                Text("System").tag(CloudEncryptionType.system)
                                Text("User").tag(CloudEncryptionType.user)
                            }
                        }
                        if presenter.selectedEncryption == .user {
                            Section(content: {
                                SecureField("Enter password", text: $presenter.password)
                            }, header: {
                                Text("Enter password")
                            }, footer: {
                                Text("Password is used to encrypt your data. If you loose it you won't be able to recover data from Cloud Backup")
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
                                Label("Failure! \(migrationFailureReason.errorText)", systemImage: "xmark.circle.fill")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(Theme.Colors.Text.theme))
                            }
                            Button {
                                presenter.applyChange()
                            } label: {
                                Text("Apply")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(RoundedFilledButtonStyle())
                            .frame(maxWidth: Theme.Metrics.componentWidth)
                            .disabled(!presenter.changePasswordEnabled)
                        }
                    }
                }
                .padding(.vertical, Theme.Metrics.doubleMargin)
                .navigationTitle("Change Encryption")
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
    }
}
