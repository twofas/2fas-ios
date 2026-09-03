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

/// The shared centre of every PIN screen: a header, the dots and the keypad, with fixed gaps
/// that shrink when space is tight. Used by `PINEntryScreen` and `LoginView`.
///
/// The block claims a higher layout priority than its siblings, so a host can centre it
/// between plain `Spacer`s and it still keeps its natural height; inside, the keypad is
/// sized before the gaps so they compress first.
struct PINEntryBlock<Header: View>: View {
    let totalDigits: Int
    @Binding var enteredCount: Int
    let shake: Bool
    let isDisabled: Bool
    let onKeyPressed: (TFPinKey) -> Void
    /// Biometry key shown left of "0"; `nil` leaves that slot empty.
    var biometryKey: TFPinKey?
    @ViewBuilder let header: () -> Header

    var body: some View {
        VStack(spacing: .zero) {
            AdaptiveReadableContainer(verticalMargin: .zero) {
                header()
            }

            gap

            PINDots(count: totalDigits, enteredCount: $enteredCount)
                .disabled(isDisabled)
                .shake(on: shake)
                .sensoryFeedback(.error, trigger: shake)

            gap

            PINKeyboard(canDelete: enteredCount > 0, biometryKey: biometryKey, action: onKeyPressed)
                .disabled(isDisabled)
                .layoutPriority(1)
        }
        .layoutPriority(1)
    }

    private var gap: some View {
        Spacer(minLength: Spacing.M.value)
            .frame(maxHeight: Spacing.XXXXXXXL.value)
    }
}

/// A reusable PIN-entry layout: info text, dots, keyboard and an optional footer.
///
/// This view is intentionally navigation-bar agnostic — it renders no title bar
/// and never touches the navigation bar. The hosting view (one level up) is
/// responsible for the chrome: setting a native `.navigationTitle` and any
/// leading button (Close/X) via `.toolbar` on its enclosing navigation stack.
struct PINEntryScreen<Presenter: PINEntryPresenting, Footer: View>: View {
    @Bindable private var presenter: Presenter
    private let footer: () -> Footer

    init(
        presenter: Presenter,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self._presenter = Bindable(wrappedValue: presenter)
        self.footer = footer
    }

    private var hasFooter: Bool { Footer.self != EmptyView.self }

    var body: some View {
        VStack(spacing: .zero) {
            Spacer(minLength: 0)

            PINEntryBlock(
                totalDigits: presenter.totalDigits,
                enteredCount: $presenter.enteredDigitCount,
                shake: presenter.shake,
                isDisabled: presenter.isInputDisabled,
                onKeyPressed: presenter.onKeyPressed
            ) {
                Text(presenter.info)
                    .textStyle(.title2, .emphasized)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(presenter.isError ? AppColor.accentsBrand : AppColor.labelsPrimary)
                    .animation(.easeInOut, value: presenter.info)
            }

            Spacer(minLength: 0)

            if hasFooter {
                HStack(alignment: .center) {
                    footer()
                }
                .frame(minHeight: Spacing.XXXL.value)
                .padding(.top, .XL)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .minimumBottomSpacing()
        .background(AppColor.backgroundsPrimary)
    }
}

extension PINEntryScreen where Footer == EmptyView {
    init(
        presenter: Presenter
    ) {
        self.init(
            presenter: presenter,
            footer: { EmptyView() }
        )
    }
}

// MARK: - Preview

@Observable
private final class PreviewPINEntryPresenter: PINEntryPresenting {
    var info: String
    let isError: Bool
    let shake = false
    var totalDigits: Int
    var enteredDigitCount: Int
    var isInputDisabled: Bool

    init(
        info: String = T.Security.enterPinShort,
        isError: Bool = false,
        totalDigits: Int = 4,
        enteredDigitCount: Int = 0,
        isInputDisabled: Bool = false
    ) {
        self.info = info
        self.isError = isError
        self.totalDigits = totalDigits
        self.enteredDigitCount = enteredDigitCount
        self.isInputDisabled = isInputDisabled
    }

    func onKeyPressed(_ key: TFPinKey) {
        switch key {
        case .digit:
            enteredDigitCount = min(totalDigits, enteredDigitCount + 1)
        case .delete:
            enteredDigitCount = max(0, enteredDigitCount - 1)
        case .faceID, .touchID:
            break
        }
    }
}

#Preview("Default") {
    NavigationStack {
        PINEntryScreen(presenter: PreviewPINEntryPresenter())
            .navigationTitle("PIN")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("With footer, 6 digits") {
    NavigationStack {
        PINEntryScreen(presenter: PreviewPINEntryPresenter(totalDigits: 6, enteredDigitCount: 2)) {
            TFButton(T.Settings.selectPinLength, variant: .borderless, size: .small) {}
        }
        .navigationTitle("PIN")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Error") {
    PINEntryScreen(presenter: PreviewPINEntryPresenter(info: T.Security.pinErrorIncorrect, isError: true))
}

#Preview("Disabled") {
    PINEntryScreen(presenter: PreviewPINEntryPresenter(isInputDisabled: true))
}
