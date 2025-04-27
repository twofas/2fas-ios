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
                    Text(verbatim: T.Backup.migrationTitle)
                        .font(.title)
                        .multilineTextAlignment(.center)
                    Text(verbatim: T.Backup.migrationSubtitle)
                        .font(.body)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(Theme.Colors.Text.theme))
                    Text(verbatim: T.Backup.migrationDescription)
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
                            Label(T.Backup.enterPasswordFailure(migrationFailureReason.description), systemImage: "xmark.circle.fill")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(Theme.Colors.Text.theme))
                        } else {
                            Label(T.Commons.successEx, systemImage: "checkmark.circle.fill")
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
