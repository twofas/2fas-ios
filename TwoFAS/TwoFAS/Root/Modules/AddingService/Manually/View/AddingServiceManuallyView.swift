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
            
            ScrollView {
                AddingServiceTextContentView(text: T.Tokens.addManualDescription)
                    .padding(.bottom, 24)
                
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        VStack {
                            AddingServiceSmallTitleView(text: T.Tokens.addManualServiceName)
                                .padding(.bottom, 10)
                            TextField("", text: $serviceName)
                                .onChange(of: serviceName) { newValue in
                                    let trimmed = newValue.trim()
                                    if trimmed != newValue {
                                        serviceName = trimmed
                                    }
                                    let value = presenter.validateServiceName(trimmed)
                                    serviceNameError = value.error
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
                                let status = presenter.validateSecret(trimmed)
                                secretError = status.error
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
                        presenter.advancedShown.toggle()
                    }
                    .padding(.top, 24)
                    
                    if presenter.advancedShown {
                        VStack {
                            AddingServiceSmallTitleView(text: T.Tokens.additionalInfo)
                                .padding(.top, 24)
                                .padding(.bottom, 10)
                            TextField("", text: $additionalInfo)
                                .onChange(of: additionalInfo) { newValue in
                                    let status = presenter.validateAdditionalInfo(newValue)
                                    additionalInfoError = status.error
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
                        } else if presenter.selectedTokenType == .hotp {
                            Text("HOTP")
                        }
                    }
                }
            }
            
            AddingServiceDividerView()
                .padding(.bottom, 10)
            AddingServiceAddServiceButton(action: {
                presenter.handleAddService()
            }, isEnabled: $presenter.isAddServiceEnabled)
            .padding(.horizontal, 40)
            
            AddingServiceLinkButton(text: T.Tokens.addManualHelpCta) {
                presenter.handleHelp()
            }
        }
        .padding(.horizontal, Theme.Metrics.doubleMargin)
        .observeHeight(onChange: { height in
            changeHeight(height)
        })
    }
}
