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

struct UserIconInfoView: View {
    let presenter: UserIconInfoPresenter

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    var body: some View {
        ScrollView {
            AdaptiveReadableContainer {
                VStack(spacing: .XL) {
                    socialSection
                    orDivider
                    providerSection
                }
            }
        }
        .background(AppColor.backgroundsPrimaryElevated)
        .navigationTitle(T.Tokens.requestIconPageTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var socialSection: some View {
        VStack(spacing: .XL) {
            Image(uiImage: Asset.requestSocial.image)
                .renderingMode(.template)
                .foregroundStyle(AppColor.accentsBrand)

            Text(T.Tokens.requestIconSocialTitle)
                .textStyle(.headline)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Button {
                presenter.handleSocial()
            } label: {
                VStack(spacing: .XS) {
                    HStack(spacing: .S) {
                        Text(T.Tokens.requestIconSocialLink)
                            .textStyle(.body)
                            .foregroundStyle(.accentsBrand)
                        Image(uiImage: Asset.externalLinkIcon.image)
                            .renderingMode(.template)
                            .foregroundStyle(AppColor.accentsBrand)
                    }
                    Text(T.Tokens.requestIconSocialDescription)
                        .textStyle(.body)
                        .foregroundStyle(.labelsPrimary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var orDivider: some View {
        HStack(spacing: .SM) {
            Rectangle()
                .fill(.separatorsNonOpaque)
                .frame(height: 1)
            Text(T.Tokens.requestIconMiddle)
                .textStyle(.footnote)
                .foregroundStyle(.labelsSecondary)
            Rectangle()
                .fill(.separatorsNonOpaque)
                .frame(height: 1)
        }
    }

    @ViewBuilder
    private var providerSection: some View {
        VStack(spacing: .XL) {
            Image(uiImage: Asset.requestProvider.image)
                .renderingMode(.template)
                .foregroundStyle(AppColor.accentsBrand)

            Text(T.Tokens.requestIconProviderTitle)
                .textStyle(.headline)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Text(T.Tokens.requestIconProviderDescription)
                .textStyle(.body)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            shareFrame

            footnote
        }
    }

    @ViewBuilder
    private var shareFrame: some View {
        Button {
            presenter.handleShare()
        } label: {
            HStack(spacing: .XL) {
                Text(decoratedProviderMessage)
                    .textStyle(.body)
                    .foregroundStyle(.labelsPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle()
                    .fill(.separatorsNonOpaque)
                    .frame(width: 1)

                Image(uiImage: Asset.shareIcon.image)
                    .renderingMode(.template)
                    .foregroundStyle(AppColor.accentsBrand)
            }
            .padding(.XL)
            .background(AppColor.backgroundsPrimaryElevated)
            .cornerRadius(.large)
            .overlay(
                RoundedRectangle(.large)
                    .stroke(.separatorsNonOpaque, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var decoratedProviderMessage: AttributedString {
        var attributed = AttributedString(T.Tokens.requestIconProviderMessage)
        if let range = attributed.range(of: T.Tokens.requestIconProviderMessageLink) {
            attributed[range].foregroundColor = AppColor.accentsBrand.color(for: colorScheme)
        }
        return attributed
    }

    @ViewBuilder
    private var footnote: some View {
        HStack(spacing: .S) {
            Image(uiImage: Asset.warningSmall.image)
                .renderingMode(.template)
                .foregroundStyle(AppColor.labelsPrimary)
            Text(T.Tokens.requestIconProviderFootnote)
                .textStyle(.caption1)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
