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
    
    private let imagePickerConfiguration: PHPickerConfiguration = {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        return configuration
    }()
    
    func createImagePicker() -> UIViewController {
        let imageSelector = PHPickerViewController(configuration: imagePickerConfiguration)
        imageSelector.delegate = self
        return imageSelector
    }
}

extension SelectFromGalleryViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else {
            picker.dismiss(animated: true, completion: nil)
            DispatchQueue.main.async {
                self.presenter.handlePickerDidCancel()
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
