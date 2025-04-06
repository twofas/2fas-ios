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

struct SyncMigrationToNewestVersionView: View {
    @ObservedObject
    var presenter: SyncMigrationToNewestVersionPresenter
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
                Spacer()
                VStack(spacing: Theme.Metrics.standardSpacing) {
                    Asset.cloudBackup.swiftUIImage
                    Spacer()
                        .frame(height: Theme.Metrics.doubleMargin)
                    Text("Migrating Cloud Backup")
                        .font(.title)
                        .multilineTextAlignment(.center)
                    Text("Don't turn the app off!")
                        .font(.body)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(Theme.Colors.Text.theme))
                    Text("Your backup is being encrypted using a generated key. This key will be shared amongst your app installations using iCloud Keychain so remember to have that option turned on. If you want to use your own key and password you can do that in Cloud Backup settings right after the migration.")
                        .font(.caption)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                if presenter.isMigrating {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(.vertical, Theme.Metrics.doubleMargin)
                } else {
                    VStack {
                        if let migrationFailureReason = presenter.migrationFailureReason {
                            Label("Failure! \(migrationFailureReason.description)", systemImage: "xmark.circle.fill")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(Theme.Colors.Text.theme))
                        } else {
                            Label("Success!", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.green)
                        }
                        Button {
                            presenter.close()
                        } label: {
                            Text(T.Commons.done)
                                .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .buttonStyle(RoundedFilledButtonStyle())
                        .padding(.vertical, Theme.Metrics.doubleMargin)
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
