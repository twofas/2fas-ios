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
import CommonUI

struct PINLoginView: View {
    @Bindable
    var presenter: PINLoginPresenter
    
    @Environment(\.scenePhase)
    private var scenePhase
    
    @State
    private var aboutWindow = false
    
    var body: some View {
        VStack(spacing: .S) {
            Spacer()
                .containerRelativeFrame(.vertical) { length, _ in
                    length * 0.06
                }
            AdaptiveReadableContainer {
                PINWelcomeHeader(info: $presenter.info)
            }
            Spacer()
                .containerRelativeFrame(.vertical) { length, _ in
                    length * 0.04
                }
            
            PINDots(count: presenter.totalDigits, enteredCount: $presenter.enteredDigitCount)
                .disabled(presenter.isBlocked)
                .shake(on: presenter.shake)
            
            PINKeyboard(action: presenter.onKeyPressed)
                .focusable()
                .onKeyPress(keys: [
                    .delete,
                    .deleteForward,
                    .init("0"),
                    .init("1"),
                    .init("2"),
                    .init("3"),
                    .init("4"),
                    .init("5"),
                    .init("6"),
                    .init("7"),
                    .init("8"),
                    .init("9")
                ]) { press in
                    let lastKey = press.key
                    if lastKey == .delete || lastKey == .deleteForward {
                        presenter.onKeyPressed(.delete)
                        return .handled
                    } else if lastKey.character.isNumber, let value = Int(String(lastKey.character)) {
                        presenter.onKeyPressed(.digit(value))
                        return .handled
                    }
                    return .ignored
                }
                .disabled(presenter.isBlocked)
            
            Spacer()
            PINWelcomeFooter {
                aboutWindow = true
            }
        }
        .background(AppColor.backgroundsPrimary)
        .onAppear {
            presenter.onAppear()
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            guard oldValue != newValue else { return }
            if newValue == .active {
                presenter.onAppear()
            }
        }
        .sheet(isPresented: $aboutWindow) {
            AppReset()
        }
    }
}
