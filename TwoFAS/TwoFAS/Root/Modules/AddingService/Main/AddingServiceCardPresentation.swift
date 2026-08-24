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

import UIKit
import Common

/// Presents the "add service" card centered in the container, sized to its
/// content, over a dimmed backdrop. Tapping the backdrop invokes
/// `onBackdropTap`. The animation itself is owned by the transitioning
/// delegate, not by this controller.
final class AddServiceCardPresentationController: UIPresentationController {
    private enum Constants {
        static let dimColor = UIColor.black.withAlphaComponent(0.7)
        /// Space between the card and the container edges.
        static let margin = Spacing.ML.value
    }

    private let cardSizeProvider: (CGSize) -> CGSize
    private let onBackdropTap: () -> Void
    /// Receives `true` when the presentation begins and `false` once it ends,
    /// so the presenting screen can suppress the zoom's push-back.
    private let setSublayerTransformDisabled: (Bool) -> Void
    private let dimmingView = UIView()

    init(
        presentedViewController: UIViewController,
        presenting: UIViewController?,
        cardSizeProvider: @escaping (CGSize) -> CGSize,
        setSublayerTransformDisabled: @escaping (Bool) -> Void,
        onBackdropTap: @escaping () -> Void
    ) {
        self.cardSizeProvider = cardSizeProvider
        self.setSublayerTransformDisabled = setSublayerTransformDisabled
        self.onBackdropTap = onBackdropTap
        super.init(presentedViewController: presentedViewController, presenting: presenting)

        dimmingView.backgroundColor = Constants.dimColor
        dimmingView.alpha = 0
        dimmingView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
        )
    }

    // MARK: - Layout

    override var shouldRemovePresentersView: Bool { false }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else { return .zero }
        let bounds = containerView.bounds
        let available = bounds.insetBy(dx: Constants.margin, dy: Constants.margin)
        let fitting = cardSizeProvider(available.size)
        let size = CGSize(
            width: min(max(fitting.width, 0), available.width),
            height: min(max(fitting.height, 0), available.height)
        )
        return CGRect(
            x: (bounds.midX - size.width / 2).rounded(),
            y: (bounds.midY - size.height / 2).rounded(),
            width: size.width,
            height: size.height
        )
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        dimmingView.frame = containerView?.bounds ?? .zero
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    // MARK: - Transitions

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView else { return }

        setSublayerTransformDisabled(true)

        // The presenting view stays in place (`shouldRemovePresentersView` is
        // false), so without this VoiceOver could still focus and activate
        // controls behind the card.
        containerView.accessibilityViewIsModal = true

        dimmingView.frame = containerView.bounds
        containerView.insertSubview(dimmingView, at: 0)

        presentedViewController.transitionCoordinator?.animate { [dimmingView] _ in
            dimmingView.alpha = 1
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        if !completed {
            dimmingView.removeFromSuperview()
            setSublayerTransformDisabled(false)
        }
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        presentedViewController.transitionCoordinator?.animate { [dimmingView] _ in
            dimmingView.alpha = 0
        } completion: { [dimmingView] context in
            if context.isCancelled {
                dimmingView.alpha = 1
            }
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        if completed {
            dimmingView.removeFromSuperview()
            setSublayerTransformDisabled(false)
        }
    }

    // MARK: - Actions

    @objc
    private func dimmingViewTapped() {
        onBackdropTap()
    }
}

