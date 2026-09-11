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

private enum Constants {
    static let sourceSize = CGSize(width: 60, height: 10)
    static let autohideDelay = Duration.seconds(2)
    static let sensoryFeedbackDelay = Duration.milliseconds(100)
    
    static let topPadding: CGFloat = 32
    
    static let presentAnimationDuration = 0.5
    static let dismissAnimationDuration = 0.4
    static let opacityAnimationDuration = 0.2
}

public typealias SensoryFeedbackConfiguration = (SensoryFeedback?) -> SensoryFeedback?

@Observable
public final class ToastPresentationController {
    public let id: UUID
    
    var toastSize = CGSize.zero
    
    private(set) var isPresented: Bool = false
    private(set) var scale = CGSize(width: 1, height: 1)
    
    private let _onDismiss: Callback?
    
    init(id: UUID, onDismiss: @escaping Callback) {
        self.id = id
        self._onDismiss = onDismiss
    }
    
    func onAppear() {
        var transaciton = Transaction()
        transaciton.disablesAnimations = true
        withTransaction(transaciton) {
            scale = sourceScale
        }
        
        isPresented = true
        scale = CGSize(width: 1, height: 1)
        
        Task {
            try await Task.sleep(for: Constants.autohideDelay)
            hide()
        }
    }
    
    func hide() {
        withAnimation {
            isPresented = false
            scale = sourceScale
        } completion: {
            self._onDismiss?()
        }
    }
    
    private var sourceScale: CGSize {
        CGSize(
            width: min(1, Constants.sourceSize.width / toastSize.width),
            height: min(1, Constants.sourceSize.height / toastSize.height)
        )
    }
}

public struct ToastPresenterView: View {
    @State
    private var sensoryFeedback: Bool = false
    
    private var sensoryFeedbackConfiguration: SensoryFeedbackConfiguration
    
    let toast: ToastContentView
    
    @State
    var controller: ToastPresentationController
    
    public init(toast: ToastContentView, controller: ToastPresentationController) {
        self.toast = toast
        self.controller = controller
        self.sensoryFeedbackConfiguration = { $0 }
    }
    
    public var body: some View {
        VStack {
            toastWithBackground
                .onGeometryChange(
                    for: CGSize.self,
                    of: { proxy in
                        proxy.size
                    }, action: { newValue in
                        controller.toastSize = newValue
                    })
                .padding(.top, Constants.topPadding)
                .scaleEffect(controller.scale)
                .offset(y: controller.isPresented ? 0 : -controller.toastSize.height)
                .animation(
                    .smooth(
                        duration: controller.isPresented ?
                        Constants.presentAnimationDuration :
                            Constants.dismissAnimationDuration
                    ),
                    value: controller.scale
                )
                .animation(
                    .smooth(
                        duration: controller.isPresented ?
                        Constants.presentAnimationDuration :
                            Constants.dismissAnimationDuration
                    ),
                    value: controller.isPresented
                )
                .opacity(controller.isPresented ? 1 : 0)
                .animation(.easeInOut(duration: Constants.opacityAnimationDuration), value: controller.isPresented)
        }
        .onChange(of: controller.isPresented, { _, newValue in
            guard newValue else {
                return
            }
            Task {
                try await Task.sleep(for: Constants.sensoryFeedbackDelay)
                sensoryFeedback = true
            }
        })
        .sensoryFeedback(trigger: sensoryFeedback, { _, _ in
            let proposal: SensoryFeedback? = {
                switch toast.style {
                case .success: return .success
                case .failure: return .error
                case .warning: return .warning
                case .info: return .impact
                }
            }()
            return sensoryFeedbackConfiguration(proposal)
        })
        .onAppear {
            controller.onAppear()
        }
    }
    
    @ViewBuilder
    private var toastWithBackground: some View {
        if #available(iOS 26.0, *) {
            toast
                .glassEffect(in: .capsule)
        } else {
            toast
                .background(
                    ZStack {
                        Capsule()
                            .fill(AppColor.backgroundsPrimaryElevated)
                            .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: 20)
                            .shadow(color:
                                        Color(
                                            red: 0.15,
                                            green: 0.15,
                                            blue: 0.15
                                        )
                                            .opacity(0.69),
                                    radius: 0,
                                    x: 0,
                                    y: 0
                            )
                            .opacity(controller.isPresented ? 1 : 0)

                        Capsule()
                            .fill(AppColor.backgroundsPrimaryElevated)
                    }
                )
        }
    }

    func sensoryFeedbackConfiguration(_ configuration: @escaping SensoryFeedbackConfiguration) -> Self {
        var instance = self
        instance.sensoryFeedbackConfiguration = configuration
        return instance
    }
}
