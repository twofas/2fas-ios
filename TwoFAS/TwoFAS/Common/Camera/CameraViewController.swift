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
import Data
import Common

protocol CameraViewControllerActivity {
    func overlayOnTop()
    func overlayHidden()
}

final class CameraViewController: UIViewController {
    private let activeAreaYOffset = Theme.Metrics.cameraActiveAreaYOffset
    private let cancelButtonOffset: CGFloat = 20
    private let descriptionOffset: CGFloat = 50
    private let openGalleryOffset: CGFloat = 64
    private let spacing: CGFloat = 16
    
    var viewModel: CameraViewModelType!
    private let cameraPreview = CameraPreview()
    private var cameraView: CameraView!
    private var activeArea: CameraActiveArea!
    private var cancelButtonTitle: String?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = T.Commons.scanQrCode
        label.font = TextStyle.headline.uiFont()
        label.textColor = AppColor.graysWhite.uiColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = TextStyle.body.uiFont()
        label.textColor = AppColor.graysWhite.uiColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = T.Commons.cameraTitle
        label.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        return label
    }()
    private let descriptionFrame = UIView()
    private let cancelButton: UIButton = {
        let button = UIButton()
        if #available(iOS 26, *) {
            var config = UIButton.Configuration.glass()
            config.baseForegroundColor = AppColor.accentsBrand.uiColor
            button.configuration = config
            button.configurationUpdateHandler = { button in
                button.configuration?.baseForegroundColor = button.isEnabled
                    ? AppColor.accentsBrand.uiColor
                    : AppColor.graysGray.uiColor
            }
        } else {
            button.setTitleColor(AppColor.accentsBrand.uiColor, for: .normal)
            button.setTitleColor(AppColor.graysGray.uiColor, for: .disabled)
            button.titleLabel?.font = TextStyle.headline.uiFont()
            button.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.titleLabel?.layer.shadowOpacity = 0.3
            button.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        }
        return button
    }()

    private let openGalleryButton: UIButton = {
        let button = UIButton()
        if #available(iOS 26, *) {
            // Circular glass background to match the redesigned styling.
            var config = UIButton.Configuration.glass()
            config.cornerStyle = .capsule
            config.image = Asset.openGallery.image.apply(AppColor.accentsBrand.uiColor)
            let inset = Spacing.L.rawValue
            config.contentInsets = NSDirectionalEdgeInsets(
                top: inset,
                leading: inset,
                bottom: inset,
                trailing: inset
            )
            button.configuration = config
        } else {
            button.setImage(Asset.openGallery.image, for: .normal)
            button.setImage(Asset.openGallery.image.apply(AppColor.accentsBrand.uiColor), for: .normal)
        }
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        viewModel.cameraDidStartedScanning = { [weak self] in self?.cameraDidStartedScanning() }
        
        cameraView = CameraView()
        activeArea = CameraActiveArea(size: Theme.Metrics.cameraActiveAreaSize)
        
        view.addSubview(cameraPreview)
        cameraPreview.pinToParent()
        cameraPreview.alpha = 0
        
        viewModel.delegate = self
        
        view.addSubview(cameraView)
        cameraView.pinToParent()
        
        view.addSubview(activeArea, with: [
            activeArea.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activeArea.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -activeAreaYOffset)
        ])
        
        let cancelTitle = cancelButtonTitle ?? T.Commons.cancel
        if #available(iOS 26, *) {
            cancelButton.configuration?.title = cancelTitle
        } else {
            cancelButton.setTitle(cancelTitle, for: .normal)
        }
        
        view.addSubview(cancelButton, with: [
            cancelButton.leadingAnchor.constraint(
                equalTo: view.safeLeadingAnchor,
                constant: Spacing.XL.rawValue
            ),
            cancelButton.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: Spacing.M.rawValue)
        ])
        
        view.addSubview(titleLabel, with: [
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.firstBaselineAnchor.constraint(equalTo: cancelButton.firstBaselineAnchor)
        ])
        
        view.addSubview(descriptionFrame, with: [
            descriptionFrame.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionFrame.topAnchor.constraint(
                greaterThanOrEqualTo: titleLabel.bottomAnchor,
                constant: Spacing.M.rawValue
            )
        ])
        let breakable = descriptionFrame.bottomAnchor.constraint(
            equalTo: activeArea.topAnchor,
            constant: -descriptionOffset
        )
        breakable.priority = .defaultLow - 1
        NSLayoutConstraint.activate([
            breakable
        ])
        configureDescriptionFrameAppearance()

        let horizontalMargin: CGFloat
        let verticalMargin: CGFloat
        if #available(iOS 26, *) {
            horizontalMargin = Spacing.XL.rawValue
            verticalMargin = Spacing.L.rawValue
        } else {
            horizontalMargin = Spacing.SM.rawValue
            verticalMargin = Spacing.SM.rawValue
        }
        descriptionFrame.addSubview(descriptionLabel, with: [
            descriptionLabel.topAnchor.constraint(
                equalTo: descriptionFrame.topAnchor,
                constant: verticalMargin
            ),
            descriptionLabel.bottomAnchor.constraint(
                equalTo: descriptionFrame.bottomAnchor,
                constant: -verticalMargin
            ),
            descriptionLabel.leadingAnchor.constraint(
                equalTo: descriptionFrame.leadingAnchor,
                constant: horizontalMargin
            ),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: descriptionFrame.trailingAnchor,
                constant: -horizontalMargin
            ),
            descriptionLabel.widthAnchor.constraint(
                equalTo: activeArea.widthAnchor,
                constant: 2 * Spacing.SM.rawValue
            )
        ])
        
        view.addSubview(openGalleryButton, with: [
            openGalleryButton.trailingAnchor.constraint(equalTo: activeArea.trailingAnchor),
            openGalleryButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -openGalleryOffset)
        ])
        
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        openGalleryButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
                
        cameraView.setHeight(
            top: Theme.Metrics.cameraTopGradientHeigth,
            bottom: Theme.Metrics.cameraBottomGradientHeigth
        )
    }
        
    private func configureDescriptionFrameAppearance() {
        descriptionFrame.layer.cornerCurve = .continuous
        descriptionFrame.layer.cornerRadius = TFCornerRadius.large.value
        descriptionFrame.clipsToBounds = true

        if #available(iOS 26, *) {
            let glassView = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
            glassView.translatesAutoresizingMaskIntoConstraints = false
            descriptionFrame.insertSubview(glassView, at: 0)
            NSLayoutConstraint.activate([
                glassView.topAnchor.constraint(equalTo: descriptionFrame.topAnchor),
                glassView.bottomAnchor.constraint(equalTo: descriptionFrame.bottomAnchor),
                glassView.leadingAnchor.constraint(equalTo: descriptionFrame.leadingAnchor),
                glassView.trailingAnchor.constraint(equalTo: descriptionFrame.trailingAnchor)
            ])
        } else {
            descriptionFrame.backgroundColor = UIColor(white: 0, alpha: 0.67)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.initialize()
        viewModel.startIfPossible()
    }
    
    @objc(openGallery)
    private func openGallery() {
        viewModel.openGallery()
    }
    
    @objc(cancelAction)
    private func cancelAction() {
        viewModel.cancel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.viewWillDisappear()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        viewModel.updateOrientation()
    }
    
    private func cameraDidStartedScanning() {
        UIView.animate(withDuration: Theme.Animations.Timing.show) {
            self.cameraPreview.alpha = 1
        }
    }
}

extension CameraViewController: CameraViewModelDelegate {
    func viewForCamera() -> UIView { cameraPreview }
    
    func scanningRegion() -> CGRect {
        let frame = view.frame
        let width = frame.size.width
        let height = frame.size.height
        let bracketSize = activeArea.intrinsicContentSize.width
        
        var bracketRect = CGRect(
            x: (width - bracketSize).half,
            y: (height - bracketSize).half + activeAreaYOffset,
            width: bracketSize,
            height: bracketSize
        )
        let outset = (width - bracketRect.width).half
        if outset > 0 {
            bracketRect = bracketRect.insetBy(dx: -outset, dy: -outset)
        }
        
        return cameraPreview.convert(bracketRect, from: view)
    }
    
    var isPresenting: Bool { presentedViewController != nil }
}

extension CameraViewController: CameraViewControllerActivity {
    func overlayOnTop() {
        titleLabel.textColor = AppColor.graysGray.uiColor
        cancelButton.isEnabled = false
    }

    func overlayHidden() {
        titleLabel.textColor = AppColor.graysWhite.uiColor
        cancelButton.isEnabled = true
    }
}
