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
    let description: String
    let actionTitle: String
}

struct AppleWatchView: View {
    private let presenter: AppleWatchPresenter
    
    init(presenter: AppleWatchPresenter) {
        self.presenter = presenter
    }
    
    var body: some View {
        AdaptiveReadableContainer {
            VStack(alignment: .center, spacing: .XXL) {
                VStack(spacing: .XL) {
                    Image(systemName: "lock.applewatch")
                        .textStyle(.iconLarge)
                        .foregroundStyle(.accentsBrand)
                        .padding(.top, .XXXXXL)
                        .symbolBounceOnAppear()
                    
                    Text(T.AppleWatch.installationInfoTitle)
                        .textStyle(.title1, .emphasized)
                        .foregroundStyle(.labelsPrimary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                VStack(spacing: .L) {
                    ForEach(
                        Array(presenter.appleWatchInstallationSteps.enumerated()),
                        id: \.element
                    ) { index, step in
                        let stepNumber = index + 1
                        TFInstructionCard(
                            icon: icon(for: stepNumber),
                            title: step.actionTitle,
                            description: step.description,
                            accessory: .link,
                            onTap: { presenter.handleInstallationStep(number: stepNumber) }
                        )
                    }
                }
                
                Spacer()
                    .frame(maxHeight: .infinity)
            }
        }
        .background(.backgroundsPrimary)
        .navigationTitle(T.Settings.appleWatch)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func icon(for stepNumber: Int) -> TFInstructionCardIcon {
        switch stepNumber {
        case 1: .download
        case 2: .iCloudSync
        default: .link
        }
    }
}
