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

/// Presents a view controller as the shared adaptive modal: in regular width a centered
/// form sheet fitted vertically to the content, in compact width a bottom sheet with a
/// content-height detent. The mode is switched live when the window changes width
/// (Split View, Stage Manager). Works with any `UIViewController`; the content is expected
/// to report its measured height into `setContentHeight(_:)` — for a `UIHostingController`
/// with `SheetContent` that is `onHeightChange(_:)` — otherwise the fallback size applies.
///
/// The owner (typically a flow controller) keeps the host alive for the lifetime of the
/// presentation; the presented controller itself is only referenced weakly.
final class AdaptiveSheetHost {
    // In regular width the modal is a centered form sheet sized to the content;
    // in compact width it is a bottom sheet sized via a custom detent.
    private var presentsCentered = false
    private var lastContentHeight: CGFloat?
    private var traitRegistration: (any UITraitChangeRegistration)?
    private weak var observedWindow: UIWindow?
    private weak var presented: UIViewController?

    deinit {
        guard let observedWindow, let traitRegistration else { return }
        // The host deallocates together with the presentation on the main thread.
        MainActor.assumeIsolated {
            observedWindow.unregisterForTraitChanges(traitRegistration)
        }
    }

    func present(_ viewController: UIViewController, on parentViewController: UIViewController) {
        presented = viewController
        // Read the size class from the window — presentation host containers (e.g. the tab
        // sidebar) can override their children's traits to compact even on a full-screen iPad.
        presentsCentered = parentViewController.viewIfLoaded?.window?.isRegularWidthLayout
            ?? parentViewController.isRegularWidthLayout

        if presentsCentered {
            presentCentered(viewController, on: parentViewController)
        } else {
            presentSheet(viewController, on: parentViewController)
        }
    }

    func setContentHeight(_ height: CGFloat) {
        guard height != lastContentHeight else { return }
        lastContentHeight = height
        // The centered form sheet is sized once, at presentation time — the live
        // measurements are noisy while the presentation settles and would make the
        // sheet wobble.
        guard !presentsCentered else { return }
        // The detent resolves against lastContentHeight, so re-resolving it is enough.
        // Replacing the detents array here would restart the sheet's animation on every
        // measurement, which livelocks against an interactive window resize (the resize
        // itself triggers a measurement each frame).
        presented?.sheetPresentationController?.invalidateDetents()
    }
}

private extension AdaptiveSheetHost {
    // The centered form sheet should come in at its final, content-fitted height, but the
    // content can only be measured while it lives in a window: it is laid out invisibly in
    // the presenting window first (the measurement arrives via setContentHeight) and the
    // actual presentation runs on the next runloop turn.
    func presentCentered(_ viewController: UIViewController, on parentViewController: UIViewController) {
        guard let window = parentViewController.viewIfLoaded?.window else {
            presentSheet(viewController, on: parentViewController)
            return
        }

        viewController.view.frame = CGRect(origin: .zero, size: centeredContentSize())
        viewController.view.alpha = 0
        window.insertSubview(viewController.view, at: 0)
        window.layoutIfNeeded()

        DispatchQueue.main.async { [weak parentViewController] in
            viewController.view.removeFromSuperview()
            viewController.view.alpha = 1
            guard let parentViewController else { return }
            self.presentSheet(viewController, on: parentViewController)
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

private extension UISheetPresentationController.Detent.Identifier {
    static let adaptiveSheetContent = UISheetPresentationController.Detent.Identifier("adaptiveSheetContent")
}
