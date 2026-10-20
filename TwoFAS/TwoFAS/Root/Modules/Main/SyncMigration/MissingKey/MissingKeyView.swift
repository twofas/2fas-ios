//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

struct MissingKeyView: View {
    @ObservedObject
    var presenter: MissingKeyPresenter

    var body: some View {
        NavigationStack {
            AdaptiveReadableContainer {
                if presenter.isWorking {
                    TFLoadingView(title: T.Backup.syncStatusProgress)
                } else {
                    content
                }
            }
            .background(.backgroundsPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .closeToolbar {
                presenter.close()
            }
        }
    }

    private var content: some View {
        VStack(alignment: .center, spacing: .XXL) {
            VStack(spacing: .XL) {
                Image(icon: .lockIcloudFill)
                    .textStyle(.iconLarge)
                    .foregroundStyle(.accentsBrand)
                    .padding(.top, .XXXXXL)

                Text(presenter.title)
                    .textStyle(.title1, .emphasized)
                    .foregroundStyle(.labelsPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: .L) {
                TFInstructionCard(
                    icon: .iCloudSync,
                    title: "Make sure iCloud Keychain is enabled",
                    description: "Open the Settings app, tap your name, then iCloud, and make sure Passwords & "
                    + "Keychain is turned on. The missing keys may sync back automatically."
                )

                TFInstructionCard(
                    icon: .download,
                    title: "Import the missing keys",
                    description: "If you have a backup file with your encryption keys, import it to restore access.",
                    primaryButton: TFInstructionCardButton(title: T.Backup.import) {
                        presenter.onImport()
                    }
                )

                TFInstructionCard(
                    icon: .link,
                    title: "I don't have the keys",
                    description: "Clear the iCloud backup and start from scratch using this device's data.",
                    primaryButton: TFInstructionCardButton(title: "Clear backup") {
                        presenter.onClearBackup()
                    }
                )
            }

            Spacer()
                .frame(maxHeight: .infinity)
        }
    }
}
