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

struct AddingServiceTokenView: View {
    @ObservedObject var presenter: AddingServiceTokenPresenter
    let dismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            MainScreenModalView(
                onClose: dismiss,
                title: T.Tokens.addSuccessTitle,
                subtitle: T.Tokens.addSuccessDescription
            ) {
                tokenView()
            } footer: {
                TFButton(T.Commons.done, variant: .borderedProminent, size: .large) {
                    dismiss()
                }
                TFButton(T.Tokens.copyTokenLong, variant: .borderless, size: .large) {
                    presenter.handleCopyCode()
                }
            }
            .padding(.ML)
        }
    }
    
    @ViewBuilder
    private func tokenView() -> some View {
        HStack(spacing: .L) {
            ServiceIconView(icon: presenter.serviceIcon)
            VStack(alignment: .leading, spacing: .SM) {
                AddingServiceTitleView(text: presenter.serviceName)
                AddingServiceTokenValueView(text: $presenter.token, willChangeSoon: $presenter.willChangeSoon)
            }
            
            switch presenter.serviceTokenType {
            case .steam, .totp:
                AddingServiceTOTPTimerView(
                    text: $presenter.time,
                    willChangeSoon: $presenter.willChangeSoon,
                    animationProgress: $presenter.part
                )
            case .hotp:
                AddingServiceHOTPView(
                    refreshTokenLocked: $presenter.refreshTokenLocked,
                    handleRefresh: presenter.handleRefresh
                )
            }
        }
        .padding(EdgeInsets(top: .XXL, leading: .XL, bottom: .XXL, trailing: .XL))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Metrics.modalCornerRadius)
                .inset(by: 0.5)
                .stroke(.bordersVibrant, lineWidth: 1)
        )
        .padding(.vertical, .XL)
    }
}

#Preview {
    AddingServiceTokenView(
        presenter: .init(
            flowController: AddingServiceTokenFlowController(viewController: UIViewController()),
            interactor: ModuleInteractorFactory
                .shared
                .addingServiceTokenModuleInteractor(
                    serviceData: .init(
                        name: "2FAS",
                        secret: "JBSWY3DPEHPK3PXP",
                        serviceTypeID: nil,
                        additionalInfo: "john@example.com",
                        rawIssuer: "2FAS",
                        modifiedAt: Date(),
                        createdAt: Date(),
                        tokenPeriod: .period30,
                        tokenLength: .digits6,
                        badgeColor: .default,
                        iconType: .brand,
                        iconTypeID: .default,
                        labelColor: .default,
                        labelTitle: "2F",
                        algorithm: .SHA1,
                        isTrashed: false,
                        trashingDate: nil,
                        counter: nil,
                        tokenType: .totp,
                        source: .manual,
                        otpAuth: nil,
                        order: 0,
                        sectionID: nil
                    )
                )
        ),
        dismiss: {}
    )
}
