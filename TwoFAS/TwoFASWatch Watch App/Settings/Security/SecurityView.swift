//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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
import CommonWatch

struct SecurityView: View {
    @Binding
    var path: NavigationPath
    
    @ObservedObject
    var presenter: SecurityPresenter
    
    var body: some View {
            List {
                if presenter.isPINset {
                    NavigationLink(value: SecurityPath.changePIN(.verify)) {
                        HStack {
                            Image(systemName: "lock.rotation")
                            Text(T.Security.changePin)
                        }
                    }

                    NavigationLink(value: SecurityPath.disablePIN(.verify)) {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text(T.Security.disablePin)
                        }
                    }
                } else {
                    NavigationLink(value: SecurityPath.setPIN(.selectLength)) {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text(T.Security.createPin)
                        }
                    }
                }
            }
            .navigationDestination(for: SecurityPath.self) { route in
                switch route {
                case .setPIN(let setPIN):
                    switch setPIN {
                    case .selectLength:
                        PINTypeView { PINType in
                            path.append(SecurityPath.setPIN(.enterPIN(PINType)))
                        }
                    case .enterPIN(let PINType):
                        PINKeyboardView(
                            presenter: .init(
                                interactor: InteractorFactory.shared.pinInteractor(variant: .enterNewPIN(PINType)
                        ), completion: { result in
                            switch result {
                            case .closed: path.removeLast(2)
                            case .entered(let appPIN): path.append(SecurityPath.setPIN(.verifyPIN(appPIN)))
                            default: break
                            }
                        }))
                    case .verifyPIN(let appPIN):
                        PINKeyboardView(
                            presenter: .init(
                                interactor: InteractorFactory.shared.pinInteractor(variant: .verifyPIN(appPIN)
                        ), completion: { result in
                            switch result {
                            case .closed: path.removeLast(3)
                            case .saved: path.append(SecurityPath.setPIN(.success))
                            default: break
                            }
                        }))
                    case .success:
                        SuccessView {
                            path.removeLast(4)
                        }
                    }
                case .disablePIN(let disablePIN):
                    switch disablePIN {
                    case .verify:
                        PINKeyboardView(
                            presenter: .init(
                                interactor: InteractorFactory.shared.pinInteractor(
                                    variant: .PINValidationWithClose), completion: { result in
                            switch result {
                            case .closed: path.removeLast()
                            case .verified: 
                                presenter.handleDisablePIN()
                                path.append(SecurityPath.disablePIN(.success))
                            default: break
                            }
                        }))
                    case .success:
                        SuccessView {
                            path.removeLast(2)
                        }
                    }
                case .changePIN(let changePIN):
                    switch changePIN {
                    case .verify:
                        PINKeyboardView(
                            presenter: .init(
                                interactor: InteractorFactory.shared.pinInteractor(
                                    variant: .PINValidationWithClose), completion: { result in
                            switch result {
                            case .closed: path.removeLast()
                            case .verified: path.append(SecurityPath.changePIN(.selectLength))
                            default: break
                            }
                        }))
                    case .selectLength:
                        PINTypeView(didSelect: { PINType in
                            path.append(SecurityPath.changePIN(.enterPIN(PINType)))
                        }, showClose: true) {
                            path.removeLast(2)
                        }
                    case .enterPIN(let PINType):
                        PINKeyboardView(presenter: .init(
                            interactor: InteractorFactory.shared.pinInteractor(
                                variant: .enterNewPIN(PINType)), completion: { result in
                            switch result {
                            case .closed: path.removeLast(3)
                            case .entered(let appPIN): path.append(SecurityPath.changePIN(.verifyPIN(appPIN)))
                            default: break
                            }
                        }))
                    case .verifyPIN(let appPIN):
                        PINKeyboardView(presenter: .init(
                            interactor: InteractorFactory.shared.pinInteractor(
                                variant: .verifyPIN(appPIN)), completion: { result in
                            switch result {
                            case .closed: path.removeLast(4)
                            case .saved: path.append(SecurityPath.changePIN(.success))
                            default: break
                            }
                        }))
                    case .success:
                        SuccessView {
                            path.removeLast(5)
                        }
                    }
                }
            }
        .onAppear {
            presenter.onAppear()
        }
        .containerBackground(.red.gradient, for: .navigation)
        .listStyle(.carousel)
        .environment(\.defaultMinListRowHeight, WatchConsts.minRowHeight)
        .navigationTitle(T.Settings.security)
        .navigationBarTitleDisplayMode(.automatic)
        .listItemTint(.clear)
    }
}
