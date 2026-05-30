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
import Common

public struct TFFormTextFieldSubmit {
    let buttonType: SubmitLabel
    let action: Callback?
}

public struct TFFloatingTextField: View {
    public enum InputType {
        case name
        case email
        case other
    }
    // MARK: - Variable
    private let textFieldHeight: CGFloat = Size.textFieldHeight
    private let placeHolderText: String
    private let submit: TFFormTextFieldSubmit?
    
    @Environment(\.isEnabled)
    private var isEnabled
    
    @Binding
    private var text: String
    @Binding
    private var isFocused: Bool
    @Binding
    private var errorMessage: String?
    @State
    private var isEditing = false
    
    @FocusState
    private var textFieldInFocus: Bool
    
    private let inputType: InputType
    private let keyboardType: UIKeyboardType
    private let autocapitalization: TextInputAutocapitalization
    
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
        isFocused: Binding<Bool> = .constant(false),
        errorMessage: Binding<String?> = .constant(nil),
        submit: TFFormTextFieldSubmit? = nil
    ) {
        self.placeHolderText = placeHolder
        self._text = text
        self.inputType = inputType
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        _isFocused = isFocused
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
                    clearTextField()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: Size.mediumIconSize, height: Size.mediumIconSize)
                        .aspectRatio(contentMode: .fit)
                        .tint(.labelsTertiary)
                }
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
        .focused($textFieldInFocus)
        .modifier(FormatInputModifier(inputType))
        .foregroundStyle(isEnabled ? .labelsPrimary : .labelsTertiary)
        .accentColor(.accentColor)
        .keyboardType(keyboardType)
        .textStyle(.body, .medium)
        .textInputAutocapitalization(autocapitalization)
        .animation(Animation.easeInOut(duration: AnimationTiming.duration), value: EdgeInsets())
        .frame(alignment: .leading)
        .onChange(of: textFieldInFocus) { _, newValue in
            if isFocused != newValue {
                isFocused = newValue
            }
            withAnimation {
                isEditing = newValue
            }
        }
        .onChange(of: isFocused) { _, newValue in
            guard textFieldInFocus != newValue else { return }
            textFieldInFocus = newValue
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
    let inputType: TFFloatingTextField.InputType
    
    init(_ inputType: TFFloatingTextField.InputType) {
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
    
    @State
    private var isFocused = false
    
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
                isFocused: $isFocused,
                errorMessage: $errorMessage,
                submit: nil
            )
            Divider()
        }
    }
}
