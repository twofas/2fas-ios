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
import Observation
import Common

/// Shared interface for the presenters backing a PIN-entry screen (create / verify PIN,
/// exporter, transfer verification). Provides everything `PINEntryScreen` needs to render.
protocol PINEntryPresenting: AnyObject, Observable {
    var info: String { get }
    var isError: Bool { get }
    var shake: Bool { get }
    var totalDigits: Int { get }
    var enteredDigitCount: Int { get set }
    /// Disables the dots and keyboard, e.g. while the input is locked after too many attempts.
    var isInputDisabled: Bool { get }
    func onKeyPressed(_ key: TFPinKey)
}

extension PINEntryPresenting {
    var isInputDisabled: Bool { false }
}

/// A reusable PIN-entry layout: info text, dots, keyboard and an optional footer.
///
/// This view is intentionally navigation-bar agnostic — it renders no title bar
/// and never touches the navigation bar. The hosting view (one level up) is
/// responsible for the chrome: setting a native `.navigationTitle` and any
/// leading button (Close/X) via `.toolbar` on its enclosing navigation stack.
struct PINEntryScreen<Presenter: PINEntryPresenting, Footer: View>: View {
    @Bindable private var presenter: Presenter
    private let onAppear: (() -> Void)?
    private let footer: () -> Footer

    init(
        presenter: Presenter,
        onAppear: (() -> Void)? = nil,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self._presenter = Bindable(wrappedValue: presenter)
        self.onAppear = onAppear
        self.footer = footer
    }

    var body: some View {
        VStack(spacing: .XL) {
            Text(presenter.info)
                .textStyle(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(presenter.isError ? AppColor.accentsBrand : AppColor.labelsSecondary)
                .animation(.easeInOut, value: presenter.info)
                .padding(.horizontal, .XL)

            Spacer()

            PINDots(count: presenter.totalDigits, enteredCount: $presenter.enteredDigitCount)
                .disabled(presenter.isInputDisabled)
                .shake(on: presenter.shake)
                .sensoryFeedback(.error, trigger: presenter.shake) { _, new in new }

            PINKeyboard(action: presenter.onKeyPressed)
                .disabled(presenter.isInputDisabled)

            Spacer()

            footer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.backgroundsPrimary)
        .onAppear { onAppear?() }
    }
}

extension PINEntryScreen where Footer == EmptyView {
    init(
        presenter: Presenter,
        onAppear: (() -> Void)? = nil
    ) {
        self.init(
            presenter: presenter,
            onAppear: onAppear,
            footer: { EmptyView() }
        )
    }
}
