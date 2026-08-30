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

struct BrowserExtensionIntroStep: Hashable, Identifiable {
    var id = UUID()
    let title: String
    let icon: TFInstructionCardIcon
    let description: String?
    let hasAction: Bool
}

struct BrowserExtensionIntroView: View {
    private let presenter: BrowserExtensionIntroPresenter
    
    init(presenter: BrowserExtensionIntroPresenter) {
        self.presenter = presenter
    }
    
    var body: some View {
        AdaptiveReadableContainer {
            VStack(alignment: .center, spacing: .XXL) {
                VStack(spacing: .XL) {
                    Image(icon: .desktopcomputerAndArrowDown)
                        .textStyle(.iconLarge)
                        .foregroundStyle(.accentsBrand)
                        .padding(.top, .XXXXXL)
                        .symbolBounceOnAppear()
                    
                    Text(T.Browser.infoTitle)
                        .textStyle(.title1, .emphasized)
                        .foregroundStyle(.labelsPrimary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                VStack(spacing: .L) {
                    ForEach(Array(presenter.steps.enumerated()), id: \.element) { _, step in
                        TFInstructionCard(
                            icon: step.icon,
                            title: step.title,
                            description: step.description,
                            accessory: nil,
                            primaryButton: step.hasAction ? .init(title: T.Browser.pairWithWebBrowser, action: {
                                presenter.handleAction()
                            }) : nil
                        )
                    }
                }

                Spacer()
                    .frame(maxHeight: .infinity)
            }
        }
        .background(.backgroundsPrimary)
        .navigationTitle(T.Settings.browserExtensionHeader)
        .navigationBarTitleDisplayMode(.inline)
    }
}
