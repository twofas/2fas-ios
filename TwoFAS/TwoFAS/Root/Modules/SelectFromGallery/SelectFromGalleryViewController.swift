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

import UIKit
import PhotosUI
import Common

// Created only to keep memory management happy
final class SelectFromGalleryViewController: UIViewController {
    var presenter: SelectFromGalleryPresenter!

    private var didReportCancel = false

    private let imagePickerConfiguration: PHPickerConfiguration = {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        return configuration
    }()
    
    func createImagePicker() -> UIViewController {
        didReportCancel = false
        let imageSelector = PHPickerViewController(configuration: imagePickerConfiguration)
        imageSelector.view.tintColor = AppColor.accentsBrand.uiColor
        imageSelector.delegate = self
        // A swipe-down dismissal bypasses `picker(_:didFinishPicking:)`; the
        // presentation controller is the only place it is reported.
        imageSelector.presentationController?.delegate = self
        return imageSelector
    }

    /// Reports the cancel exactly once, after the picker is fully off screen,
    /// whichever way it went away. Parents can therefore treat
    /// `galleryDidCancel` as "nothing is presented any more" — a dismiss
    /// issued there would land on their own controller. The one-shot guard
    /// covers an OS that delivers both the empty `didFinishPicking` and the
    /// presentation-controller callback for a single dismissal.
    private func reportPickerCancelled() {
        guard !didReportCancel else { return }
        didReportCancel = true
        presenter.handlePickerDidCancel()
    }
}

extension SelectFromGalleryViewController: UIAdaptivePresentationControllerDelegate {
    // Fires when the picker's deferred presentation transition actually
    // starts — the only moment its coordinator becomes available (the
    // remote view controller presents itself once its content has loaded,
    // after `present()` has long returned). Documented for adaptivity
    // changes, it also fires for the initial non-adapting sheet
    // presentation (verified on iOS 18.6 and 26.5).
    func presentationController(
        _ presentationController: UIPresentationController,
        willPresentWithAdaptiveStyle style: UIModalPresentationStyle,
        transitionCoordinator: UIViewControllerTransitionCoordinator?
    ) {
        presenter.handlePickerWillShow(alongside: transitionCoordinator)
    }

    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        presenter.handlePickerWillDismiss(
            alongside: presentationController.presentedViewController.transitionCoordinator
        )
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        reportPickerCancelled()
    }
}

extension SelectFromGalleryViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else {
            picker.dismiss(animated: true) { [weak self] in
                self?.reportPickerCancelled()
            }
            return
        }
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            DispatchQueue.main.async {
                picker.dismiss(animated: true, completion: { [weak self] in
                    if let image = image as? UIImage {
                        self?.presenter.handleScannedImage(image)
                    } else {
                        Log("Can't get image from gallery! \(String(describing: error))", module: .camera)
                        self?.presenter.handleScanError()
                    }
                })
            }
        }
    }
}
