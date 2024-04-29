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

@main
struct TwoFASWatch_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor var appDelegate: AppDelegateInteractor
    @State var locked = false
    @ObservedObject var presenter = AppPresenter(mainRepository: MainRepositoryImpl.shared)
    var body: some Scene {
        WindowGroup {
            if presenter.isAppLocked {
                NavigationStack {
                    PINKeyboardView(
                        presenter: PINKeyboardPresenter(
                            interactor: PINKeyboardInteractor(
                                mainRepository: MainRepositoryImpl.shared,
                                variant: .PINValidation), completion: { result in
                                    guard result == .verified else { return }
                                    presenter.unlockApp()
                                }
                        )
                    )
                }
                .transition(.opacity)
            } else {
                if presenter.showIntro {
                    IntroductionView {
                        presenter.markIntroAsShown()
                    }
                    .transition(.opacity)
                } else {
                    MainView(
                        presenter: MainPresenter(
                            interactor: InteractorFactory.shared.mainInteractor()
                        )
                    )
                    .containerBackground(.red.gradient, for: .navigation)
                }
            }
        }
        .onChange(of: WKApplication.shared().applicationState) { _, newValue in
            if newValue == .active {
                presenter.update()
            }
        }
    }
}
