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

/// Presents a view controller as the shared adaptive modal. In regular width it becomes a
/// popover anchored to `popoverAnchor` (falling back to a centered form sheet fitted
/// vertically to the content when no anchor is given); in compact width a bottom sheet with
/// a content-height detent. The mode follows the window's width class: the sheet modes are
/// switched live on trait changes, and the popover adapts to the content-detent sheet
/// through the system's adaptive presentation. Works with any `UIViewController`; the
/// content is expected to report its measured height into `setContentHeight(_:)` — for a
/// `UIHostingController` with `SheetContent` that is `onHeightChange(_:)` — otherwise the
/// fallback size applies.
///
/// The owner (typically a flow controller) keeps the host alive for the lifetime of the
/// presentation; the presented controller itself is only referenced weakly.
final class AdaptiveSheetHost: NSObject {
    // In regular width the modal is a popover or a centered form sheet sized to the
    // content; in compact width it is a bottom sheet sized via a custom detent.
    private var presentsCentered = false
    private var presentsPopover = false
    /// Whether the popover is currently adapted to its compact sheet; kept in sync by the
    /// adaptive presentation delegate callback.
    private var isAdaptedToSheet = false
    private var isAdaptationTransitionRunning = false
    private var pendingDetentInvalidation = false
    private var lastContentHeight: CGFloat?
    private var traitRegistration: (any UITraitChangeRegistration)?
    private weak var observedWindow: UIWindow?
    private weak var presented: UIViewController?
    private var popoverAnchorProvider: (() -> UIView?)?

    deinit {
        guard let observedWindow, let traitRegistration else { return }
        // The host deallocates together with the presentation on the main thread.
        MainActor.assumeIsolated {
            observedWindow.unregisterForTraitChanges(traitRegistration)
        }
    }

    func present(
        _ viewController: UIViewController,
        on parentViewController: UIViewController,
        popoverAnchor: (() -> UIView?)? = nil
    ) {
        presented = viewController
        popoverAnchorProvider = popoverAnchor
        // The provider is queried again on every reposition (window resizes reflow
        // collection views and reuse cells, so a captured view would go stale).
        let anchor = popoverAnchor?()
        // Read the size class from the window — presentation host containers (e.g. the tab
        // sidebar) can override their children's traits to compact even on a full-screen iPad.
        presentsCentered = parentViewController.viewIfLoaded?.window?.isRegularWidthLayout
            ?? parentViewController.isRegularWidthLayout
        // With an anchor the popover is used regardless of the width class: only the popover
        // presentation adapts BOTH ways (popover in regular, content-detent sheet in compact),
        // so a presentation started in compact still becomes an anchored popover when the
        // window grows. A plain sheet can never morph into a popover mid-presentation.
        presentsPopover = anchor?.window != nil
        // Set the final style before anything can touch the presentation controller: it is
        // created lazily on first access (e.g. sheetPresentationController during the
        // measurement pass) and cached — a later style change would be silently ignored.
        viewController.modalPresentationStyle = presentsPopover ? .popover : .formSheet

        if presentsPopover, let anchor {
            measureContent(of: viewController, in: parentViewController, proposedSize: popoverContentSize()) {
                self.presentPopover(viewController, on: parentViewController, anchor: anchor)
            }
        } else if presentsCentered {
            measureContent(of: viewController, in: parentViewController, proposedSize: centeredContentSize()) {
                self.presentSheet(viewController, on: parentViewController)
            }
        } else {
            presentSheet(viewController, on: parentViewController)
        }
    }

    func setContentHeight(_ height: CGFloat) {
        guard height != lastContentHeight else { return }
        lastContentHeight = height
        // The centered form sheet and the popover are sized once, at presentation time —
        // the live measurements are noisy while the presentation settles and would make
        // the frame wobble. The detent stays live: it also drives the sheet the popover
        // adapts to when the window narrows to compact.
        guard presentsPopover || !presentsCentered else { return }
        // Not before the actual presentation: accessing sheetPresentationController would
        // instantiate and freeze the presentation controller prematurely.
        guard presented?.presentingViewController != nil else { return }
        // The detent resolves against lastContentHeight, so re-resolving it is enough.
        // Replacing the detents array here would restart the sheet's animation on every
        // measurement, which livelocks against an interactive window resize (the resize
        // itself triggers a measurement each frame).
        scheduleDetentInvalidation()
    }
}

private extension AdaptiveSheetHost {
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

    // The regular-width modes should come in at their final, content-fitted height, but the
    // content can only be measured while it lives in a window: it is laid out invisibly in
    // the presenting window first (the measurement arrives via setContentHeight) and the
    // actual presentation runs on the next runloop turn.
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

    func presentPopover(
        _ viewController: UIViewController,
        on parentViewController: UIViewController,
        anchor: UIView
    ) {
        isAdaptedToSheet = !presentsCentered
        applyPopoverBackground(isAdaptedToSheet: isAdaptedToSheet)
        viewController.preferredContentSize = popoverContentSize()

        if let popover = viewController.popoverPresentationController {
            popover.sourceView = anchor
            popover.delegate = self
            // When the window narrows to compact the popover adapts to a sheet — give the
            // adaptive sheet the same content detent as the plain bottom-sheet mode. The
            // system drives that adaptation, so no trait observation is needed here.
            let sheet = popover.adaptiveSheetPresentationController
            sheet.detents = [contentDetent()]
            sheet.selectedDetentIdentifier = .adaptiveSheetContent
            sheet.prefersGrabberVisible = false
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }

        // The tab container overrides its horizontal size class to compact (to keep the
        // bottom tab bar on iPad), which makes UIKit collapse a popover presented from it
        // into a sheet even on a full-screen iPad. Present from the window root instead —
        // its traits are genuine, so the popover stays a popover in regular width and
        // still adapts to the content-detent sheet in genuinely compact windows.
        // Dismissal is unaffected: presentedViewController/dismiss are inherited across
        // the presenting hierarchy.
        let presentingViewController = parentViewController.viewIfLoaded?.window?.rootViewController
            ?? parentViewController
        presentingViewController.present(viewController, animated: true) { [weak self] in
            guard let self, presentsPopover, !isAdaptedToSheet, let presented else { return }
            // One corrective pass once the presentation settles, and only upwards: the size
            // was frozen from the pre-presentation measurement in the window, whose insets
            // differ from the presented popover's (home indicator, the bar's scroll edge
            // margin) — when it came out too short the content would scroll. Growing is the
            // lesser evil; shrinking to the settled size would visibly snap the popover
            // right after the presentation animation, so slack is left alone. A single
            // write only: continuously tracking the measurement re-animates the popover
            // frame on every jitter and spirals into a layout feedback loop.
            let settled = popoverContentSize()
            if settled.height > presented.preferredContentSize.height {
                presented.preferredContentSize = settled
            }
        }
    }

    func presentSheet(_ viewController: UIViewController, on parentViewController: UIViewController) {
        viewController.modalPresentationStyle = .formSheet
        if let sheet = viewController.sheetPresentationController {
            sheet.prefersGrabberVisible = false
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        applyPresentationMode()

        parentViewController.present(viewController, animated: true, completion: nil)
        observeWindowWidth(of: parentViewController)
    }

    func observeWindowWidth(of parentViewController: UIViewController) {
        guard let window = parentViewController.viewIfLoaded?.window else { return }
        observedWindow = window
        traitRegistration = MainActor.assumeIsolated {
            window.registerForTraitChanges(
                [UITraitHorizontalSizeClass.self]
            ) { [weak self] (window: UIWindow, _) in
                self?.updatePresentationMode(isRegularWidth: window.isRegularWidthLayout)
            }
        }
    }

    func updatePresentationMode(isRegularWidth: Bool) {
        guard isRegularWidth != presentsCentered else { return }
        presentsCentered = isRegularWidth
        applyPresentationMode()
    }

    // Applied without animateChanges: the mode also switches from the trait change callback,
    // i.e. in the middle of an interactive window resize, and starting a detent animation
    // there livelocks the sheet layout against the resize.
    func applyPresentationMode() {
        guard let presented else { return }

        if #available(iOS 26.0, *), !presentsCentered {
            // Transparent so the bottom sheet's system Liquid Glass background shows through.
            // In the centered form sheet the system background hugs the content instead of
            // the sheet frame, so a transparent presented view would make the sheet look
            // smaller and shifted down — use an opaque background there.
            presented.view.backgroundColor = .clear
        } else {
            presented.view.backgroundColor = AppColor.backgroundsPrimaryElevated.uiColor
        }

        guard let sheet = presented.sheetPresentationController else { return }
        if presentsCentered {
            sheet.detents = [.large()]
            sheet.selectedDetentIdentifier = nil
            presented.preferredContentSize = centeredContentSize()
        } else {
            sheet.detents = [contentDetent()]
            sheet.selectedDetentIdentifier = .adaptiveSheetContent
        }
    }

    func centeredContentSize() -> CGSize {
        CGSize(
            width: Theme.Metrics.modalPreferredWidth,
            height: min(
                lastContentHeight ?? Theme.Metrics.modalLargePreferredHeight,
                Theme.Metrics.modalLargePreferredHeight
            )
        )
    }

    func popoverContentSize() -> CGSize {
        CGSize(
            width: Theme.Metrics.popoverPreferredWidth,
            height: min(
                lastContentHeight ?? Theme.Metrics.modalLargePreferredHeight,
                Theme.Metrics.modalLargePreferredHeight
            )
        )
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

extension AdaptiveSheetHost: UIPopoverPresentationControllerDelegate {
    // Called whenever the popover needs to re-layout (window resize, adaptation back from
    // the compact sheet). The original anchor may be stale by then — collection views
    // reflow and reuse cells — so resolve the current one and re-point the arrow.
    func popoverPresentationController(
        _ popoverPresentationController: UIPopoverPresentationController,
        willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>,
        in view: AutoreleasingUnsafeMutablePointer<UIView>
    ) {
        guard let anchor = popoverAnchorProvider?(), anchor.window != nil else { return }
        view.pointee = anchor
        rect.pointee = anchor.bounds
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

private extension AdaptiveSheetHost {
    // The popover itself needs an opaque background; the compact-adapted sheet uses the
    // same transparent Liquid Glass treatment as the plain bottom-sheet mode on iOS 26.
    func applyPopoverBackground(isAdaptedToSheet: Bool) {
        if #available(iOS 26.0, *), isAdaptedToSheet {
            presented?.view.backgroundColor = .clear
        } else {
            presented?.view.backgroundColor = AppColor.backgroundsPrimaryElevated.uiColor
        }
    }
}

private extension UISheetPresentationController.Detent.Identifier {
    static let adaptiveSheetContent = UISheetPresentationController.Detent.Identifier("adaptiveSheetContent")
}
