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

public extension View {
    @ViewBuilder
    func toast(
        _ text: Text,
        isPresented: Binding<Bool>,
        style: ToastStyle,
        icon: Image? = nil,
        sensoryFeedback: @escaping SensoryFeedbackConfiguration = { $0 }
    ) -> some View {
        modifier(
            ToastPresenterViewModifier(
                text: text,
                isPresented: isPresented,
                style: style,
                icon: icon,
                sensoryFeedback: sensoryFeedback
            )
        )
    }
    
    @ViewBuilder
    func toast(
        _ text: LocalizedStringResource,
        isPresented: Binding<Bool>,
        style: ToastStyle,
        icon: Image? = nil,
        sensoryFeedback: @escaping SensoryFeedbackConfiguration = { $0 }
    ) -> some View {
        toast(Text(text), isPresented: isPresented, style: style, icon: icon, sensoryFeedback: sensoryFeedback)
    }
}

public final class ToastPresenter {
    public static let shared = ToastPresenter()
    
    private let window = UIWindow()
    
    private var preseted: [UUID: ToastPresentationController] = [:]
    
    /// Window level for the toast overlay. Defaults to `.alert` (system value).
    /// The app can override this so the toast sits below its cover / login windows.
    public var windowLevel: UIWindow.Level = .alert {
        didSet { window.windowLevel = windowLevel }
    }
    
    @discardableResult
    func present(
        _ text: Text,
        style: ToastStyle,
        icon: Image? = nil,
        sensoryFeedback: @escaping SensoryFeedbackConfiguration = { $0 },
        onDismiss: @escaping Callback = {}
    ) -> UUID {
        let id = UUID()
        let controller = ToastPresentationController(id: id, onDismiss: {
            self.preseted[id] = nil
            
            if self.preseted.isEmpty {
                self.window.rootViewController = nil
                self.window.isHidden = true
            }
            
            onDismiss()
        })
        preseted[id] = controller
        
        let toastView = ToastPresenterView(
            toast: ToastContentView(text: text, style: style, icon: icon),
            controller: controller
        )
            .sensoryFeedbackConfiguration(sensoryFeedback)
        
        let toastViewController = UIHostingController(rootView: toastView)
        toastViewController.view.backgroundColor = .clear
        
        window.windowScene = UIApplication.shared.activeWindowScene
        let containerBounds = window.windowScene?.coordinateSpace.bounds
            ?? window.windowScene?.screen.bounds
            ?? .zero
        let toastSize = toastViewController.sizeThatFits(in: containerBounds.size)
        window.frame = CGRect(x: 0, y: 0, width: toastSize.width, height: toastSize.height)
        window.center.x = containerBounds.width / 2.0
        window.windowLevel = windowLevel
        
        window.rootViewController = toastViewController
        window.isHidden = false
        window.backgroundColor = .clear
        
        return id
    }
    
    public func dismiss(id: UUID) {
        guard let controller = preseted[id] else { return }
        controller.hide()
    }
    
    public func dismissAll(animated: Bool) {
        if animated {
            for controller in preseted.values {
                controller.hide()
            }
        } else {
            self.preseted = [:]
            self.window.rootViewController = nil
            self.window.isHidden = true
        }
    }
}

public extension ToastPresenter {
    func present(
        _ text: LocalizedStringResource,
        style: ToastStyle,
        icon: UIImage? = nil,
        sensoryFeedback: @escaping SensoryFeedbackConfiguration = { $0 },
        onDismiss: @escaping Callback = {}
    ) {
        self.present(
            Text(text),
            style: style,
            icon: icon.map(Image.init),
            sensoryFeedback: sensoryFeedback,
            onDismiss: onDismiss
        )
    }
    
    func present(
        _ text: String,
        style: ToastStyle,
        icon: UIImage? = nil,
        sensoryFeedback: @escaping SensoryFeedbackConfiguration = { $0 },
        onDismiss: @escaping Callback = {}
    ) {
        self.present(
            Text(text),
            style: style,
            icon: icon.map(Image.init),
            sensoryFeedback: sensoryFeedback,
            onDismiss: onDismiss
        )
    }
}

private struct ToastPresenterViewModifier: ViewModifier {
    let text: Text
    let isPresented: Binding<Bool>
    let style: ToastStyle
    let icon: Image?
    let sensoryFeedback: SensoryFeedbackConfiguration
    
    @State private var toastId: UUID?
    
    @Environment(\.toastPresenter)
    private var toastPresenter
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented.wrappedValue) { _, newValue in
                if newValue {
                    toastId = toastPresenter.present(
                        text,
                        style: style,
                        icon: icon,
                        sensoryFeedback: sensoryFeedback,
                        onDismiss: {
                            isPresented.wrappedValue = false
                        })
                } else if let toastId {
                    toastPresenter.dismiss(id: toastId)
                }
            }
    }
}

public extension EnvironmentValues {
    var toastPresenter: ToastPresenter {
        get {
            self[ToastPresenterEnvironmentKey.self]
        } set {
            self[ToastPresenterEnvironmentKey.self] = newValue
        }
    }
}

private struct ToastPresenterEnvironmentKey: EnvironmentKey {
    static let defaultValue: ToastPresenter = .shared
}

private extension UIApplication {
    var activeWindowScene: UIWindowScene? {
        connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        ?? connectedScenes.first as? UIWindowScene
    }
}
