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

// MARK: - TFInstructionCardIcon

@frozen
public enum TFInstructionCardIcon {
    case download
    case iCloudSync
    case link

    var systemName: String {
        switch self {
        case .download: "arrow.down.circle.fill"
        case .iCloudSync: "arrow.trianglehead.2.clockwise.rotate.90.icloud.fill"
        case .link: "link"
        }
    }

    var color: AppColor {
        switch self {
        case .download: .accentsBlue
        case .iCloudSync, .link: .accentsGreen
        }
    }
}

// MARK: - TFInstructionCardAccessory

@frozen
public enum TFInstructionCardAccessory {
    case chevron
    case link

    var systemName: String {
        switch self {
        case .chevron: "chevron.right"
        case .link: "arrow.up.forward"
        }
    }
}

// MARK: - TFInstructionCardButton

public struct TFInstructionCardButton {
    let title: String
    let action: () -> Void

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

// MARK: - TFInstructionCard

public struct TFInstructionCard: View {
    private let icon: TFInstructionCardIcon
    private let title: String
    private let description: String?
    private let accessory: TFInstructionCardAccessory?
    private let primaryButton: TFInstructionCardButton?
    private let secondaryButton: TFInstructionCardButton?

    public init(
        icon: TFInstructionCardIcon,
        title: String,
        description: String? = nil,
        accessory: TFInstructionCardAccessory? = nil,
        primaryButton: TFInstructionCardButton? = nil,
        secondaryButton: TFInstructionCardButton? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.accessory = accessory
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .XXL) {
            header
            if primaryButton != nil || secondaryButton != nil {
                buttons
            }
        }
        .padding(.XL)
        .background(
            RoundedRectangle(.large)
                .fill(AppColor.backgroundsPrimary)
        )
        .overlay(
            RoundedRectangle(.large)
                .inset(by: 0.75)
                .stroke(AppColor.bordersPrimary, lineWidth: 1)
        )
    }

    private var header: some View {
        HStack(alignment: .top, spacing: .L) {
            Image(systemName: icon.systemName)
                .textStyle(.title3, .regular)
                .foregroundStyle(icon.color)

            VStack(alignment: .leading, spacing: .XS) {
                Text(title)
                    .textStyle(.body, .emphasized)
                    .foregroundStyle(.labelsPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let description {
                    Text(description)
                        .textStyle(.footnote, .regular)
                        .foregroundStyle(.labelsSecondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if let accessory {
                Image(systemName: accessory.systemName)
                    .textStyle(.body, .emphasized)
                    .foregroundStyle(.labelsTertiary)
                    .accessibilityHidden(true)
            }
        }
    }

    private var buttons: some View {
        VStack(spacing: .L) {
            if let primaryButton {
                TFButton(
                    primaryButton.title,
                    variant: .borderedProminent,
                    size: .medium,
                    action: primaryButton.action
                )
            }
            if let secondaryButton {
                TFButton(
                    secondaryButton.title,
                    variant: .bordered,
                    size: .medium,
                    action: secondaryButton.action
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: .XL) {
            TFInstructionCard(
                icon: .download,
                title: "Download the app",
                description: "Install the companion app on your other device to continue the setup.",
                accessory: .chevron
            )

            TFInstructionCard(
                icon: .iCloudSync,
                title: "Sync via iCloud",
                description: "Your data will be securely synced across all your devices.",
                primaryButton: TFInstructionCardButton(title: "Enable sync") {},
                secondaryButton: TFInstructionCardButton(title: "Not now") {}
            )

            TFInstructionCard(
                icon: .link,
                title: "Open in browser",
                accessory: .link
            )

            TFInstructionCard(
                icon: .download,
                title: "Import from another app",
                description: "Choose a file to import your existing tokens.",
                primaryButton: TFInstructionCardButton(title: "Choose file") {}
            )
        }
        .padding(.XL)
    }
    .background(AppColor.backgroundsPrimaryElevated)
}
