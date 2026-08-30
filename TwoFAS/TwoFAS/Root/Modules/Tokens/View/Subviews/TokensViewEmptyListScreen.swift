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

// MARK: - Model

final class TokensEmptyListModel: ObservableObject {
    @Published var trashCount: Int = 0

    var pairNewService: Callback?
    var importFromExternalService: Callback?
    var help: Callback?
    var goToTrashAction: Callback?

    func setItemsInTrashCount(_ count: Int) {
        trashCount = count
    }
}

// MARK: - Empty list screen

struct TokensEmptyListView: View {
    @ObservedObject
    var model: TokensEmptyListModel

    var body: some View {
        VStack(spacing: .zero) {
            if model.trashCount > 0 {
                TrashWarningCard(count: model.trashCount) {
                    model.goToTrashAction?()
                }
                .frame(maxWidth: Theme.Metrics.componentWidth)
                .padding(.top, .XL)
            }

            Spacer(minLength: Spacing.M.value)

            AdaptiveReadableContainer(
                iphoneMaxWidth: Theme.Metrics.componentWidth,
                ipadMaxWidth: Theme.Metrics.componentWidth,
                verticalMargin: .zero
            ) {
                VStack(spacing: .XXXXXL) {
                    TFInfoContent(
                        icon: .systemImage(.qrcode),
                        title: T.Tokens.emptyListTitle,
                        description: T.Introduction.descriptionTitle
                    )

                    VStack(spacing: .XL) {
                        TFButton(
                            T.Introduction.pairNewService,
                            variant: .borderedProminent,
                            size: .large,
                            applyGlass: true
                        ) {
                            model.pairNewService?()
                        }

                        TFButton(
                            T.Introduction.importExternalApp,
                            variant: .borderless,
                            size: .large
                        ) {
                            model.importFromExternalService?()
                        }
                    }
                }
            }

            Spacer(minLength: Spacing.M.value)

            Button {
                model.help?()
            } label: {
                Text(T.Introduction.whatToDo)
                    .foregroundStyle(.labelsPrimary)
                    .textStyle(.subheadline, .emphasized)
                    .padding(.horizontal, .ML)
                    .padding(.vertical, .S)
                    .background {
                        RoundedRectangle(.medium)
                            .foregroundStyle(.fillsTertiary)
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.backgroundsPrimary)
        .minimumBottomSpacing(.XXXXXXL)
    }
}

// MARK: - Trash warning card

private struct TrashWarningCard: View {
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: .S) {
                Image(icon: .trash)
                    .textStyle(.subheadline, .emphasized)
                    .foregroundStyle(.labelsPrimary)

                VStack(alignment: .leading, spacing: .S) {
                    Text(summary)
                        .textStyle(.subheadline)
                        .foregroundStyle(.labelsPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: .S) {
                        Text(T.Commons.goToTrash)
                            .textStyle(.callout)
                        Image(icon: .arrowUpForward)
                            .textStyle(.callout)
                    }
                    .foregroundStyle(.accentsBrand)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, .XL)
            .padding(.vertical, .L)
            .background(
                RoundedRectangle(.large)
                    .fill(AppColor.backgroundsSecondary)
            )
        }
        .buttonStyle(.plain)
    }

    private var summary: AttributedString {
        let raw = T.Tokens.emptyScreenInTrash(count)
        return (try? AttributedString(markdown: raw)) ?? AttributedString(raw)
    }
}
