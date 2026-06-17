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

#if os(iOS)
public struct TFFormTextFieldSubmit {
    let buttonType: SubmitLabel
    let action: (() -> Void)?

    public init(buttonType: SubmitLabel, action: (() -> Void)?) {
        self.buttonType = buttonType
        self.action = action
    }
}

public enum TFFloatingTextFieldInputType {
    case name
    case email
    case secret
    case other
}

public struct TFFloatingTextField<FocusValue: Hashable>: View {
    public typealias InputType = TFFloatingTextFieldInputType
    // MARK: - Variable
    private let textFieldHeight: CGFloat = Size.textFieldHeight
    private let placeHolderText: String
    private let submit: TFFormTextFieldSubmit?

    @Environment(\.isEnabled)
    private var isEnabled

    @Binding
    private var text: String
    private let focused: FocusState<FocusValue?>.Binding
    private let focusValue: FocusValue
    @Binding
    private var errorMessage: String?
    @State
    private var isEditing = false
    @State
    private var clearTapped = false
    @Environment(\.colorScheme)
    private var colorScheme

    private let inputType: InputType
    private let keyboardType: UIKeyboardType
    private let autocapitalization: TextInputAutocapitalization

    private var isFocused: Bool {
        focused.wrappedValue == focusValue
    }

    private var shouldPlaceHolderMove: Bool {
        isEditing || !text.isEmpty
    }

    // MARK: - init
    public init(
        placeHolder: String,
        text: Binding<String>,
        inputType: InputType,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences,
        focused: FocusState<FocusValue?>.Binding,
        focusValue: FocusValue,
        errorMessage: Binding<String?> = .constant(nil),
        submit: TFFormTextFieldSubmit? = nil
    ) {
        self.placeHolderText = placeHolder
        self._text = text
        self.inputType = inputType
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.focused = focused
        self.focusValue = focusValue
        _errorMessage = errorMessage
        self.submit = submit
    }

    public var body: some View {
        TFInputFloatingContainer(
            isEditing: $isEditing,
            movePlaceholderUp: Binding(get: { shouldPlaceHolderMove }, set: { _ in }),
            title: placeHolderText,
            errorMessage: $errorMessage
        ) {
            textField()
                .frame(maxWidth: .infinity)
        } trailingAccessory: {
            if shouldPlaceHolderMove && !text.isEmpty && isEnabled {
                Button {
                    clearTapped.toggle()
                    clearTextField()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: Size.mediumIconSize, height: Size.mediumIconSize)
                        .aspectRatio(contentMode: .fit)
                        .tint(.labelsTertiary)
                }
                .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.6), trigger: clearTapped) { _, new in new }
            }
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func textField() -> some View {
        TextField(
            "",
            text: $text,
            prompt: isEditing || (!isEnabled && !text.isEmpty) ? nil : Text(placeHolderText)
                .foregroundStyle(AppColor.labelsSecondary)
        )
        .focused(focused, equals: focusValue)
        .modifier(FormatInputModifier(inputType))
        .foregroundStyle(isEnabled ? .labelsPrimary : .labelsTertiary)
        .accentColor(AppColor.accentsBrand.color(for: colorScheme))
        .keyboardType(keyboardType)
        .textStyle(.body, .medium)
        .textInputAutocapitalization(autocapitalization)
        .animation(Animation.easeInOut(duration: AnimationTiming.duration), value: EdgeInsets())
        .frame(alignment: .leading)
        .accessibilityLabel(placeHolderText)
        .onChange(of: isFocused) { _, newValue in
            withAnimation {
                isEditing = newValue
            }
        }
        .submitLabel(submit?.buttonType ?? .return)
        .onSubmit {
            DispatchQueue.main.async {
                submit?.action?()
            }
        }
    }

    private func clearTextField() {
        text = ""
    }
}

private struct FormatInputModifier: ViewModifier {
    let inputType: TFFloatingTextFieldInputType

    init(_ inputType: TFFloatingTextFieldInputType) {
        self.inputType = inputType
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        switch inputType {
        case .email:
            content
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        case .name:
            content
                .keyboardType(.asciiCapable)
                .textContentType(.name)
                .textInputAutocapitalization(.words)
        case .secret:
            content
                .keyboardType(.alphabet)
                .textContentType(nil)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
        case .other:
            content
        }
    }
}

#Preview {
    Test()
}

private struct Test: View {
    @State
    private var text: String = "Test"

    @FocusState
    private var isFocused: Bool?

    @State
    private var errorMessage: String?// = "Błąd"

    var body: some View {
        VStack(spacing: .zero) {
            Divider()
            TFFloatingTextField(
                placeHolder: "Label",
                text: $text,
                inputType: .name,
                keyboardType: .asciiCapable,
                autocapitalization: .never,
                focused: $isFocused,
                focusValue: true,
                errorMessage: $errorMessage,
                submit: nil
            )
            Divider()
        }
    }
}
#endif
