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

struct EncryptedByUserPasswordSyncView: View {
    @State
    var presenter: EncryptedByUserPasswordSyncPresenter
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
                Spacer()
                VStack(spacing: Theme.Metrics.standardSpacing) {
                    Asset.cloudBackup.swiftUIImage
                    Spacer()
                        .frame(height: Theme.Metrics.doubleMargin)
                    Text("Enter Cloud Backup Password")
                        .font(.title)
                        .multilineTextAlignment(.center)
                    Text("iCloud Backup is encrypted by your password. Enter password to enable sync")
                        .font(.caption)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                    Spacer()
                        .frame(height: Theme.Metrics.doubleMargin)
                    SecureField("Password", text: $presenter.password)
                        .disabled(presenter.isCheckingPassword)
                        .background(Color(Theme.Colors.Form.rowInput))
                }
                Spacer()
                if presenter.isCheckingPassword {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    VStack {
                        if let migrationFailureReason = presenter.migrationFailureReason {
                            Label("Failure! \(migrationFailureReason.errorText)", systemImage: "xmark.circle.fill")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(Theme.Colors.Text.theme))
                        } else {
                            if presenter.wrongPassword {
                                Label("Wrong password! Try again)", systemImage: "xmark.circle.fill")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(Theme.Colors.Text.theme))
                            } else if presenter.isDone {
                                Label("Success!", systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.green)
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
                                Text(presenter.isDone ? T.Commons.done : "Check password")
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
            .frame(maxWidth: Theme.Metrics.componentWidth)
            .padding(.vertical, Theme.Metrics.doubleMargin)
        }
        .frame(maxWidth: .infinity)
        .background(Color(Theme.Colors.Fill.System.third))
    }
}
