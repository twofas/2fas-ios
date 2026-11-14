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
public struct TFInlineTextField<FocusValue: Hashable>: View {
    private let label: String
    private let placeholder: String
    private let submit: TFFormTextFieldSubmit?
    private let isInvalid: Bool
    private let isAutocorrectionEnabled: Bool

    @Environment(\.isEnabled)
    private var isEnabled
    @Environment(\.colorScheme)
    private var colorScheme
    @Binding
    private var text: String
    private let focused: FocusState<FocusValue?>.Binding
    private let focusValue: FocusValue
    @State
    private var clearTapped = false
    @State
    private var isPasswordRevealed = false

    private let inputType: TFTextInputType
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

    private var textColor: AppColor {
        if !isEnabled {
            return .labelsTertiary
        }
        if isInvalid && !text.isEmpty {
            return .accentsBrand
        }
        return .labelsPrimary
    }

    public init(
        label: String,
        placeholder: String,
        text: Binding<String>,
        inputType: TFTextInputType,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences,
        focused: FocusState<FocusValue?>.Binding,
        focusValue: FocusValue,
        isInvalid: Bool = false,
        isAutocorrectionEnabled: Bool = false,
        submit: TFFormTextFieldSubmit? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.inputType = inputType
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.focused = focused
        self.focusValue = focusValue
        self.isInvalid = isInvalid
        self.isAutocorrectionEnabled = isAutocorrectionEnabled
        self.submit = submit
    }

    public var body: some View {
        TFInlineRow(label: label) {
            HStack(alignment: .center, spacing: .M) {
                textField()
                trailingAccessory()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            requestFocus()
        }
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
        .modifier(TFTextInputFormatModifier(inputType))
        .foregroundStyle(textColor.color(for: colorScheme))
        .background(TFTextFieldColorSync(color: UIColor(textColor.color(for: colorScheme))))
        .accentColor(AppColor.accentsBrand.color(for: colorScheme))
        .keyboardType(keyboardType)
        .textStyle(.body)
        .textInputAutocapitalization(autocapitalization)
        .autocorrectionDisabled(!isAutocorrectionEnabled)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel(label)
        .submitLabel(submit?.buttonType ?? .return)
        .onSubmit {
            submit?.action?()
        }
        .onChange(of: showAsSecure) { _, _ in
            guard focused.wrappedValue == focusValue else { return }
            focused.wrappedValue = nil
            DispatchQueue.main.async {
                focused.wrappedValue = focusValue
            }
        }
    }

    @ViewBuilder
    private func trailingAccessory() -> some View {
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
                text = ""
            } label: {
                Image(icon: .xmarkCircleFill)
                    .resizable()
                    .frame(width: Size.mediumIconSize, height: Size.mediumIconSize)
                    .aspectRatio(contentMode: .fit)
                    .tint(.labelsTertiary)
            }
            .sensoryFeedback(.selection, trigger: clearTapped) { _, new in new }
        }
    }

    private var promptText: Text {
        Text(placeholder)
            .foregroundStyle(AppColor.labelsTertiary)
    }

    private func requestFocus() {
        guard isEnabled, focused.wrappedValue != focusValue else { return }
        focused.wrappedValue = focusValue
    }
}

public struct TFInlineRow<Content: View>: View {
    private let label: String
    private let content: Content

    @Environment(\.isEnabled)
    private var isEnabled
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize
    @Environment(\.tfInlineLabelWidth)
    private var labelWidth

    public init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    public var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: .XS) {
                    labelText()
                    content
                }
                .padding(.vertical, .M)
            } else {
                HStack(alignment: .center, spacing: .L) {
                    labelText()
                        .fixedSize()
                        .background {
                            GeometryReader { proxy in
                                Color.clear.preference(key: TFInlineLabelWidthKey.self, value: proxy.size.width)
                            }
                        }
                        .frame(width: labelWidth, alignment: .leading)

                    content
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: .normal)
    }

    @ViewBuilder
    private func labelText() -> some View {
        Text(label)
            .textStyle(.body)
            .foregroundStyle(isEnabled ? AppColor.labelsSecondary : AppColor.labelsTertiary)
            .accessibilityHidden(true)
    }
}

private struct TFTextFieldColorSync: UIViewRepresentable {
    let color: UIColor

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        let color = color
        DispatchQueue.main.async {
            guard let textField = uiView.nearestTextField() else { return }
            textField.textColor = color
            if textField.isEditing {
                textField.typingAttributes?[.foregroundColor] = color
            }
        }
    }
}

private extension UIView {
    func nearestTextField() -> UITextField? {
        guard let window else { return nil }
        let center = convert(CGPoint(x: bounds.midX, y: bounds.midY), to: window)
        var ancestor = superview
        var level = 0
        while let current = ancestor, level < 6 {
            let match = current.textFields().first { textField in
                textField.convert(textField.bounds, to: window).contains(center)
            }
            if let match {
                return match
            }
            ancestor = current.superview
            level += 1
        }
        return nil
    }

    func textFields() -> [UITextField] {
        subviews.flatMap { subview -> [UITextField] in
            if let textField = subview as? UITextField {
                return [textField]
            }
            return subview.textFields()
        }
    }
}

public struct TFInlineTextFieldSection<Content: View>: View {
    private let isElevated: Bool
    private let errors: [String?]
    private let content: Content

    private var hasErrors: Bool {
        errors.contains { $0 != nil }
    }

    public init(
        isElevated: Bool = false,
        errors: [String?] = [],
        @ViewBuilder content: () -> Content
    ) {
        self.isElevated = isElevated
        self.errors = errors
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            content
                .groupedSectionBackground(isElevated: isElevated)

            VStack(alignment: .leading, spacing: .S) {
                ForEach(errors.indices, id: \.self) { index in
                    if let error = errors[index] {
                        Text(error)
                            .textStyle(.caption2)
                            .foregroundStyle(.accentsBrand)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity)
                    }
                }
            }
            .padding(.horizontal, .XL)
            .padding(.top, hasErrors ? Spacing.M.rawValue : 0)
        }
        .animation(.easeInOut(duration: AnimationTiming.duration), value: errors)
    }
}

public extension View {
    func tfInlineLabelAlignment() -> some View {
        modifier(TFInlineLabelAlignmentModifier())
    }
}

private struct TFInlineLabelAlignmentModifier: ViewModifier {
    @State
    private var labelWidth: CGFloat?

    func body(content: Content) -> some View {
        content
            .environment(\.tfInlineLabelWidth, labelWidth)
            .onPreferenceChange(TFInlineLabelWidthKey.self) { width in
                labelWidth = width > 0 ? width : nil
            }
    }
}

private struct TFInlineLabelWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private extension EnvironmentValues {
    @Entry var tfInlineLabelWidth: CGFloat?
}

#Preview {
    TFInlineTextFieldPreview()
}

private struct TFInlineTextFieldPreview: View {
    enum Field: Hashable {
        case name
        case key
        case info
    }

    @State
    private var name = ""
    @State
    private var key = "ABC1"
    @State
    private var info = ""

    @FocusState
    private var focused: Field?

    var body: some View {
        VStack(spacing: .XXXL) {
            TFInlineTextFieldSection(isElevated: true, errors: ["Name is too short", "Key is incorrect"]) {
                VStack(spacing: .zero) {
                    TFInlineTextField(
                        label: "Service name",
                        placeholder: "Name",
                        text: $name,
                        inputType: .name,
                        focused: $focused,
                        focusValue: .name,
                        isInvalid: true
                    )
                    Divider()
                    TFInlineTextField(
                        label: "Secret Key",
                        placeholder: "Key",
                        text: $key,
                        inputType: .secret,
                        focused: $focused,
                        focusValue: .key,
                        isInvalid: true
                    )
                }
            }

            TFInlineTextFieldSection(isElevated: true) {
                TFInlineTextField(
                    label: "Additional info",
                    placeholder: "(optional)",
                    text: $info,
                    inputType: .other,
                    focused: $focused,
                    focusValue: .info
                )
            }
        }
        .tfInlineLabelAlignment()
        .padding()
    }
}
#endif
