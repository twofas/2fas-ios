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
import Data

/// Shown instead of the app while the local storage isn't ready (`LocalStoragePreflight`): explains what happened
/// and lets the user try again or reset the local data. Nothing of the app exists under it.
struct LocalDataUnavailableView: View {
    /// Called when the local storage became ready – the app can be started
    let onReady: Callback
    /// Checks the local storage again
    var retry: () -> LocalStorageStatus = { LocalStoragePreflight.run(userVisible: false) }
    /// Removes the local data and checks the local storage again
    var reset: () -> LocalStorageStatus = { LocalStoragePreflight.resetLocalData() }

    @State
    private var status: LocalStorageStatus
    @State
    private var isStillUnavailable = false
    @State
    private var isResetConfirmationPresented = false

    init(status: LocalStorageStatus, onReady: @escaping Callback) {
        self.onReady = onReady
        _status = State(initialValue: status)
    }

    var body: some View {
        VStack(spacing: .zero) {
            // The text sits in the middle of the space above the buttons and scrolls when it doesn't fit
            GeometryReader { proxy in
                ScrollView {
                    AdaptiveReadableContainer {
                        VStack(spacing: .L) {
                            TFInfoContent(
                                icon: .systemImage(.exclamationmarkTriangle, bounces: true),
                                title: title,
                                description: description
                            )
                            if isStillUnavailable {
                                Text(T.Storage.stillUnavailable)
                                    .textStyle(.footnote)
                                    .foregroundStyle(.accentsBrand)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(minHeight: proxy.size.height, alignment: .center)
                }
                .scrollBounceBehavior(.basedOnSize)
            }

            AdaptiveReadableContainer(verticalMargin: .zero) {
                VStack(spacing: .L) {
                    TFButton(T.Storage.tryAgain, variant: .borderedProminent, size: .large) {
                        handle(retry())
                    }
                    TFButton(T.Storage.resetLocalData, variant: .borderless, size: .large) {
                        isResetConfirmationPresented = true
                    }
                }
            }
        }
        .background(AppColor.backgroundsPrimary)
        .minimumBottomSpacing()
        .alert(T.Storage.resetConfirmTitle, isPresented: $isResetConfirmationPresented) {
            Button(T.Commons.cancel, role: .cancel) {}
            Button(T.Storage.resetConfirmAction, role: .destructive) {
                handle(reset())
            }
        } message: {
            Text(T.Storage.resetConfirmMsg)
        }
    }

    private var title: String {
        switch status {
        case .keyLost: T.Storage.keyLostTitle
        case .keyUnavailable, .ready: T.Storage.localDataUnavailableTitle
        case .migrationFailed: T.Storage.migrationFailedTitle
        }
    }

    private var description: String {
        switch status {
        case .keyLost(let launchesLeft):
            T.Storage.keyLostMsg + "\n\n" + T.Storage.keyLostAutoReset(launchesLeft)
        case .keyUnavailable, .ready:
            T.Storage.localDataUnavailableMsg
        case .migrationFailed:
            T.Storage.migrationFailedMsg
        }
    }

    private func handle(_ newStatus: LocalStorageStatus) {
        guard newStatus != .ready else {
            onReady()
            return
        }
        status = newStatus
        isStillUnavailable = true
        AccessibilityNotification.Announcement(T.Storage.stillUnavailable).post()
    }
}

#Preview("Key lost") {
    LocalDataUnavailableView(status: .keyLost(launchesLeft: 2), onReady: {})
}

#Preview("Key unavailable") {
    LocalDataUnavailableView(status: .keyUnavailable, onReady: {})
}

#Preview("Migration failed") {
    LocalDataUnavailableView(status: .migrationFailed, onReady: {})
}
