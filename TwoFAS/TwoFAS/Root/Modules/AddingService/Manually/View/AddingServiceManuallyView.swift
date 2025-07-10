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
    @ObservedObject var presenter: AddingServiceManuallyPresenter
    var enableSave: (Bool) -> Void
    
    @FocusState private var focusedField: Field?
    private enum Field: Int, Hashable {
        case serviceName
        case secret
    }
    
    @State private var serviceName = ""
    @State private var serviceNameError: String?
    
    @State private var secret = ""
    @State private var secretError: String?
    
    @State private var additionalInfo = ""
    @State private var additionalInfoError: String?
    
    var body: some View {
        ScrollView(.vertical) {
            Group {
                AddingServiceTextContentView(text: T.Tokens.addManualDescription)
                    .padding(.vertical, 24)
                    .accessibilityAddTraits(.isHeader)
                
                VStack(spacing: 10) {
                    serviceNameBuilder()
                    serviceKeyBuilder()
                    
                    revealAdvancedBuilder()
                    
                    if presenter.advancedShown {
                        additionalInfoBuilder()
                        
                        AddServiceAdvancedWarningView()
                        
                        AddingServiceServiceTypeSelector(selectedTokenType: $presenter.selectedTokenType)
                            .padding(.vertical, Theme.Metrics.doubleMargin)
                        
                        if presenter.selectedTokenType != .steam {
                            advancedParametersBuilder()
                        }
                    }
                }
            }
            .onTapGesture {
                dismissKeyboard()
            }
            .padding(.horizontal, Theme.Metrics.doubleMargin)
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
        .onReceive(presenter.$isAddServiceEnabled, perform: { _ in
            enableSave(presenter.isAddServiceEnabled)
        })
    }
    
    @ViewBuilder
    func additionalInfoBuilder() -> some View {
        VStack {
            AddingServiceSmallTitleView(text: T.Tokens.additionalInfo)
                .padding(.top, 24)
                .padding(.bottom, 10)
                .accessibilityHidden(true)
            TextField("", text: $additionalInfo)
                .onChange(of: additionalInfo) { newValue in
                    additionalInfoError = presenter.validateAdditionalInfo(newValue).error
                }
                .textInputAutocapitalization(.never)
                .keyboardType(.alphabet)
                .autocorrectionDisabled(true)
                .submitLabel(.done)
                .onSubmit {
                    presenter.handleAddService()
                }
                .padding(.bottom, 5)
                .accessibilityLabel(T.Tokens.additionalInfo)
            AddingServiceTextFieldLineView()
        }
        .frame(maxWidth: .infinity)
        
        if let additionalInfoError {
            AddingServiceErrorTextView(text: additionalInfoError)
        }
    }
    
    @ViewBuilder
    func advancedParametersBuilder() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            switch presenter.selectedTokenType {
            case .totp:
                Button {
                    presenter.handleSelectAlgorithm()
                } label: {
                    advancedMenuPositionBuilder(
                        title: T.Tokens.algorithm,
                        value: presenter.selectedAlgorithm.rawValue
                    )
                }
                AddingServiceAdvancedSectionDividerView()
                Button {
                    presenter.handleSelectRefreshTime()
                } label: {
                    advancedMenuPositionBuilder(
                        title: T.Tokens.refreshTime,
                        value: T.Tokens.second(presenter.selectedRefreshTime.rawValue)
                    )
                }
                AddingServiceAdvancedSectionDividerView()
                Button {
                    presenter.handleSelectDigits()
                } label: {
                    advancedMenuPositionBuilder(
                        title: T.Tokens.numberOfDigits,
                        value: "\(presenter.selectedDigits.rawValue)"
                    )
                }
            case .steam:
                EmptyView()
            case .hotp:
                Button {
                    presenter.handleShowInitialCounterInput()
                } label: {
                    advancedMenuPositionBuilder(
                        title: T.Tokens.initialCounter,
                        value: "\(presenter.initialCounter)"
                    )
                }
                AddingServiceAdvancedSectionDividerView()
                Button {
                    presenter.handleSelectDigits()
                } label: {
                    advancedMenuPositionBuilder(
                        title: T.Tokens.numberOfDigits,
                        value: "\(presenter.selectedDigits.rawValue)"
                    )
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Metrics.modalCornerRadius)
                .strokeBorder(Color(Theme.Colors.Line.selectionBorder), lineWidth: 1)
        )
        .padding(.bottom, Theme.Metrics.doubleMargin)
    }
    
    @ViewBuilder
    func revealAdvancedBuilder() -> some View {
        AddingServiceAdvancedRevealView(isVisible: $presenter.advancedShown) {
            if focusedField != nil {
                dismissKeyboard()
                DispatchQueue.main.async {
                    presenter.advancedShown.toggle()
                }
            } else {
                presenter.advancedShown.toggle()
            }
        }
        .padding(.top, 24)
        .accessibilityAddTraits(.isButton)
    }
    
    @ViewBuilder
    func advancedMenuPositionBuilder(
        title: String,
        value: String,
        systemName: String = "chevron.right"
    ) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(Color(Theme.Colors.Text.main))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(value)
                .font(.body)
                .foregroundColor(Color(Theme.Colors.Text.inactive))
                .frame(alignment: .trailing)
            
            Image(systemName: systemName)
                .font(.body)
                .foregroundColor(Color(Theme.Colors.Text.inactive))
                .frame(alignment: .trailing)
                .padding(.leading, Theme.Metrics.halfSpacing)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, Theme.Metrics.standardSpacing)
        .padding(.vertical, Theme.Metrics.doubleSpacing)
        .accessibilityAddTraits(.isButton)
    }
    
    @ViewBuilder
    func serviceNameBuilder() -> some View {
        HStack(spacing: 10) {
            VStack {
                AddingServiceSmallTitleView(text: T.Tokens.addManualServiceName)
                    .padding(.bottom, 10)
                    .accessibilityHidden(true)
                TextField("", text: $serviceName)
                    .onChange(of: serviceName) { newValue in
                        serviceNameError = presenter.validateServiceName(newValue.trim()).error
                    }
                    .textInputAutocapitalization(.sentences)
                    .keyboardType(.alphabet)
                    .focused($focusedField, equals: .serviceName)
                    .autocorrectionDisabled(true)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .secret
                    }
                    .padding(.bottom, 5)
                    .onAppear {
                        serviceName = presenter.serviceName
                    }
                    .accessibilityLabel(T.Tokens.addManualServiceName)
                AddingServiceTextFieldLineView()
            }
            .frame(maxWidth: .infinity)
            AddingServiceServiceIconView(serviceImage: $presenter.serviceIcon)
                .accessibilityHidden(true)
        }
        if let serviceNameError {
            AddingServiceErrorTextView(text: serviceNameError)
        }
    }
    
    @ViewBuilder
    func serviceKeyBuilder() -> some View {
        VStack {
            AddingServiceSmallTitleView(text: T.Tokens.addManualServiceKey)
                .padding(.top, 24)
                .padding(.bottom, 10)
                .accessibilityHidden(true)
            TextField("", text: $secret)
                .onChange(of: secret) { newValue in
                    let trimmed = newValue.sanitazeSecret()
                    if trimmed != newValue {
                        secret = trimmed
                    }
                    secretError = presenter.validateSecret(trimmed).error
                }
                .textInputAutocapitalization(.characters)
                .keyboardType(.alphabet)
                .focused($focusedField, equals: .secret)
                .autocorrectionDisabled(true)
                .submitLabel(.done)
                .onSubmit {
                    presenter.handleAddService()
                }
                .padding(.bottom, 5)
                .accessibilityLabel(T.Tokens.addManualServiceKey)
            AddingServiceTextFieldLineView()
        }
        .frame(maxWidth: .infinity)
        
        if let secretError {
            AddingServiceErrorTextView(text: secretError)
        }
    }
    
    func dismissKeyboard() {
        guard let window = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let keyWindow = window.windows.first(where: { $0.isKeyWindow })
        else { return }
        keyWindow.endEditing(true)
    }
}
