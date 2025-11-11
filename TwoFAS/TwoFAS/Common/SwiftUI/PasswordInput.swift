//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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

struct PasswordInput: View {
    let label: LocalizedStringKey
    
    @State
    private var isReveal = false
    
    @Binding
    private var password: String
    
    private var bindingReveal: Binding<Bool>?
    private var isColorized = false
    private var onSubmit: (() -> Void)?
    
    init(
        label: LocalizedStringKey,
        password: Binding<String>,
        reveal: Binding<Bool>? = nil,
        onSubmit: (() -> Void)? = nil
    ) {
        self.label = label
        self.bindingReveal = reveal
        self._password = password
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        HStack {
            PasswordContentInput(label: label, password: $password, isReveal: isReveal)
                .colorized(isColorized)
                .onSubmit {
                    onSubmit?()
                }
            
            Spacer()
            
            Toggle(isOn: $isReveal, label: {})
                .toggleStyle(RevealToggleStyle())
                .frame(width: 22)
        }
        .onChange(of: isReveal) { newValue in
            if let bindingReveal, newValue != bindingReveal.wrappedValue {
                bindingReveal.wrappedValue = newValue
            }
        }
        .onChange(of: bindingReveal?.wrappedValue ?? false) { newValue in
            if newValue != isReveal {
                isReveal = newValue
            }
        }
    }
    
    func colorized(_ isColorized: Bool = true) -> Self {
        var instance = self
        instance.isColorized = isColorized
        return instance
    }
}

struct RevealToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.$isOn.wrappedValue.toggle()
        } label: {
            Image(systemName: configuration.isOn ? "eye.slash" : "eye")
                .foregroundStyle(Color(Theme.Colors.Icon.theme))
        }
    }
}

struct PasswordContentInput: View {
    
    private enum Field {
        case unsecure
        case secure
    }
    
    let label: LocalizedStringKey
    let isReveal: Bool
    
    @Binding
    var password: String
    
    @FocusState
    private var focusedField: Field?
    
    private var introspectTextField: (UITextField) -> Void = { _ in }
    private var isColorized = false
    
    init(label: LocalizedStringKey, password: Binding<String>, isReveal: Bool = false) {
        self.label = label
        self._password = password
        self.isReveal = isReveal
    }
    
    var body: some View {
        ZStack {
            SecureField(label, text: $password)
                .focused($focusedField, equals: .secure)
                .opacity(isReveal ? 0 : 1)
            
            SecureContainerView(contentId: password) {
                RevealedPasswordTextField(text: $password)
                    .focused($focusedField, equals: .unsecure)
                    .fontDesign(password.isEmpty ? .default : .monospaced)
            }
            .opacity(isReveal ? 1 : 0)
        }
        .animation(nil, value: isReveal)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .frame(maxWidth: .infinity)
        .onChange(of: isReveal) { newValue in
            if newValue, (focusedField == .secure || focusedField == nil) {
                Task {
                    focusedField = .unsecure
                }
            } else if focusedField == .unsecure || focusedField == nil {
                focusedField = .secure
            }
        }
    }
    
    func introspect(_ introspect: @escaping (UITextField) -> Void) -> Self {
        var instance = self
        instance.introspectTextField = introspect
        return instance
    }
    
    func colorized(_ isColorized: Bool) -> Self {
        var instance = self
        instance.isColorized = isColorized
        return instance
    }
}

private struct RevealedPasswordTextField: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartQuotesType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        
        textField.delegate = context.coordinator
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        
        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        uiView.font = UIFont.monospacedSystemFont(ofSize: bodyFont.pointSize, weight: .regular)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: RevealedPasswordTextField
        
        init(_ parent: RevealedPasswordTextField) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}

struct SecureContainerView<ID: Hashable, Content: View>: View {
    
    let contentId: ID
    @ViewBuilder var content: (ID) -> Content
    
    var body: some View {
        _SecureContainerView(contentId: contentId, content: content)
    }
}

extension SecureContainerView {
    
    init(contentId: ID, @ViewBuilder content: @escaping () -> Content) {
        self.contentId = contentId
        self.content = { _ in content() }
    }
}

extension SecureContainerView where ID == UUID {
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.contentId = UUID()
        self.content = { _ in content() }
    }
}

private struct _SecureContainerView<ID: Hashable, Content: View>: UIViewRepresentable {
    
    let contentId: ID
    @ViewBuilder var content: (ID) -> Content
    
    func makeUIView(context: Context) -> UIView {
        let secureEntryTextField = UITextField()
        secureEntryTextField.isSecureTextEntry = true
        secureEntryTextField.isUserInteractionEnabled = false
        
        guard let container = secureEntryTextField.layer.sublayers?.first?.delegate as? UIView else {
            return UIView()
        }
        
        clearContainer(container)
        context.coordinator.hosting = embedContent(in: container)
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.hosting?.rootView = content(contentId)
    }
    
    private func clearContainer(_ container: UIView) {
        container.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
    
    private func embedContent(in container: UIView) -> UIHostingController<Content> {
        let contentHostingController = UIHostingController(rootView: content(contentId))
        contentHostingController.view.backgroundColor = .clear
        
        container.addSubview(contentHostingController.view)
        contentHostingController.view.pinToParent()
        
        return contentHostingController
    }
    
    func makeCoordinator() -> Coordinator {
        .init()
    }
    
    class Coordinator {
        fileprivate var hosting: UIHostingController<Content>?
    }
}

private enum Constants {
    static let focusedPlaceholderScale: CGFloat = 0.7
    static let focusedPlaceholderVerticalOffset: CGFloat = -10
}

struct FloatingField<Label>: View where Label: View {
    
    let placeholder: Text
    @Binding
    var isEmpty: Bool
    @Binding
    var isFocused: Bool
    let focusOnField: Callback
    
    @ViewBuilder var label: () -> Label
        
    var body: some View {
        ZStack(alignment: .leading) {
            placeholder
                .foregroundStyle(Color(Theme.Colors.Text.inactive))
                .scaleEffect(
                    isFocused || isEmpty == false ? Constants.focusedPlaceholderScale : 1,
                    anchor: .topLeading
                )
                .offset(y: isFocused || isEmpty == false ? Constants.focusedPlaceholderVerticalOffset : 0)
                .animation(.default, value: isFocused)
                .onTapGesture {
                    if !isFocused {
                        focusOnField()
                    }
                }
            
            label()
                .padding(.top, 20)
        }
    }
}
