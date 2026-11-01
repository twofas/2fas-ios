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
    @Bindable
    var presenter: ComposeServicePresenter

    @Bindable
    var router: ComposeServiceRouter

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
        NavigationStack(path: $router.path) {
            ScrollView {
                AdaptiveReadableContainer {
                    VStack(spacing: .XXXL) {
                        serviceInformationSection
                        additionalInfoSection
                        advancedSection
                        personalizationSection
                        if presenter.isBrowserExtensionAllowed {
                            otherSection
                        }
                        deleteSection
                    }
                    .tfInlineLabelAlignment()
                }
                .dismissKeyboardOnTapOutside()
            }
            .scrollDismissesKeyboard(.immediately)
            .background(.backgroundsPrimaryElevated)
            .navigationTitle(T.Commons.edit)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presenter.handleCancel()
                    } label: {
                        Image(icon: .xmark)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    TFSaveButton(T.Commons.save, isEnabled: presenter.isSaveEnabled) {
                        presenter.handleSave()
                    }
                }
            }
            .navigationDestination(for: ComposeServiceRoute.self) { route in
                router.destination(for: route)
            }
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
        }
    }

    private var serviceNameError: String? {
        touchedServiceName ? presenter.serviceNameError : nil
    }

    private var additionalInfoError: String? {
        touchedAdditionalInfo ? presenter.additionalInfoError : nil
    }

    @ViewBuilder
    private var serviceInformationSection: some View {
        VStack(spacing: .zero) {
            sectionHeader(T.Tokens.serviceInformation)

            TFInlineTextFieldSection(isElevated: true, errors: [serviceNameError]) {
                VStack(spacing: .zero) {
                    TFInlineTextField(
                        label: T.Tokens.serviceName,
                        placeholder: T.Tokens.addManualServiceNamePlaceholder,
                        text: $presenter.serviceName,
                        inputType: .name,
                        keyboardType: .asciiCapable,
                        focused: $focusedField,
                        focusValue: .serviceName,
                        isInvalid: serviceNameError != nil,
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
                        onReveal: { presenter.handleReveal() }
                    ) {
                        Button {
                            presenter.handleCopySecret()
                        } label: {
                            Label(T.Tokens.copySecret, icon: .docOnDoc)
                        }
                        Button {
                            presenter.handleCopyLink()
                        } label: {
                            Label(T.Tokens.copyLink, icon: .link)
                        }
                        Button {
                            presenter.handleShowQRCode()
                        } label: {
                            Label(T.Tokens.qrCodeShow, icon: .qrcode)
                        }
                        Button {
                            presenter.handleShareQRCode()
                        } label: {
                            Label(T.Tokens.qrCodeShare, icon: .squareAndArrowUp)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var additionalInfoSection: some View {
        TFInlineTextFieldSection(isElevated: true, errors: [additionalInfoError]) {
            TFInlineTextField(
                label: T.Tokens.additionalInfo,
                placeholder: T.Tokens.addManualOtherOptional,
                text: $presenter.additionalInfo,
                inputType: .other,
                keyboardType: .asciiCapable,
                focused: $focusedField,
                focusValue: .additionalInfo,
                isInvalid: additionalInfoError != nil,
                submit: .init(buttonType: .done, action: {
                    focusedField = nil
                })
            )
            .onChange(of: presenter.additionalInfo) { _, newValue in
                presenter.handleAdditionalInfoUpdate(newValue)
            }
        }
    }

    @ViewBuilder
    private var advancedSection: some View {
        navigationRow(
            title: T.Tokens.advanced,
            accessory: .arrow,
            isEnabled: true,
            action: { presenter.handleAdvanced() }
        )
        .groupedSectionBackground(isElevated: true)
    }

    @ViewBuilder
    private var personalizationSection: some View {
        VStack(spacing: .zero) {
            sectionHeader(T.Tokens.personalization)

            VStack(spacing: .zero) {
                changeIconRow

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
    private var changeIconRow: some View {
        Button {
            presenter.handleEditIcon()
        } label: {
            HStack(spacing: .M) {
                ServiceIconPreview(icon: presenter.iconDetails, dimension: changeIconDimension)

                Text(T.Tokens.changeIcon)
                    .textStyle(.body)
                    .foregroundStyle(.labelsPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(icon: .chevronRight)
                    .textStyle(.footnote, .emphasized)
                    .foregroundStyle(.labelsTertiary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, .ML)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var changeIconDimension: CGFloat { 44 }

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

                Image(icon: .chevronRight)
                    .textStyle(.footnote, .emphasized)
                    .foregroundStyle(.labelsTertiary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, .L)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .frame(minHeight: .normal)
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
}
