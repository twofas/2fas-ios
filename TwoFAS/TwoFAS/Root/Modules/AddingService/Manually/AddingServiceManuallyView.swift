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

struct AddingServiceManuallyView: View {
    @ObservedObject
    var presenter: AddingServiceManuallyPresenter

    @ObservedObject
    var router: AddingServiceManuallyRouter

    @FocusState
    private var focusedField: Field?
    private enum Field: Int, Hashable {
        case serviceName
        case secret
        case additionalInfo
    }

    @State
    private var touchedServiceName = false
    @State
    private var touchedSecret = false
    @State
    private var touchedAdditionalInfo = false

    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    AdaptiveReadableContainer {
                        VStack(spacing: .XXXL) {
                            iconRow()

                            mainFields()

                            additionalInfoField()

                            advancedSettingsRow()
                        }
                        .tfInlineLabelAlignment()
                    }
                }
                .dismissKeyboardOnTapOutside()
                .onChange(of: focusedField) { oldField, newField in
                    if let newField {
                        let centerField = {
                            withAnimation(.easeInOut(duration: Theme.Animations.Timing.keyboard)) {
                                proxy.scrollTo(newField, anchor: .center)
                            }
                        }
                        if oldField == nil {
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + Theme.Animations.Timing.keyboard,
                                execute: centerField
                            )
                        } else {
                            centerField()
                        }
                    }
                    switch oldField {
                    case .serviceName: touchedServiceName = true
                    case .secret: touchedSecret = true
                    case .additionalInfo: touchedAdditionalInfo = true
                    case nil: break
                    }
                }
                .onChange(of: presenter.serviceName) { _, _ in touchedServiceName = true }
                .onChange(of: presenter.secret) { _, _ in touchedSecret = true }
                .onChange(of: presenter.additionalInfo) { _, _ in touchedAdditionalInfo = true }
                .onTapGesture {
                    dismissKeyboard()
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    switch presenter.keyboardInitialFocus {
                    case .noFocus: break
                    case .name: focusedField = .serviceName
                    case .secret: focusedField = .secret
                    }
                    presenter.viewDidAppear()
                }
            }
            .navigationTitle(T.Tokens.addTitle)
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
                    TFSaveButton(T.Commons.pair, isEnabled: presenter.isAddServiceEnabled) {
                        presenter.handlePair()
                    }
                }
            }
            .background(.backgroundsPrimaryElevated)
            .navigationDestination(for: AddingServiceManuallyRoute.self) { route in
                router.destination(for: route)
            }
        }
    }

    @ViewBuilder
    private func advancedSettingsRow() -> some View {
        Button {
            dismissKeyboard()
            presenter.handleShowAdvancedSettings()
        } label: {
            TFRowContent(title: T.Tokens.addManualOtherSettings) {
                CheveronIcon()
            }
        }
        .buttonStyle(.plain)
        .groupedSectionBackground(isElevated: true)
    }
    
    @ViewBuilder
    private func iconRow() -> some View {
        VStack(spacing: .L) {
            ServiceIconPreview(icon: presenter.previewIcon)

            TFLiquidGlassTextButton(T.Tokens.editIcon) {
                dismissKeyboard()
                presenter.handleEditIcon()
            }
        }
        .padding(.top, .XL)
        .frame(maxWidth: .infinity)
    }

    private var serviceNameError: String? {
        touchedServiceName ? presenter.serviceNameError : nil
    }

    private var secretError: String? {
        touchedSecret ? presenter.secretError : nil
    }

    private var additionalInfoError: String? {
        touchedAdditionalInfo ? presenter.additionalInfoError : nil
    }

    @ViewBuilder
    private func mainFields() -> some View {
        VStack(spacing: .zero) {
            sectionHeader(T.Tokens.addManualDescription)

            TFInlineTextFieldSection(isElevated: true, errors: [serviceNameError, secretError]) {
                VStack(alignment: .leading, spacing: 0) {
                    TFInlineTextField(
                        label: T.Tokens.addManualServiceName,
                        placeholder: T.Tokens.addManualServiceNamePlaceholder,
                        text: $presenter.serviceName,
                        inputType: .name,
                        keyboardType: .asciiCapable,
                        focused: $focusedField,
                        focusValue: .serviceName,
                        isInvalid: serviceNameError != nil,
                        submit: .init(buttonType: .next, action: {
                            focusedField = .secret
                        })
                    )
                    .id(Field.serviceName)

                    separator()

                    TFInlineTextField(
                        label: T.Tokens.addManualServiceKey,
                        placeholder: T.Tokens.addManualServiceKeyPlaceholder,
                        text: $presenter.secret,
                        inputType: .secret,
                        keyboardType: .alphabet,
                        focused: $focusedField,
                        focusValue: .secret,
                        isInvalid: secretError != nil,
                        submit: .init(buttonType: .done, action: {
                            focusedField = nil
                            presenter.handleAddService()
                        })
                    )
                    .id(Field.secret)
                }
            }
        }
    }

    @ViewBuilder
    private func additionalInfoField() -> some View {
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
                    presenter.handleAddService()
                })
            )
            .id(Field.additionalInfo)
        }
    }

    @ViewBuilder
    private func separator() -> some View {
        Divider()
            .foregroundStyle(.separatorsNonOpaque)
            .padding(.trailing, -Spacing.XL.value)
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
