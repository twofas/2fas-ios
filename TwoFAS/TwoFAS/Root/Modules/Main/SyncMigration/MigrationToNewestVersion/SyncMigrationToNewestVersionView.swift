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

struct SyncMigrationToNewestVersionView: View {
    private let image = Asset.cloudBackup.image
    
    @ObservedObject
    var presenter: SyncMigrationToNewestVersionPresenter
    
    var body: some View {
        NavigationStack {
            TFInfoView {
            Image(uiImage: image)
                .renderingMode(.original)
                .frame(width: image.size.width, height: image.size.height)
                .scaleEffect(0.75)
        } texts: {
            Text(verbatim: T.Backup.migrationTitle)
                .textStyle(.title1, .emphasized)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.center)
            Text(verbatim: T.Backup.migrationSubtitle)
                .textStyle(.title2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.accentsBrand)
            Text(verbatim: T.Backup.migrationDescription)
                .textStyle(.body)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .foregroundStyle(.labelsPrimary)
        } buttons: {
            if presenter.isMigrating {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                    .tint(.accentsBrand)
                    .padding(.vertical, .XL)
            } else {
                VStack {
                    if let migrationFailureReason = presenter.migrationFailureReason {
                        TFFailureView(title: T.Backup.enterPasswordFailure(migrationFailureReason.description))
                    } else {
                        TFSuccessView(title: T.Commons.successEx)
                    }
                    TFButton(T.Commons.done, variant: .borderedProminent, size: .large) {
                        presenter.close()
                    }
                }
            }
        }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
