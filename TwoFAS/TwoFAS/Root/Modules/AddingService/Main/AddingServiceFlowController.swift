//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
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
import Data

protocol AddingServiceFlowControllerParent: AnyObject {
    func addingServiceDismiss()
    func addingServiceToGoogleAuthSummary(importable: Int, total: Int, codes: [Code])
    func addingServiceToLastPassSummary(importable: Int, total: Int, codes: [Code])
    func addingServiceToSendLogs(auditID: UUID)
    func addingServiceToPushPermissions(for extensionID: Common.ExtensionID)
    func addingServiceToTwoFASWebExtensionPairing(for extensionID: Common.ExtensionID)
    func addingServiceToToken(_ serviceData: ServiceData)
    func addingServiceGalleryDidImport(count: Int)
}

protocol AddingServiceFlowControlling: AnyObject {
    func toToken(serviceData: ServiceData)
    func close()
    func toAddManually()
    func toAppSettings()
    func toGuides()
    
    func toGoogleAuthSummary(importable: Int, total: Int, codes: [Code])
    func toLastPassSummary(importable: Int, total: Int, codes: [Code])
    func toGallery()
    func toTwoFASWebExtensionPairing(for extensionID: ExtensionID)
    func toSendLogs(auditID: UUID)
    func toPushPermissions(for extensionID: ExtensionID)
}

final class AddingServiceFlowController: FlowController {
    private weak var parent: AddingServiceFlowControllerParent?
    private var zoomTransitioningDelegate: ZoomFromRectTransitioningDelegate?

    static func isPresented(on viewController: UIViewController) -> Bool {
        viewController.presentedViewController is UIHostingController<AddServiceHostingView>
    }

    static func present(
        on viewController: UIViewController,
        parent: AddingServiceFlowControllerParent
    ) {
        let box = FlowControllerBox()

        let rootView = AddServiceHostingView(flowController: box, onFullyDismissed: { [weak parent] in
            parent?.addingServiceDismiss()
        })

        let hosting = UIHostingController(rootView: rootView)

        hosting.view.backgroundColor = .clear
        // Keep the presenting VC in the hierarchy so the background shows through.
        hosting.modalPresentationStyle = .overFullScreen
        hosting.isModalInPresentation = true
        hosting.definesPresentationContext = true
        // Prevents UIKit from snapshotting the full focus environment on present(),
        // which blocks the main thread for several seconds on large token lists.
        hosting.restoresFocusAfterTransition = false

        let sourceView = zoomSourceView(in: viewController)
        let zoomDelegate = ZoomFromRectTransitioningDelegate(sourceProvider: { [weak sourceView] in sourceView })
        hosting.transitioningDelegate = zoomDelegate

        let flowController = AddingServiceFlowController(viewController: hosting)
        flowController.parent = parent
        flowController.zoomTransitioningDelegate = zoomDelegate
        box.flowController = flowController

        viewController.present(hosting, animated: true)
    }

    private static let zoomSourceTag = 0xADD5_E70C

    private static func zoomSourceView(in viewController: UIViewController) -> UIView {
        if let existing = viewController.view.viewWithTag(zoomSourceTag) {
            return existing
        }

        let marker = UIView()
        marker.tag = zoomSourceTag
        marker.backgroundColor = .clear
        marker.isUserInteractionEnabled = false
        marker.isAccessibilityElement = false
        marker.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(marker)

        let topInset = viewController.view.safeAreaInsets.top
        let hasDynamicIsland = topInset >= 51

        if hasDynamicIsland {
            // Dynamic Island: ~124×37
            // Bottom marker = safeAreaTop - 4
            NSLayoutConstraint.activate([
                marker.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
                marker.widthAnchor.constraint(equalToConstant: 124),
                marker.heightAnchor.constraint(equalToConstant: 37),
                marker.bottomAnchor.constraint(equalTo: viewController.view.topAnchor, constant: topInset - 4)
            ])
        } else {
            NSLayoutConstraint.activate([
                marker.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
                marker.topAnchor.constraint(equalTo: viewController.view.topAnchor),
                marker.widthAnchor.constraint(equalToConstant: 1),
                marker.heightAnchor.constraint(equalToConstant: 1)
            ])
        }

        return marker
    }
}

private final class FlowControllerBox {
    var flowController: AddingServiceFlowControlling?
}

private struct AddServiceHostingView: View {
    let flowController: FlowControllerBox
    let onFullyDismissed: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture(perform: onFullyDismissed)

            if let flowController = flowController.flowController {
                AddingServiceView(
                    presenter: AddingServicePresenter(
                        flowController: flowController,
                        interactor: ModuleInteractorFactory.shared.addingServiceModuleInteractor()
                    ),
                    onClose: onFullyDismissed
                )
                .background(.clear)
            }
        }
    }
}

extension AddingServiceFlowController: AddingServiceFlowControlling {
    func toToken(serviceData: ServiceData) {
        parent?.addingServiceToToken(serviceData)
    }
    
    func close() {
        parent?.addingServiceDismiss()
    }
    
    func toAddManually() {
        presentManually(name: nil)
    }
    
    func toAppSettings() {
        parent?.addingServiceDismiss()
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    func toGuides() {
        guard let _viewController else { return }
        GuideSelectorNavigationFlowController.show(on: _viewController, parent: self)
    }

    func toGallery() {
        guard let _viewController else { return }
        _ = SelectFromGalleryFlowController.present(
            on: _viewController,
            applyOverlay: true,
            parent: self
        )
    }
    
    func toGoogleAuthSummary(importable: Int, total: Int, codes: [Code]) {
        parent?.addingServiceToGoogleAuthSummary(importable: importable, total: total, codes: codes)
    }
    
    func toLastPassSummary(importable: Int, total: Int, codes: [Code]) {
        parent?.addingServiceToLastPassSummary(importable: importable, total: total, codes: codes)
    }
    
    func toPushPermissions(for extensionID: ExtensionID) {
        parent?.addingServiceToPushPermissions(for: extensionID)
    }
    
    func toTwoFASWebExtensionPairing(for extensionID: ExtensionID) {
        parent?.addingServiceToTwoFASWebExtensionPairing(for: extensionID)
    }
    
    func toSendLogs(auditID: UUID) {
        parent?.addingServiceToSendLogs(auditID: auditID)
    }
}

extension AddingServiceFlowController {
    func presentManually(name: String?) {
        guard let _viewController else { return }
        AddingServiceManuallyNavigationFlowController.present(
            on: _viewController,
            parent: self,
            name: name
        )
    }
}

extension AddingServiceFlowController: AddingServiceManuallyNavigationFlowControllerParent {
    func addingServiceManuallyToClose(_ serviceData: ServiceData) {
        parent?.addingServiceToToken(serviceData)
    }

    func addingServiceManuallyToCancel() {
        _viewController?.dismiss(animated: true)
    }
}

extension AddingServiceFlowController: GuideSelectorNavigationFlowControllerParent {
    func closeGuideSelector() {
        _viewController?.dismiss(animated: true)
    }

    func guideToAddManually(with data: String?) {
        _viewController?.dismiss(animated: true) { [weak self] in
            self?.presentManually(name: data)
        }
    }

    func guideToCodeScanner() {
        _viewController?.dismiss(animated: true)
    }
}

extension AddingServiceFlowController: SelectFromGalleryFlowControllerParent {
    func galleryDidFinish() {
        _viewController?.dismiss(animated: true)
    }

    func galleryDidImport(count: Int) {
        parent?.addingServiceGalleryDidImport(count: count)
    }

    func galleryDidCancel() {
        _viewController?.dismiss(animated: true)
    }

    func galleryServiceWasCreated(serviceData: ServiceData) {
        parent?.addingServiceToToken(serviceData)
    }

    func galleryToSendLogs(auditID: UUID) {
        parent?.addingServiceToSendLogs(auditID: auditID)
    }
}

// MARK: - Custom zoom-from-rect transition

private final class ZoomFromRectAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    enum Direction { case present, dismiss }

    private let direction: Direction
    private let sourceProvider: () -> UIView?

    init(direction: Direction, sourceProvider: @escaping () -> UIView?) {
        self.direction = direction
        self.sourceProvider = sourceProvider
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        switch direction {
        case .present: 0.45
        case .dismiss: 0.35
        }
    }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        let container = context.containerView
        let sourceRect = computeSourceRect(in: container)

        switch direction {
        case .present:
            animatePresent(context: context, container: container, sourceRect: sourceRect)
        case .dismiss:
            animateDismiss(context: context, container: container, sourceRect: sourceRect)
        }
    }

    private func animatePresent(
        context: UIViewControllerContextTransitioning,
        container: UIView,
        sourceRect: CGRect
    ) {
        guard let toVC = context.viewController(forKey: .to),
              let toView = context.view(forKey: .to) else {
            context.completeTransition(false)
            return
        }

        let finalFrame = context.finalFrame(for: toVC)
        container.addSubview(toView)
        toView.frame = finalFrame
        toView.layoutIfNeeded()

        let startTransform = transform(from: sourceRect, to: finalFrame)
        let startRadius = min(sourceRect.height, sourceRect.width) / 2

        toView.transform = startTransform
        toView.layer.cornerRadius = startRadius
        toView.layer.masksToBounds = true
        toView.alpha = 0

        UIView.animate(
            withDuration: transitionDuration(using: context),
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0,
            options: [.curveEaseInOut]
        ) {
            toView.transform = .identity
            toView.layer.cornerRadius = 0
            toView.alpha = 1
        } completion: { _ in
            toView.transform = .identity
            toView.layer.cornerRadius = 0
            toView.layer.masksToBounds = false
            context.completeTransition(!context.transitionWasCancelled)
        }
    }

    private func animateDismiss(
        context: UIViewControllerContextTransitioning,
        container: UIView,
        sourceRect: CGRect
    ) {
        guard let fromView = context.view(forKey: .from) else {
            context.completeTransition(false)
            return
        }

        let initialFrame = fromView.frame
        let endTransform = transform(from: sourceRect, to: initialFrame)
        let endRadius = min(sourceRect.height, sourceRect.width) / 2

        fromView.layer.cornerRadius = 0
        fromView.layer.masksToBounds = true

        UIView.animate(
            withDuration: transitionDuration(using: context),
            delay: 0,
            options: [.curveEaseInOut]
        ) {
            fromView.transform = endTransform
            fromView.layer.cornerRadius = endRadius
            fromView.alpha = 0
        } completion: { _ in
            fromView.transform = .identity
            fromView.removeFromSuperview()
            context.completeTransition(!context.transitionWasCancelled)
        }
    }

    private func computeSourceRect(in container: UIView) -> CGRect {
        if let source = sourceProvider() {
            return source.convert(source.bounds, to: container)
        }
        // Fallback
        return CGRect(x: container.bounds.midX - 0.5, y: 0, width: 1, height: 1)
    }

    private func transform(from sourceRect: CGRect, to finalRect: CGRect) -> CGAffineTransform {
        let scaleX = sourceRect.width / finalRect.width
        let scaleY = sourceRect.height / finalRect.height
        let translateX = sourceRect.midX - finalRect.midX
        let translateY = sourceRect.midY - finalRect.midY
        return CGAffineTransform(translationX: translateX, y: translateY)
            .scaledBy(x: scaleX, y: scaleY)
    }
}

private final class ZoomFromRectTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let sourceProvider: () -> UIView?

    init(sourceProvider: @escaping () -> UIView?) {
        self.sourceProvider = sourceProvider
        super.init()
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        ZoomFromRectAnimator(direction: .present, sourceProvider: sourceProvider)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ZoomFromRectAnimator(direction: .dismiss, sourceProvider: sourceProvider)
    }
}
