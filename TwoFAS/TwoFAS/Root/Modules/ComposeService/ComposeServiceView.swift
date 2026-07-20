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

struct ComposeServiceView: View {
    @ObservedObject
    var presenter: ComposeServicePresenter

    @FocusState
    private var focusedField: Field?
    private enum Field: Int, Hashable {
        case serviceName
        case secret
        case additionalInfo
    }

    @State private var touchedServiceName = false
    @State private var touchedAdditionalInfo = false

    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            header

            ScrollView {
                AdaptiveReadableContainer {
                    VStack(spacing: .XXXL) {
                        serviceInformationSection
                        personalizationSection
                        if presenter.isBrowserExtensionAllowed {
                            otherSection
                        }
                        deleteSection
                    }
                }
                .dismissKeyboardOnTapOutside()
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .background(.backgroundsPrimaryElevated)
        .onAppear {
            presenter.viewWillAppear()
        }
        .onReceive(NotificationCenter.default.publisher(for: .servicesWereUpdated)) { notification in
            let modified = notification.userInfo?[Notification.UserInfoKey.modified] as? [String]
            let deleted = notification.userInfo?[Notification.UserInfoKey.deleted] as? [String]
            presenter.handleServicesWereUpdated(modified: modified, deleted: deleted)
        }
        .onChange(of: presenter.serviceName) { _, _ in touchedServiceName = true }
        .onChange(of: presenter.additionalInfo) { _, _ in touchedAdditionalInfo = true }
        .alert(T.Commons.notice, isPresented: $presenter.isSetPINAlertPresented) {
            Button(T.Commons.cancel, role: .cancel) {}
            Button(T.Commons.set, role: .destructive) {
                presenter.handleSwitchToSetupPIN()
            }
        } message: {
            Text(T.Tokens.showServiceKeySetupLock)
        }
        .confirmationDialog(
            T.Commons.optionsTitle,
            isPresented: $presenter.isRevealMenuPresented,
            titleVisibility: .visible
        ) {
            Button(T.Tokens.copySecret) { presenter.handleCopySecret() }
            Button(T.Tokens.copyLink) { presenter.handleCopyLink() }
            Button(T.Tokens.qrCodeShow) { presenter.handleShowQRCode() }
            Button(T.Tokens.qrCodeShare) { presenter.handleShareQRCode() }
            Button(T.Commons.cancel, role: .cancel) {}
        }
    }

    @ViewBuilder
    private var header: some View {
        ZStack {
            HStack(spacing: .zero) {
                TFLiquidGlassSymbolButton(symbol: .close) {
                    presenter.handleCancel()
                }
                Spacer()
                TFLiquidGlassTextButton(T.Commons.save, color: .accentsBrand) {
                    presenter.handleSave()
                }
                .disabled(!presenter.isSaveEnabled)
            }
            TFTitleView(title: T.Commons.edit)
        }
        .padding(.horizontal, .XL)
        .padding(.vertical, .XL)
    }

    @ViewBuilder
    private var serviceInformationSection: some View {
        VStack(spacing: .zero) {
            sectionHeader(T.Tokens.serviceInformation)

            VStack(spacing: .zero) {
                TFFloatingTextField(
                    placeHolder: T.Tokens.serviceName,
                    text: $presenter.serviceName,
                    inputType: .name,
                    keyboardType: .asciiCapable,
                    focused: $focusedField,
                    focusValue: .serviceName,
                    errorMessage: gatedError($presenter.serviceNameError, touched: touchedServiceName),
                    submit: .init(buttonType: .next, action: {
                        focusedField = .additionalInfo
                    })
                )
                .onChange(of: presenter.serviceName) { _, newValue in
                    presenter.handleServiceNameUpdate(newValue)
                }

                separator()

                ComposeServiceSecretKeyField(
                    mode: presenter.secretKeyMode,
                    secret: .constant(""),
                    errorMessage: .constant(nil),
                    focused: $focusedField,
                    focusValue: .secret,
                    onReveal: { presenter.handleReveal() },
                    onShare: { presenter.handleShare() }
                )

                separator()

                TFFloatingTextField(
                    placeHolder: T.Tokens.additionalInfo,
                    text: $presenter.additionalInfo,
                    inputType: .other,
                    keyboardType: .asciiCapable,
                    focused: $focusedField,
                    focusValue: .additionalInfo,
                    errorMessage: gatedError($presenter.additionalInfoError, touched: touchedAdditionalInfo),
                    submit: .init(buttonType: .done, action: {
                        focusedField = nil
                    })
                )
                .onChange(of: presenter.additionalInfo) { _, newValue in
                    presenter.handleAdditionalInfoUpdate(newValue)
                }

                separator()

                navigationRow(
                    title: T.Tokens.advanced,
                    accessory: .arrow,
                    isEnabled: true,
                    action: { presenter.handleAdvanced() }
                )
            }
            .groupedSectionBackground(isElevated: true)
        }
    }

    @ViewBuilder
    private var personalizationSection: some View {
        VStack(spacing: .zero) {
            sectionHeader(T.Tokens.personalization)

            VStack(spacing: .zero) {
                ComposeServiceIconTypeSelector(
                    selectedType: Binding(
                        get: { presenter.iconType },
                        set: { presenter.handleIconType($0) }
                    ),
                    iconTypeID: presenter.iconTypeID,
                    labelTitle: presenter.labelTitle,
                    labelColor: presenter.labelColor
                )

                separator()

                navigationRow(
                    title: T.Tokens.changeBrandIcon,
                    accessory: .arrow,
                    isEnabled: presenter.isBrandIconRowEnabled,
                    action: { presenter.handleBrandIcon() }
                )

                separator()

                navigationRow(
                    title: T.Tokens.changeLabel,
                    accessory: .arrow,
                    isEnabled: presenter.isLabelRowEnabled,
                    action: { presenter.handleLabel() }
                )

                separator()

                TFColorPickerMenu(
                    title: T.Tokens.badgeColor,
                    selectedColor: Binding(
                        get: { presenter.badgeColor },
                        set: { presenter.handleBadgeColor($0) }
                    ),
                    colors: TintColor.badgeList
                )

                separator()

                navigationRow(
                    title: T.Tokens.group,
                    accessory: .text(presenter.sectionTitle),
                    isEnabled: true,
                    action: { presenter.handleCategory() }
                )
            }
            .groupedSectionBackground(isElevated: true)
        }
    }

    @ViewBuilder
    private var otherSection: some View {
        VStack(spacing: .zero) {
            sectionHeader(T.Tokens.addManualOther)

            VStack(spacing: .zero) {
                navigationRow(
                    title: T.Browser.browserExtension,
                    accessory: .arrow,
                    isEnabled: presenter.isWebExtensionActive,
                    action: { presenter.handleBrowserExtension() }
                )
            }
            .groupedSectionBackground(isElevated: true)
        }
    }

    @ViewBuilder
    private var deleteSection: some View {
        VStack(spacing: .zero) {
            Button {
                presenter.handleAskForDeletition()
            } label: {
                Text(T.Tokens.moveToTrash)
                    .textStyle(.body)
                    .foregroundStyle(.accentsBrand)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, .L)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .groupedSectionBackground(isElevated: true)
        }
    }

    private enum Accessory {
        case arrow
        case text(String)
    }

    @ViewBuilder
    private func navigationRow(
        title: String,
        accessory: Accessory,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: .ML) {
                Text(title)
                    .textStyle(.body)
                    .foregroundStyle(isEnabled ? .labelsPrimary : .labelsTertiary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if case .text(let value) = accessory {
                    Text(value)
                        .textStyle(.body)
                        .foregroundStyle(.labelsSecondary)
                        .lineLimit(1)
                }

                Image(systemName: "chevron.right")
                    .textStyle(.footnote, .emphasized)
                    .foregroundStyle(.labelsTertiary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, .L)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }

    @ViewBuilder
    private func separator() -> some View {
        Divider()
            .foregroundStyle(.separatorsNonOpaque)
    }

    @ViewBuilder
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .textStyle(.headline)
            .foregroundStyle(.labelsSecondary)
            .accessibilityAddTraits(.isHeader)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, .ML)
            .padding(.horizontal, .XL)
    }

    private func gatedError(_ source: Binding<String?>, touched: Bool) -> Binding<String?> {
        Binding(
            get: { touched ? source.wrappedValue : nil },
            set: { source.wrappedValue = $0 }
        )
    }
}
