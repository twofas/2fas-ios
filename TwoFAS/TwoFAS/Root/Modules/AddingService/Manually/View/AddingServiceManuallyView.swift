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
    
    var body: some View {
        VStack {
            AddingServiceTitleView(text: T.Tokens.addManualTitle)
            
            ScrollView {
                AddingServiceTextContentView(text: T.Tokens.addManualDescription)
                
                HStack(spacing: 10) {
                    VStack {
                        AddingServiceSmallTitleView(text: T.Tokens.addManualServiceName)
                            .padding(.bottom, 10)
                        TextField("", text: $serviceName)
                            .onChange(of: serviceName) { newValue in
                                switch presenter.validateServiceName(newValue) {
                                case .correct:
                                    serviceNameError = nil
                                case .tooLong:
                                    serviceNameError = T.Commons.textLongTitle(ServiceRules.serviceNameMaxLength)
                                case .tooShort:
                                    serviceNameError = nil
                                }
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

//maxLength: ServiceRules.serviceNameMaxLength,
// T.Commons.textLongTitle(maxLength)

//let keyError: ComposeServiceSectionCell.PrivateKeyConfig.PrivateKeyError? = {
//    switch interactor.privateKeyError {
//    case .duplicated: return .duplicated
//    case .incorrect: return .incorrect
//    case .tooShort: return .tooShort
//    case .none, .empty: return nil
//    }
//}()
//
//extension ComposeServiceSectionCell.PrivateKeyConfig.PrivateKeyError {
//    var localizedStringValue: String {
//        switch self {
//        case .duplicated: return T.Tokens.duplicatedPrivateKey
//        case .incorrect: return T.Tokens.incorrectServiceKey
//        case .tooShort: return T.Tokens.serviceKeyToShort
//        }
//    }
//}
//


//---
//
//maxLength: ServiceRules.additionalInfoMaxLength,
//autocapitalizationType: UITextAutocapitalizationType.none
