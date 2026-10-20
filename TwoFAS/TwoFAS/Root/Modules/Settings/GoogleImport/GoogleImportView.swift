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

struct GoogleImportView: View {
    @Bindable
    var presenter: GoogleImportPresenter

    let showsCloseButton: Bool

    var body: some View {
        AdaptiveReadableContainer {
            VStack(spacing: Spacing.XL) {
                GeometryReader { proxy in
                    ScrollView {
                        VStack(spacing: Spacing.XL) {
                            Spacer(minLength: 0)

                            VStack(spacing: Spacing.M) {
                                Text(T.Tokens.googleImportTitle)
                                    .textStyle(.title2, .emphasized)
                                    .foregroundStyle(.labelsPrimary)
                                    .multilineTextAlignment(.center)

                                Text(T.Tokens.googleImportMultiSubtitle)
                                    .textStyle(.title3)
                                    .foregroundStyle(.labelsPrimary)
                                    .multilineTextAlignment(.center)

                                Text(T.Tokens.googleImportScannedCount(presenter.scannedCount, presenter.totalCount))
                                    .textStyle(.body)
                                    .foregroundStyle(.labelsSecondary)
                                    .multilineTextAlignment(.center)
                            }

                            if presenter.totalCount > 0 {
                                GoogleImportCodesGrid(scannedList: presenter.scannedList)
                                    .frame(maxWidth: .infinity)
                            }

                            Spacer(minLength: 0)
                        }
                        .frame(minHeight: proxy.size.height)
                        .frame(maxWidth: .infinity)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }

                if !presenter.isComplete {
                    VStack(spacing: Spacing.M) {
                        TFButton(T.Commons.scanQrCode, variant: .borderedProminent, size: .large) {
                            presenter.handleScanWithCamera()
                        }

                        TFButton(T.Tokens.selectFromGallery, variant: .bordered, size: .large) {
                            presenter.handleScanFromGallery()
                        }

                        TFButton(T.Tokens.googleImportOnlyScanned, variant: .borderless, size: .large) {
                            presenter.handleOnlyScanned()
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .minimumBottomSpacing()
        .background(.backgroundsPrimaryElevated)
        .onAppear {
            presenter.handleViewAppeared()
        }
        .navigationBarTitleDisplayMode(.inline)
        .modify { view in
            if showsCloseButton {
                view.closeToolbar {
                    presenter.handleClose()
                }
            } else {
                view
            }
        }
        .alert(T.Tokens.googleImportDifferentBatchTitle, isPresented: $presenter.showBatchError) {
            Button(T.Commons.ok, role: .cancel) {}
        } message: {
            Text(T.Tokens.googleImportDifferentBatchMessage)
        }
        .alert(T.Tokens.googleImportAlreadyScannedTitle, isPresented: $presenter.alreadyScanned) {
            Button(T.Commons.ok, role: .cancel) {}
        } message: {
            Text(T.Tokens.googleImportAlreadyScannedMessage)
        }
    }
}

private struct GoogleImportCodesGrid: View {
    let scannedList: [Bool]

    @Environment(\.colorScheme)
    private var colorScheme

    private let circleSize: CGFloat = Theme.Metrics.buttonHeight
    private let spacing: Spacing = .M

    private var columnCount: Int {
        min(max(scannedList.count, 1), 5)
    }

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.fixed(circleSize), spacing: spacing.value, alignment: .leading),
            count: columnCount
        )
    }

    private var gridWidth: CGFloat {
        CGFloat(columnCount) * circleSize + CGFloat(columnCount - 1) * spacing.value
    }

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: spacing.value) {
            ForEach(Array(scannedList.enumerated()), id: \.offset) { index, isImported in
                circle(number: index + 1, isImported: isImported)
            }
        }
        .frame(width: gridWidth)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: scannedList)
    }

    private func circle(number: Int, isImported: Bool) -> some View {
        Text(verbatim: "\(number)")
            .textStyle(.body)
            .foregroundStyle(.labelsPrimary)
            .frame(width: circleSize, height: circleSize)
            .modify {
                if #available(iOS 26, *) {
                    $0.glassEffect(
                        isImported
                            ? .regular.tint(AppColor.accentsBrand.color(for: colorScheme))
                            : .regular,
                        in: Circle()
                    )
                } else {
                    $0.background {
                        if isImported {
                            Circle().foregroundStyle(.accentsBrand)
                        } else {
                            Circle().foregroundStyle(.fillsTertiary)
                        }
                    }
                }
            }
            .scaleEffect(isImported ? 1 : 0.9)
    }
}
