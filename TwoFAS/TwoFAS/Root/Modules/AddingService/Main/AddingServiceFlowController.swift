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
    // swiftlint:disable weak_delegate
    private var zoomTransitioningDelegate: ZoomFromRectTransitioningDelegate?
    // swiftlint:enable weak_delegate

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
        hosting.modalPresentationStyle = .custom
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

    private enum DynamicIsland {
        /// Value of `safeAreaInsets.top` above which we're determining device has Dynamic Island.
        static let detectionThreshold: CGFloat = 51
        static let width: CGFloat = 124
        static let height: CGFloat = 37
        /// Spacing between Dynamic Island and `safeAreaInsets.top`.
        static let bottomMargin: CGFloat = 4
    }

    private enum Fallback {
        /// Point size when no Dynamic Island
        static let pointSize: CGFloat = 1
    }

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
        let constraints: [NSLayoutConstraint] = if topInset >= DynamicIsland.detectionThreshold {
            [
                marker.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
                marker.widthAnchor.constraint(equalToConstant: DynamicIsland.width),
                marker.heightAnchor.constraint(equalToConstant: DynamicIsland.height),
                marker.bottomAnchor.constraint(
                    equalTo: viewController.view.topAnchor,
                    constant: topInset - DynamicIsland.bottomMargin
                )
            ]
        } else {
            // Notch / iPad / older devices
            [
                marker.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
                marker.topAnchor.constraint(equalTo: viewController.view.topAnchor),
                marker.widthAnchor.constraint(equalToConstant: Fallback.pointSize),
                marker.heightAnchor.constraint(equalToConstant: Fallback.pointSize)
            ]
        }
        NSLayoutConstraint.activate(constraints)

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
            Color.clear
                .contentShape(Rectangle())
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

    private enum Constants {
        static let duration: TimeInterval = 0.35
        static let springDamping: CGFloat = 0.85
        static let springVelocity: CGFloat = 0
        static let curve: UIView.AnimationOptions = .curveEaseInOut
        /// Fallback source rect when `sourceProvider` returns nil
        static let fallbackRectSize: CGFloat = 1
    }

    private let direction: Direction
    private let sourceProvider: () -> UIView?

    init(direction: Direction, sourceProvider: @escaping () -> UIView?) {
        self.direction = direction
        self.sourceProvider = sourceProvider
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        Constants.duration
    }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        switch direction {
        case .present: animatePresent(context: context)
        case .dismiss: animateDismiss(context: context)
        }
    }

    // MARK: - Animations

    private func animatePresent(context: UIViewControllerContextTransitioning) {
        guard let toVC = context.viewController(forKey: .to),
              let toView = context.view(forKey: .to) else {
            context.completeTransition(false)
            return
        }

        let container = context.containerView
        let finalFrame = context.finalFrame(for: toVC)
        let sourceRect = computeSourceRect(in: container)

        container.addSubview(toView)
        toView.frame = finalFrame
        toView.layoutIfNeeded()

        applyZoomedState(to: toView, sourceRect: sourceRect, finalFrame: finalFrame)

        runAnimation(
            animations: { [self] in
                applyIdentityState(to: toView)
            },
            completion: { _ in
                self.applyIdentityState(to: toView)
                toView.layer.masksToBounds = false
                context.completeTransition(!context.transitionWasCancelled)
            }
        )
    }

    private func animateDismiss(context: UIViewControllerContextTransitioning) {
        guard let fromView = context.view(forKey: .from) else {
            context.completeTransition(false)
            return
        }

        let sourceRect = computeSourceRect(in: context.containerView)
        let initialFrame = fromView.frame

        fromView.layer.masksToBounds = true

        runAnimation(
            animations: { [self] in
                applyZoomedState(to: fromView, sourceRect: sourceRect, finalFrame: initialFrame)
            },
            completion: { _ in
                fromView.transform = .identity
                fromView.removeFromSuperview()
                context.completeTransition(!context.transitionWasCancelled)
            }
        )
    }

    private func runAnimation(
        animations: @escaping () -> Void,
        completion: @escaping (Bool) -> Void
    ) {
        UIView.animate(
            withDuration: Constants.duration,
            delay: 0,
            usingSpringWithDamping: Constants.springDamping,
            initialSpringVelocity: Constants.springVelocity,
            options: Constants.curve,
            animations: animations,
            completion: completion
        )
    }

    // MARK: - View state

    private func applyZoomedState(to view: UIView, sourceRect: CGRect, finalFrame: CGRect) {
        view.transform = zoomedTransform(from: sourceRect, to: finalFrame)
        view.layer.cornerRadius = pillRadius(for: sourceRect)
        view.alpha = 0
    }

    private func applyIdentityState(to view: UIView) {
        view.transform = .identity
        view.layer.cornerRadius = 0
        view.alpha = 1
    }

    // MARK: - Geometry

    private func computeSourceRect(in container: UIView) -> CGRect {
        if let source = sourceProvider() {
            return source.convert(source.bounds, to: container)
        }
        let size = Constants.fallbackRectSize
        return CGRect(x: container.bounds.midX - size / 2, y: 0, width: size, height: size)
    }

    private func zoomedTransform(from sourceRect: CGRect, to finalRect: CGRect) -> CGAffineTransform {
        let scaleX = sourceRect.width / finalRect.width
        let scaleY = sourceRect.height / finalRect.height
        let translateX = sourceRect.midX - finalRect.midX
        let translateY = sourceRect.midY - finalRect.midY
        return CGAffineTransform(translationX: translateX, y: translateY)
            .scaledBy(x: scaleX, y: scaleY)
    }

    private func pillRadius(for rect: CGRect) -> CGFloat {
        min(rect.height, rect.width) / 2
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

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

// MARK: - Dimming Presentation Controller

private final class DimmingPresentationController: UIPresentationController {
    private enum Constants {
        static let dimColor: UIColor = .black
        static let maxAlpha: CGFloat = 0.4
        static let durationShow: TimeInterval = 0.15
        static let durationHide: TimeInterval = 0.35
        static let curve: UIView.AnimationOptions = .curveLinear
    }

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.dimColor
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override var shouldRemovePresentersView: Bool { false }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let container = containerView else { return }

        container.insertSubview(dimView, at: 0)
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: container.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        UIView.animate(
            withDuration: Constants.durationShow,
            delay: 0,
            options: Constants.curve,
            animations: { [self] in
                dimView.alpha = Constants.maxAlpha
            }
        )
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        UIView.animate(
            withDuration: Constants.durationHide,
            delay: 0,
            options: Constants.curve,
            animations: { [self] in
                dimView.alpha = 0
            },
            completion: { [weak self] _ in
                self?.dimView.removeFromSuperview()
            }
        )
    }
}
