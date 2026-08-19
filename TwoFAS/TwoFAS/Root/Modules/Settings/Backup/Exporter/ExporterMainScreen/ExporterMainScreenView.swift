//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
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

struct ExporterMainScreenView: View {
    @Bindable
    var presenter: ExporterMainScreenPresenter

    @ObservedObject
    var router: ExporterRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            TFInfoView(
                icon: .image(Asset.exportBackup.image, .original),
                title: T.Backup.exportToBackupFile,
                description: T.Backup.importFileTitle,
                buttons: {
                TFToggleRow(T.Backup.backupFilePasswordTitle, isOn: $presenter.setPassword, isElevated: true)
                    .padding(.bottom, .S)

                TFButton(
                    T.Backup.exportToFile,
                    variant: .borderedProminent,
                    size: .large
                ) {
                    presenter.handleExport()
                }

                TFCancelButton(T.Commons.cancel) {
                    presenter.handleClose()
                }
            })
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presenter.handleClose()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .navigationDestination(for: ExporterRoute.self) { route in
                router.destination(for: route)
            }
        }
        .background(.backgroundsPrimary)
    }
}
