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

struct PasswordTextField: View {
    // MARK: - Variable
    private let title: String
    private let isPasswordNew: Bool
    private let prompt: String?
    
    @Binding
    private var text: String
    @Binding
    private var isFocused: Bool
    @State
    private var isEditing = false
    @State
    private var reveal = false
    @FocusState
    private var isSecureFieldFocused: Bool
    @FocusState
    private var isPlainFieldFocused: Bool
    
    // MARK: - init
    init(
        title: String,
        text: Binding<String>,
        isPasswordNew: Bool = true,
        prompt: String? = nil,
        isFocused: Binding<Bool> = .constant(false)
    ) {
        self.title = title
        self._text = text
        self.isPasswordNew = isPasswordNew
        self.prompt = prompt
        _isFocused = isFocused
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            HStack {
                if reveal {
                    textField()
                } else {
                    secureTextField()
                }
                
                icon()
            }
            .padding(0)
            .clipShape(Rectangle())
            placeholder()
        }
        .frame(height: 40)
        .animation(.easeInOut(duration: 0.3), value: reveal)
    }
    
    @ViewBuilder
    private func textField() -> some View {
        TextField(isEditing ? "" : title, text: $text, onEditingChanged: { edit in
            isFocused = edit
            withAnimation {
                isEditing = edit
            }
        })
        .focused($isPlainFieldFocused)
        .modifier(FormatInputModifier(isPasswordNew: isPasswordNew))
    }
    
    @ViewBuilder
    private func secureTextField() -> some View {
        SecureField(title, text: $text, prompt: prompt != nil ? promptText(prompt: prompt!) : nil)
            .modifier(FormatInputModifier(isPasswordNew: isPasswordNew))
            .focused($isSecureFieldFocused)
            .onChange(of: isSecureFieldFocused) { focused in
                isFocused = focused
                withAnimation {
                    isEditing = focused
                }
            }
    }
    
    @ViewBuilder
    private func promptText(prompt: String) -> Text {
        Text(verbatim: prompt)
            .bold()
    }
    
    @ViewBuilder
    private func icon() -> some View {
        Button {
            withAnimation {
                reveal.toggle()
                if isEditing {
                    if reveal {
                        isPlainFieldFocused = true
                    } else {
                        isSecureFieldFocused = true
                    }
                }
            }
        } label: {
            Image(systemName: reveal ? "eye.slash" : "eye")
                .foregroundColor(Color(Theme.Colors.Icon.theme))
                .padding(.leading, Theme.Metrics.standardMargin)
        }
    }
    
    @ViewBuilder
    private func placeholder() -> some View {
        Text(!isEditing && reveal && text.isEmpty ? " " + title + " " : "")
            .foregroundColor(Color.secondary)
            .background(Color(UIColor.systemBackground))
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
    }
}

private struct FormatInputModifier: ViewModifier {
    let isPasswordNew: Bool
    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .keyboardType(.asciiCapable)
            .textContentType(isPasswordNew ? .newPassword : .password)
            .accentColor(Color(Theme.Colors.Text.theme))
            .animation(Animation.easeInOut(duration: 0.4), value: EdgeInsets())
            .frame(alignment: .leading)
    }
}

#Preview {
    PasswordTextField(
        title: "Enter password",
        text: Binding(get: { "1234" }, set: { _ in }),
        prompt: "8 chars min"
    )
    .padding(Theme.Metrics.standardMargin)
}
