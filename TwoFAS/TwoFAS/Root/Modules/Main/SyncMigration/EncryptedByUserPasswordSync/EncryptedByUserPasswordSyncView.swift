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
    @ObservedObject
    var presenter: EncryptedByUserPasswordSyncPresenter
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
                    Spacer()
                    VStack(spacing: Theme.Metrics.standardSpacing) {
                        Asset.cloudBackup.swiftUIImage
                        Spacer()
                            .frame(height: Theme.Metrics.doubleMargin)
                        Text(verbatim: T.Backup.enterPasswordTitle)
                            .font(.title)
                            .multilineTextAlignment(.center)
                        Text(verbatim: T.Backup.enterPasswordDescription)
                            .font(.caption)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                        Spacer()
                            .frame(height: Theme.Metrics.doubleMargin)
                        
                        VStack(alignment: .leading, spacing: Theme.Metrics.standardMargin) {
                            Text(verbatim: T.Backup.password)
                                .font(.caption2)
                                .foregroundStyle(Color(Theme.Colors.Text.subtitle))
                            VStack(spacing: Theme.Metrics.halfSpacing) {
                                SecureField(T.Backup.password, text: $presenter.password)
                                    .font(Font(Theme.Fonts.iconLabelInputTitle))
                                    .foregroundStyle(presenter.isCheckingPassword ?
                                                     Color(Theme.Colors.Text.inactive) :
                                                        Color(Theme.Colors.Form.rowInput))
                                    .lineLimit(1)
                                    .disabled(presenter.isCheckingPassword)
                                Divider()
                                    .overlay {
                                        Rectangle()
                                            .foregroundStyle(presenter.isCheckingPassword ?
                                                             Color(Theme.Colors.Text.inactive) :
                                                                Color(Theme.Colors.Line.primaryLine))
                                    }
                            }
                        }
                    }
                    Spacer()
                    if presenter.isCheckingPassword {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        VStack {
                            if let migrationFailureReason = presenter.migrationFailureReason {
                                Label(T.Backup.enterPasswordFailure(migrationFailureReason.description), systemImage: "xmark.circle.fill")
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
                                    Label(T.Commons.successEx, systemImage: "checkmark.circle.fill")
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
                                    Text(presenter.isDone ? T.Commons.done : T.Backup.checkPassword)
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
}
