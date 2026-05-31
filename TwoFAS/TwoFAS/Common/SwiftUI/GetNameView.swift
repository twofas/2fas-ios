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

private struct GetNameView: View {
    let title: String
    let message: String?
    let placeholder: String
    let confirmTitle: String
    let cancelTitle: String
    let defaultText: String?
    let onConfirm: (String) -> Void
    let onCancel: (() -> Void)?
    let onVerify: (String) -> Bool
    
    @State
    private var text: String = ""
    
    @State
    private var isConfirmEnabled = false
    
    @State
    private var isFocused = false
    
    var body: some View {
        container
            .padding(.XL)
            .frame(maxWidth: 320)
            .modify(modifier: {
                if #available(iOS 26, *) {
                    $0.glassEffect(.regular, in: .rect(cornerRadius: TFCornerRadius.alert.rawValue))
                } else {
                    $0
                }
            })
            .onAppear {
                if let defaultText {
                    text = defaultText
                }
                isFocused = true
                isConfirmEnabled = text.isEmpty == false
            }
            .onChange(of: text) { _, _ in
                updateConfirmState()
            }
    }

    @ViewBuilder
    private var container: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: Spacing.XL.rawValue) {
                content
            }
        } else {
            VStack(spacing: .XL) {
                content
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: .M) {
            Text(title)
                .textStyle(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let message {
                Text(message)
                    .textStyle(.body)
                    .foregroundStyle(.labelsSecondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.M)

        TFFloatingTextField(
            placeHolder: placeholder,
            text: $text,
            inputType: .name,
            isFocused: $isFocused,
            submit: TFFormTextFieldSubmit(buttonType: .done, action: {
                onConfirmAction()
            })
        )
        .padding(.horizontal, .L)
        .background(AppColor.fillsTertiary, in: .rect(cornerRadius: TFCornerRadius.large.rawValue))

        HStack(spacing: .XL) {
            TFButton(cancelTitle, variant: .borderedSecondary, size: .largeWide) {
                onCancel?()
            }
            .frame(maxWidth: .infinity)

            TFButton(confirmTitle, variant: .borderedProminent, size: .largeWide) {
                onConfirmAction()
            }
            .disabled(!isConfirmEnabled)
            .frame(maxWidth: .infinity)
        }
    }
    
    private func onConfirmAction() {
        updateConfirmState()
        if isConfirmEnabled {
            onConfirm(text)
        }
    }
    
    private func updateConfirmState() {
        let verification = onVerify(text)
        isConfirmEnabled = verification
    }
}

private struct GetNameModifier: ViewModifier {
    @Binding
    var isPresented: Bool
    let title: String
    let message: String?
    let placeholder: String
    let confirmTitle: String
    let cancelTitle: String
    let defaultText: String?
    let onConfirm: (String) -> Void
    let onCancel: (() -> Void)?
    let onVerify: (String) -> Bool
    
    func body(content: Content) -> some View {
        content.overlay {
            ZStack {
                if isPresented {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { dismiss() }
                        .transition(.opacity)
                    
                    GetNameView(
                        title: title,
                        message: message,
                        placeholder: placeholder,
                        confirmTitle: confirmTitle,
                        cancelTitle: cancelTitle,
                        defaultText: defaultText,
                        onConfirm: { value in
                            dismiss()
                            onConfirm(value)
                        },
                        onCancel: {
                            dismiss()
                            onCancel?()
                        },
                        onVerify: onVerify
                    )
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
                }
            }
            .animation(.snappy(duration: 0.25), value: isPresented)
        }
    }
    
    private func dismiss() {
        withAnimation(.snappy(duration: 0.25)) { isPresented = false }
    }
}

extension View {
    func getName(
        _ isPresented: Binding<Bool>,
        title: String,
        message: String?,
        placeholder: String,
        defaultText: String? = nil,
        confirmTitle: String,
        cancelTitle: String = T.Commons.cancel,
        onConfirm: @escaping (String) -> Void,
        onCancel: (() -> Void)? = nil,
        onVerify: @escaping (String) -> Bool
    ) -> some View {
        modifier(GetNameModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            placeholder: placeholder,
            confirmTitle: confirmTitle,
            cancelTitle: cancelTitle,
            defaultText: defaultText,
            onConfirm: onConfirm,
            onCancel: onCancel,
            onVerify: onVerify
        ))
    }
}
