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

public struct TFFloatingTextField<FocusValue: Hashable>: View {
    public enum InputType {
        case name
        case email
        case secret
        case password
        case other
    }
    
    // MARK: - Variable
    private let textFieldHeight: CGFloat = TFRowHeight.list.value
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
    @State
    private var isPasswordRevealed = false
    @Environment(\.colorScheme)
    private var colorScheme

    private let inputType: InputType
    private let keyboardType: UIKeyboardType
    private let autocapitalization: TextInputAutocapitalization

    private var isFocused: Bool {
        focused.wrappedValue == focusValue
    }

    private var isSecure: Bool {
        inputType == .password
    }

    private var showAsSecure: Bool {
        isSecure && !isPasswordRevealed
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
            HStack(alignment: .center, spacing: .zero) {
                if isSecure {
                    if isEnabled {
                        Button {
                            isPasswordRevealed.toggle()
                        } label: {
                            Image(icon: isPasswordRevealed ? .eyeFill : .eyeSlashFill)
                                .textStyle(.body)
                                .tint(.labelsTertiary)
                        }
                    }
                } else if isFocused && !text.isEmpty && isEnabled {
                    Button {
                        clearTapped.toggle()
                        clearTextField()
                    } label: {
                        Image(icon: .xmarkCircleFill)
                            .resizable()
                            .frame(width: Size.mediumIconSize, height: Size.mediumIconSize)
                            .aspectRatio(contentMode: .fit)
                            .tint(.labelsTertiary)
                    }
                    .sensoryFeedback(
                        .impact(flexibility: .rigid, intensity: 0.6),
                        trigger: clearTapped) { _, new in new }
                }
            }
        }
        .contentShape(Rectangle())
        .frame(minHeight: .input)
        .onTapGesture {
            requestFocus()
        }
        .onChange(of: isEditing) { _, newValue in
            guard newValue else { return }
            requestFocus()
        }
    }

    private func requestFocus() {
        guard isEnabled, focused.wrappedValue != focusValue else { return }
        focused.wrappedValue = focusValue
    }

    @ViewBuilder
    private func textField() -> some View {
        ZStack {
            if showAsSecure {
                SecureField("", text: $text, prompt: promptText)
                    .focused(focused, equals: focusValue)
                    .textContentType(.password)
                    .transition(.opacity.animation(.easeInOut(duration: AnimationTiming.duration)))
            } else {
                TextField("", text: $text, prompt: promptText)
                    .focused(focused, equals: focusValue)
                    .transition(.opacity.animation(.easeInOut(duration: AnimationTiming.duration)))
            }
        }
        .modifier(FormatInputModifier(inputType))
        .foregroundStyle(isEnabled ? .labelsPrimary : .labelsTertiary)
        .accentColor(AppColor.accentsBrand.color(for: colorScheme))
        .keyboardType(keyboardType)
        .textStyle(.body, .medium)
        .textInputAutocapitalization(autocapitalization)
        .animation(Animation.easeInOut(duration: AnimationTiming.duration), value: EdgeInsets())
        .animation(Animation.easeInOut(duration: AnimationTiming.duration), value: focused.wrappedValue)
        .frame(alignment: .leading)
        .accessibilityLabel(placeHolderText)
        .submitLabel(submit?.buttonType ?? .return)
        .onSubmit {
            submit?.action?()
        }
        .onChange(of: focused.wrappedValue) { _, newValue in
            withAnimation {
                isEditing = newValue == focusValue
            }
        }
        .onChange(of: showAsSecure) { _, _ in
            guard focused.wrappedValue == focusValue else { return }
            focused.wrappedValue = nil
            DispatchQueue.main.async {
                focused.wrappedValue = focusValue
            }
        }
    }

    private var promptText: Text? {
        isEditing || (!isEnabled && !text.isEmpty) ? nil : Text(placeHolderText)
            .foregroundStyle(AppColor.labelsSecondary)
    }

    private func clearTextField() {
        text = ""
    }

    private struct FormatInputModifier: ViewModifier {
        let inputType: InputType

        init(_ inputType: InputType) {
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
            case .password:
                content
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            case .other:
                content
            }
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
    private var errorMessage: String? = "this is an error"

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
