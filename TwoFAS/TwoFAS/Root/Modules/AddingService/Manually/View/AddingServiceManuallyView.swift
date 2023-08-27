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
    let changeHeight: (CGFloat) -> Void
    
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
        VStack {
            AddingServiceTitleView(text: T.Tokens.addManualTitle)
            
            ScrollView(.vertical) {
                Group {
                    AddingServiceTextContentView(text: T.Tokens.addManualDescription)
                        .padding(.bottom, 24)
                    
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            VStack {
                                AddingServiceSmallTitleView(text: T.Tokens.addManualServiceName)
                                    .padding(.bottom, 10)
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
                                AddingServiceTextFieldLineView()
                            }
                            .frame(maxWidth: .infinity)
                            AddingServiceServiceIconView(serviceImage: $presenter.serviceIcon)
                        }
                        if let serviceNameError {
                            AddingServiceErrorTextView(text: serviceNameError)
                        }
                        
                        VStack {
                            AddingServiceSmallTitleView(text: T.Tokens.addManualServiceKey)
                                .padding(.top, 24)
                                .padding(.bottom, 10)
                            TextField("", text: $secret)
                                .onChange(of: secret) { newValue in
                                    let trimmed = newValue.removeWhitespaces()
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
                            AddingServiceTextFieldLineView()
                        }
                        .frame(maxWidth: .infinity)
                        
                        if let secretError {
                            AddingServiceErrorTextView(text: secretError)
                        }
                        
                        AddingServiceAdvancedRevealView(isVisible: $presenter.advancedShown) {
                            if let focusedField {
                                dismissKeyboard()
                                DispatchQueue.main.async {
                                    presenter.advancedShown.toggle()
                                }
                            } else {
                                presenter.advancedShown.toggle()
                            }
                        }
                        .padding(.top, 24)
                        
                        if presenter.advancedShown {
                            VStack {
                                AddingServiceSmallTitleView(text: T.Tokens.additionalInfo)
                                    .padding(.top, 24)
                                    .padding(.bottom, 10)
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
                                AddingServiceTextFieldLineView()
                            }
                            .frame(maxWidth: .infinity)
                             
                            if let additionalInfoError {
                                AddingServiceErrorTextView(text: additionalInfoError)
                            }
                            
                            AddServiceAdvancedWarningView()
                            
                            AddingServiceServiceTypeSelector(selectedTokenType: $presenter.selectedTokenType)
                            
                            if presenter.selectedTokenType == .totp {
                                Text("TOTP")
                                    .padding(.bottom, 1000)
                            } else if presenter.selectedTokenType == .hotp {
                                Text("HOTP")
                            }
                        }
                    }
                    
                    VStack {
                        AddingServiceDividerView()
                            .padding(.bottom, 10)
                        AddingServiceAddServiceButton(action: {
                            presenter.handleAddService()
                        }, isEnabled: $presenter.isAddServiceEnabled)
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                        
                        AddingServiceLinkButton(text: T.Tokens.addManualHelpCta) {
                            presenter.handleHelp()
                        }
                    }
                }
                .observeHeight(onChange: { contentHeight in
                    changeHeight(contentHeight)
                })
                .onTapGesture {
                    dismissKeyboard()
                }
                .padding(.horizontal, Theme.Metrics.doubleMargin)
            }
            .onAppear {
                DispatchQueue.main.async {
                    focusedField = .serviceName
                }
            }
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
