//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
//  Contributed by Grzegorz Machnio. All rights reserved.
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

struct AppleWatchInstallationStep: Hashable, Identifiable {
    var id = UUID()
    let descirption: String
    let actionTitle: String
}

struct AppleWatchView: View {
    private let spacing: CGFloat = Theme.Metrics.doubleSpacing

    let appleWatchInstallationSteps: [AppleWatchInstallationStep] 
    let installationStepActionCallback: (_ stepNumber: Int) -> Void

    var body: some View {
        VStack(spacing: spacing) {
            Image(uiImage: Asset.appleWatch.image)
                .renderingMode(.original)
                .padding(.top, Theme.Metrics.standardSpacing)

                Text("2FAS Apple Watch app installation")
                .font(Font(Theme.Fonts.Text.title))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)

            VStack(alignment: .leading) {
                ForEach(Array(appleWatchInstallationSteps.enumerated()), id: \.element) { index, step in
                    let stepNumber = index + 1
                    stepView(
                        for: step,
                        stepNumber: stepNumber,
                        isDividerVisible: stepNumber != appleWatchInstallationSteps.count
                    )
                }
            }
            .padding(.horizontal, Theme.Metrics.quadrupleMargin)
        }
    }

    private func stepView(
        for step: AppleWatchInstallationStep,
        stepNumber: Int,
        isDividerVisible: Bool
    ) -> some View {
        HStack(alignment: .top) {
            Text("\(stepNumber)")
                .font(Font(Theme.Fonts.iconLabelLarge))
                .frame(width: 28, height: 28)
                .background(Color(Theme.Colors.Fill.tertiary))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: Theme.Metrics.halfSpacing) {
                Text(step.descirption)
                    .font(Font(Theme.Fonts.Text.content))

                Button {
                    installationStepActionCallback(stepNumber)
                } label: {
                    HStack(spacing: Theme.Metrics.halfSpacing) {
                        Text(step.actionTitle)
                            .font(Font(Theme.Fonts.Text.boldContent))

                        Image(systemName: "arrow.up.right")
                            .font(Font(Theme.Fonts.iconLabelExtraLarge))
                    }
                    .foregroundColor(Color(Theme.Colors.Text.theme))
                }

                if isDividerVisible {
                    Divider()
                        .frame(height: Theme.Metrics.separatorHeight)
                        .padding(.vertical, Theme.Metrics.standardSpacing)
                }
            }
        }
    }
}

#Preview {
    AppleWatchView(
        appleWatchInstallationSteps: [
            .init(descirption: "Install 2FAS Auth via Watch app",
                  actionTitle: "Open Watch app"),
            .init(descirption: "Ensure your 2FAS Backup iCloud sync is enabled.",
                  actionTitle: "Go to 2FAS Backup settings")
        ], 
        installationStepActionCallback: { _ in }
    )
}
