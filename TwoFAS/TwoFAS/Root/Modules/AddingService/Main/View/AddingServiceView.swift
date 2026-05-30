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
import CommonUI

struct AddingServiceView: View {
    private let viewportHeight: CGFloat = 220
    private let viewportRatio: CGFloat = 0.63
    private let ipadMaxWidth: CGFloat = 480
    
    @State
    private var errorReason: String?
    
    @State
    private var isVisible = false
    
    @Bindable
    var presenter: AddingServicePresenter
    
    let onClose: () -> Void

    init(
        presenter: AddingServicePresenter,
        onClose: @escaping () -> Void
    ) {
        self.presenter = presenter
        self.onClose = onClose
    }
    
    var body: some View {
        AdaptiveReadableContainer(
            ipadMaxWidth: ipadMaxWidth,
            horizontalMargin: Spacing.XL.rawValue,
            verticalMargin: Spacing.XL.rawValue
        ) {
            VStack(spacing: .L) {
                HStack(spacing: .zero) {
                    Spacer()
                    TFLiquidGlassSymbolButton(symbol: .close) {
                        onClose()
                    }
                }
                
                header()
                
                VStack(spacing: .zero) {
                    if errorReason != nil || presenter.isCameraUnavailable {
                        ErrorTextView(errorReason: errorReason)
                            .onTapGesture {
                                guard presenter.isCameraUnavailable else { return }
                                presenter.handleToAppSettings()
                            }
                    } else {
                        AddingServiceCameraViewport(
                            cameraFreeze: $presenter.freezeCamera,
                            didRegisterError: { error in
                                self.errorReason = error
                            },
                            didFoundCode: { codeType in
                                presenter.handleFoundCode(codeType: codeType)
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: AddingServiceMetrics.cameraActiveAreaHeight)
                .clipShape(RoundedRectangle(.badge))
                .overlay {
                    RoundedRectangle(.badge)
                        .stroke(.bordersWhite, lineWidth: 1)
                }
                
                Text("or")
                    .textStyle(.subheadline)
                    .foregroundStyle(.labelsPrimary)
                
                TFButton("Enter secret key", variant: .borderedSecondary, size: .largeWide, applyGlass: false) {
                    presenter.handleToAddManually()
                }
                
                TFButton("Upload image with QR code", variant: .borderedSecondary, size: .largeWide) {
                    presenter.handleToGallery()
                }
                
                TFButton("Guide me", variant: .borderlessNeutral, size: .largeWide) {
                    presenter.handleToGuides()
                }
            }
        }
        .background {
            RoundedRectangle(.extraLarge)
                .foregroundStyle(.backgroundsPrimary)
                .shadow(.glass)
        }
        .overlay {
            RoundedRectangle(.extraLarge)
                .stroke(.bordersVibrant, lineWidth: 1)
        }
        .environment(\.colorScheme, .dark)
        .alert(item: $presenter.alert) { alert in
            switch alert {
            case .cantPairWatch:
                Alert(
                    title: Text(T.Commons.error),
                    message: Text(T.Backup.watchPairingError),
                    dismissButton: .default(Text(T.Commons.ok))
                )
            case .appStore:
                Alert(
                    title: Text(T.Tokens.qrCodeLeadsToAppStore),
                    message: Text(T.Tokens.scanQrCodeTitle),
                    dismissButton: .default(Text(T.Commons.ok), action: {
                        presenter.handleResumeCamera()
                    })
                )
            case .generalError:
                Alert(
                    title: Text(T.Tokens.thisQrCodeIsInavlid),
                    message: Text(T.Tokens.scanQrCodeTitle),
                    dismissButton: .default(Text(T.Commons.ok), action: {
                        presenter.handleResumeCamera()
                    })
                )
            case .duplicatedCode(let code):
                Alert(
                    title: Text(T.Commons.warning),
                    message: Text(T.Tokens.serviceAlreadyExists),
                    primaryButton: .destructive(Text(T.Commons.yes), action: {
                        presenter.onForceAddCode(code)
                        presenter.handleResumeCamera()
                    }),
                    secondaryButton: .cancel(Text(T.Commons.no), action: {
                        presenter.handleResumeCamera()
                    })
                )
            }
        }
    }
    
    @ViewBuilder
    private func header() -> some View {
        VStack(spacing: .XS) {
            Text("Pair service with 2FAS")
                .textStyle(.headline)
                .foregroundStyle(.labelsPrimary)
            
            Text("Point your camera to the screen to capture the QR code.")
                .multilineTextAlignment(.center)
                .textStyle(.subheadline)
                .foregroundStyle(.labelsPrimary)
        }
        .padding(.bottom, .XXXXXL)
    }
}

private struct ErrorTextView: View {
    let errorReason: String?
    
    var body: some View {
        let reason: AttributedString = {
            if let errorReason {
                return AttributedString(errorReason)
            }

            var result = AttributedString(T.Tokens.cameraIsUnavailableAppPermission)
            if let range = result.range(of: T.Tokens.cameraIsUnavailableAppPermissionUnderline) {
                result[range].underlineStyle = .single
            }
            
            return result
        }()
        Text(reason)
            .font(.headline)
            .foregroundColor(Color(Theme.Colors.Text.light))
            .multilineTextAlignment(.center)
            .padding(.horizontal, Theme.Metrics.doubleMargin)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
