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

struct AddingServiceView: View {
    private let viewportHeight: CGFloat = 220
    private let viewportRatio: CGFloat = 0.63
    
    @State
    private var errorReason: String?
    
    @State
    private var isVisible = false

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

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
        MainScreenModalView(
            onClose: onClose,
            title: T.Tokens.addManualTitle,
            subtitle: T.Tokens.addDescription
        ) {
            VStack(spacing: .zero) {
                if errorReason != nil || presenter.isCameraUnavailable {
                    ErrorTextView(errorReason: errorReason)
                        .onTapGesture {
                            guard presenter.isCameraUnavailable else { return }
                            presenter.handleToAppSettings()
                        }
                } else {
                    AddingServiceCameraViewport(
                        height: AddingServiceMetrics.cameraActiveAreaHeight(for: horizontalSizeClass),
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
            .frame(height: AddingServiceMetrics.cameraActiveAreaHeight(for: horizontalSizeClass))
            .clipShape(RoundedRectangle(.badge))
            .overlay {
                RoundedRectangle(.badge)
                    .stroke(.bordersWhite, lineWidth: 1)
            }
            .padding(.top, .XL)
        } footer: {
            VStack(spacing: .L) {
                Text(T.Tokens.requestIconMiddle)
                    .textStyle(.subheadline)
                    .foregroundStyle(.labelsPrimary)

                TFButton(T.Tokens.addEnterManual, variant: .borderedSecondary, size: .large, applyGlass: false) {
                    presenter.handleToAddManually()
                }

                TFButton(
                    T.Tokens.addFromGallery,
                    variant: .borderedSecondary,
                    size: .large
                ) {
                    presenter.handleToGallery()
                }

                TFButton(T.Tokens.addWithGuide, variant: .borderlessNeutral, size: .large) {
                    presenter.handleToGuides()
                }
            }
        }
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
        .getName(
            $presenter.showRename,
            title: T.Tokens.enterServiceName,
            message: nil,
            placeholder: presenter.currentName,
            confirmTitle: T.Commons.rename
        ) { newName in
            presenter.handleRename(newName: newName)
        } onCancel: {
            presenter.handleCancelRename()
        } onVerify: { value in
            ServiceRules.isServiceNameValid(serviceName: value)
        }
        .getName(
            $presenter.showPairWatchQuestion,
            title: T.Backup.watchPairingTitle,
            message: T.Backup.watchPairingDescription,
            placeholder: T.Backup.watchPairingDefaultName,
            defaultText: T.Backup.watchPairingDefaultName,
            confirmTitle: T.Backup.watchPairingAction) { deviceName in
                presenter.handleAppleWatchPairing(
                    deviceName: deviceName
                )
            } onVerify: { deviceName in
                ServiceRules.isAppleWatchNameValid(deviceName: deviceName)
            }
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
            .foregroundColor(Color(AppColor.graysWhite.uiColor))
            .multilineTextAlignment(.center)
            .padding(.horizontal, Spacing.XL)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
