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
    private var focusedField: FocusedField?
    
    @State
    private var height: CGFloat = 0
    
    private enum FocusedField {
        case password
    }
    
    var body: some View {
        ScrollView {
            Section {
                VStack(alignment: .center) {
                    VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
                        VStack(spacing: Theme.Metrics.standardSpacing) {
                            Asset.cloudBackup.swiftUIImage
                            Spacer()
                                .frame(height: Theme.Metrics.doubleMargin)
                            Text(verbatim: T.Commons.icloudBackupPassword)
                                .font(.title2)
                                .multilineTextAlignment(.center)
                            Text(verbatim: T.Backup.enterPasswordDescription)
                                .font(.caption)
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                            Spacer()
                                .frame(height: Theme.Metrics.doubleMargin)
                            
                            input()
                                .padding(.bottom, Theme.Metrics.halfSpacing)
                        }
                        Spacer()
                        if presenter.isCheckingPassword {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(Color(ThemeColor.theme))
                                .scaleEffect(1.5)
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
                                        Label(T.Commons.successEx, systemImage: "checkmark.circle.fill")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.green)
                                    }
                                }
                                Spacer()
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
                    .background(Color(Theme.Colors.Fill.background))
                    .frame(maxWidth: Theme.Metrics.componentWidth)
                    .padding(.top, Theme.Metrics.doubleMargin)
                }
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .background(Color(Theme.Colors.Fill.background))
            }
            .listRowBackground(Color(Theme.Colors.Fill.background))
        }
        .scrollContentBackground(.hidden)
        .background(Color(Theme.Colors.Fill.background))
        .frame(maxHeight: .infinity)
        .observeHeight { height in
            if focusedField == nil {
                self.height = height
            }
        }
    }
    
    @ViewBuilder
    private func input() -> some View {
        VStack(spacing: Theme.Metrics.quaterSpacing) {
            HStack {
                FloatingField(placeholder: Text(T.Backup.password), isEmpty: presenter.password.isEmpty) {
                    PasswordContentInput(
                        label: "",
                        password: $presenter.password,
                        isReveal: presenter.firstInputReveal
                    )
                }
                .focused($focusedField, equals: .password)
                .onSubmit {
                    if presenter.checkPasswordEnabled {
                        presenter.onCheckPassword()
                    }
                }
                .submitLabel(presenter.checkPasswordEnabled ? .send : .return)
                
                Spacer()
                
                Toggle(isOn: $presenter.firstInputReveal, label: {})
                    .toggleStyle(RevealToggleStyle())
            }
            Divider()
                .overlay {
                    Rectangle()
                        .foregroundStyle(presenter.isCheckingPassword ?
                                         Color(Theme.Colors.Text.inactive) :
                                            Color(Theme.Colors.Line.primaryLine))
                }
        }
        .disabled(presenter.isCheckingPassword)
    }
}
