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
import SwiftUI
import Common

/// Presents a view controller as an adaptive popover: anchored (with an arrow) when a
/// `popoverAnchor` resolves, centered and arrow-less otherwise; in compact width the system
/// adapts it — both ways, live during window resizes — to a bottom sheet with a
/// content-height detent. Works with any `UIViewController`; the content is expected to
/// report its measured height into `setContentHeight(_:)` — for a `UIHostingController`
/// with `SheetContent` that is `onHeightChange(_:)` — otherwise the fallback size applies.
///
/// The owner (typically a flow controller) keeps the host alive for the lifetime of the
/// presentation; the presented controller itself is only referenced weakly.
final class AdaptivePopoverHost: NSObject {
    /// Whether the popover is currently adapted to its compact sheet; kept in sync by the
    /// adaptive presentation delegate callback.
    private var isAdaptedToSheet = false
    private var isAdaptationTransitionRunning = false
    private var pendingDetentInvalidation = false
    private var lastContentHeight: CGFloat?
    private var popoverAnchorProvider: (() -> UIView?)?
    private weak var presented: UIViewController?

    func present(
        _ viewController: UIViewController,
        on parentViewController: UIViewController,
        popoverAnchor: (() -> UIView?)? = nil
    ) {
        presented = viewController
        popoverAnchorProvider = popoverAnchor
        // Set the style before anything can touch the presentation controller: it is
        // created lazily on first access and cached — a later style change would be
        // silently ignored.
        viewController.modalPresentationStyle = .popover

        measureContent(of: viewController, in: parentViewController, proposedSize: contentSize()) {
            self.presentPopover(viewController, on: parentViewController)
        }
    }

    func setContentHeight(_ height: CGFloat) {
        guard height != lastContentHeight else { return }
        lastContentHeight = height
        // Not before the actual presentation: accessing sheetPresentationController would
        // instantiate the presentation controller prematurely; the pre-presentation
        // measurement only needs the stored height.
        guard presented?.presentingViewController != nil else { return }
        scheduleDetentInvalidation()
    }
}

private extension AdaptivePopoverHost {
    // The popover should come in at its final, content-fitted height, but SwiftUI content
    // only lays out inside a window: it is laid out invisibly in the presenting window
    // first (the measurement arrives via setContentHeight) and the actual presentation
    // runs on the next runloop turn. The measured height is the column's natural height,
    // so it is identical in the measurement window and in the presented popover.
    func measureContent(
        of viewController: UIViewController,
        in parentViewController: UIViewController,
        proposedSize: CGSize,
        completion: @escaping () -> Void
    ) {
        guard let window = parentViewController.viewIfLoaded?.window else {
            completion()
            return
        }

        viewController.view.frame = CGRect(origin: .zero, size: proposedSize)
        viewController.view.alpha = 0
        window.insertSubview(viewController.view, at: 0)
        window.layoutIfNeeded()

        DispatchQueue.main.async {
            viewController.view.removeFromSuperview()
            viewController.view.alpha = 1
            completion()
        }
    }

    func presentPopover(_ viewController: UIViewController, on parentViewController: UIViewController) {
        // Read the size class from the window — presentation host containers (e.g. the tab
        // sidebar) can override their children's traits to compact even on a full-screen iPad.
        let isRegularWidth = parentViewController.viewIfLoaded?.window?.isRegularWidthLayout
            ?? parentViewController.isRegularWidthLayout
        isAdaptedToSheet = !isRegularWidth
        applyPopoverBackground(isAdaptedToSheet: isAdaptedToSheet)
        viewController.preferredContentSize = contentSize()

        // The tab container overrides its horizontal size class to compact (to keep the
        // bottom tab bar on iPad), which makes UIKit collapse a popover presented from it
        // into a sheet even on a full-screen iPad. Present from the window root instead —
        // its traits are genuine, so the popover stays a popover in regular width and
        // still adapts to the content-detent sheet in genuinely compact windows.
        // Dismissal is unaffected: presentedViewController/dismiss are inherited across
        // the presenting hierarchy.
        let presentingViewController = parentViewController.viewIfLoaded?.window?.rootViewController
            ?? parentViewController

        if let popover = viewController.popoverPresentationController {
            popover.delegate = self
            if let anchor = popoverAnchorProvider?(), anchor.window != nil {
                popover.sourceView = anchor
            } else if let sourceView = presentingViewController.viewIfLoaded {
                // Anchorless: a centered, arrow-less popover stands in for a centered
                // form sheet — unlike a plain sheet it keeps the system's two-way
                // compact adaptation.
                popover.sourceView = sourceView
                popover.sourceRect = centerRect(of: sourceView)
                popover.permittedArrowDirections = []
            }
            // When the window narrows to compact the popover adapts to a sheet — the
            // system drives that adaptation, so no trait observation is needed here.
            let sheet = popover.adaptiveSheetPresentationController
            sheet.detents = [contentDetent()]
            sheet.selectedDetentIdentifier = .adaptiveSheetContent
            sheet.prefersGrabberVisible = false
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }

        presentingViewController.present(viewController, animated: true, completion: nil)
    }

    // Invalidating synchronously from the measurement callback closes a layout feedback
    // loop within a single transaction (measure → invalidate → layout → measure), which
    // the observation-tracking runtime detects as a hang during the popover's adaptation.
    // Deferring to the next runloop turn lets each layout settle, so the cycle converges;
    // during the adaptation transition itself invalidation is suppressed entirely and runs
    // once when the transition completes.
    func scheduleDetentInvalidation() {
        guard !isAdaptationTransitionRunning, !pendingDetentInvalidation else { return }
        pendingDetentInvalidation = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            pendingDetentInvalidation = false
            guard !isAdaptationTransitionRunning else { return }
            presented?.sheetPresentationController?.invalidateDetents()
        }
    }

    // The popover itself needs an opaque background; the compact-adapted sheet uses the
    // same transparent Liquid Glass treatment as a plain bottom sheet on iOS 26.
    func applyPopoverBackground(isAdaptedToSheet: Bool) {
        if #available(iOS 26.0, *), isAdaptedToSheet {
            presented?.view.backgroundColor = .clear
        } else {
            presented?.view.backgroundColor = AppColor.backgroundsPrimaryElevated.uiColor
        }
    }

    func contentSize() -> CGSize {
        CGSize(
            width: Theme.Metrics.popoverPreferredWidth,
            height: min(
                lastContentHeight ?? Theme.Metrics.modalLargePreferredHeight,
                Theme.Metrics.modalLargePreferredHeight
            )
        )
    }

    func centerRect(of view: UIView) -> CGRect {
        CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
    }

    // A single stable detent that resolves against the latest measured content height —
    // height changes go through invalidateDetents() instead of replacing the detents array.
    func contentDetent() -> UISheetPresentationController.Detent {
        .custom(identifier: .adaptiveSheetContent) { [weak self] context in
            min(
                self?.lastContentHeight ?? Theme.Metrics.modalLargePreferredHeight,
                context.maximumDetentValue
            )
        }
    }
}

extension AdaptivePopoverHost: UIPopoverPresentationControllerDelegate {
    // Called whenever the popover needs to re-layout (window resize, adaptation back from
    // the compact sheet). The original anchor may be stale by then — collection views
    // reflow and reuse cells — so resolve the current one and re-point the arrow; the
    // anchorless variant re-centers within its source view instead.
    func popoverPresentationController(
        _ popoverPresentationController: UIPopoverPresentationController,
        willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>,
        in view: AutoreleasingUnsafeMutablePointer<UIView>
    ) {
        if let anchor = popoverAnchorProvider?(), anchor.window != nil {
            view.pointee = anchor
            rect.pointee = anchor.bounds
        } else if popoverPresentationController.permittedArrowDirections.isEmpty {
            rect.pointee = centerRect(of: view.pointee)
        }
    }

    // Fires when the popover adapts to the compact sheet and again (with .none) when it
    // returns to the popover — the background follows the current incarnation.
    func presentationController(
        _ presentationController: UIPresentationController,
        willPresentWithAdaptiveStyle style: UIModalPresentationStyle,
        transitionCoordinator: UIViewControllerTransitionCoordinator?
    ) {
        isAdaptedToSheet = style != .none
        applyPopoverBackground(isAdaptedToSheet: isAdaptedToSheet)

        if let transitionCoordinator {
            isAdaptationTransitionRunning = true
            transitionCoordinator.animate(alongsideTransition: nil) { [weak self] _ in
                guard let self else { return }
                isAdaptationTransitionRunning = false
                scheduleDetentInvalidation()
            }
        }
    }
}

private extension UISheetPresentationController.Detent.Identifier {
    static let adaptiveSheetContent = UISheetPresentationController.Detent.Identifier("adaptiveSheetContent")
}
