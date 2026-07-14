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
}

struct BrowserExtensionIntroView<Presenter: BrowserExtensionIntroPresenting>: View {
    private let presenter: Presenter

    init(presenter: Presenter) {
        self.presenter = presenter
    }

    var body: some View {
        VStack(spacing: .zero) {
            TFScreenTitleBar(
                title: T.Browser.browserExtension,
                leadingSymbol: presenter.hasCancel ? .close : nil,
                onLeadingTap: presenter.hasCancel ? presenter.handleCancel : nil
            )

            ScrollView {
                VStack(spacing: .XXL) {
                    Image(systemName: "puzzlepiece.extension.fill")
                        .textStyle(.iconLarge)
                        .foregroundStyle(.accentsBrand)
                        .padding(.top, .XL)

                    Text(T.Browser.infoTitle)
                        .textStyle(.title1, .emphasized)
                        .foregroundStyle(.labelsPrimary)
                        .multilineTextAlignment(.center)

                    VStack(spacing: .L) {
                        ForEach(Array(presenter.steps.enumerated()), id: \.element) { _, step in
                            TFInstructionCard(
                                icon: step.icon,
                                title: step.title,
                                description: step.description,
                                accessory: nil
                            )
                        }
                    }

                    VStack(spacing: .S) {
                        Text(T.Browser.moreInfo)
                            .textStyle(.footnote)
                            .foregroundStyle(.labelsSecondary)
                            .multilineTextAlignment(.center)

                        TFButton(
                            T.Browser.moreInfoLinkTitle,
                            variant: .borderless,
                            size: .small,
                            action: presenter.handleInfo
                        )
                    }
                }
                .padding(.horizontal, .XL)
                .padding(.bottom, .XL)
            }

            VStack(spacing: .L) {
                TFButton(
                    T.Browser.pairWithWebBrowser,
                    variant: .borderedProminent,
                    size: .large,
                    action: presenter.handleAction
                )
            }
            .padding(.horizontal, .XL)
            .padding(.bottom, .XL)
        }
        .background(.backgroundsPrimary)
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
}

#Preview {
    final class BrowserExtensionIntroPresenterMock: BrowserExtensionIntroPresenting {
        var hasCancel: Bool { false }
        let steps: [BrowserExtensionIntroStep] = [
            .init(title: T.Browser.infoDescriptionFirst, icon: .download, description: nil),
            .init(title: T.Browser.infoDescriptionSecond, icon: .link, description: nil)
        ]

        func handleAction() {}
        func handleCancel() {}
        func handleInfo() {}
    }

    return BrowserExtensionIntroView(presenter: BrowserExtensionIntroPresenterMock())
}
