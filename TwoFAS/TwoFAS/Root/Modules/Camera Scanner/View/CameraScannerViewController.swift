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
import Common
import Data
import AVFoundation

protocol CameraScannerViewControlling: AnyObject {
    func freezeCamera()
    func feedback()
    func enableOverlay()
    func disableOverlay()
}

final class CameraScannerViewController: UIViewController {
    var presenter: CameraScannerPresenter!
    
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    private let notificationCenter = NotificationCenter.default
    
    private var camera: CameraViewController!
    private var cameraViewModel: CameraViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationCenter.addObserver(
            self,
            selector: #selector(cameraStateChanged),
            name: NSNotification.Name.AVCaptureSessionWasInterrupted,
            object: nil
        )
        
        camera = CameraViewController()
        cameraViewModel = CameraViewModel(presenter: presenter)
        
        camera.viewModel = cameraViewModel
        
        camera.willMove(toParent: self)
        addChild(camera)
        view.addSubview(camera.view)
        view.pinToParent()
        camera.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        notificationCenter.removeObserver(self)
    }
    
    @objc
    private func cameraStateChanged(notification: Notification) {
        if let reasonKey = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as? Int,
           let reason = AVCaptureSession.InterruptionReason(rawValue: reasonKey) {
            let str: String = {
                switch reason {
                case .videoDeviceInUseByAnotherClient:
                    return T.Camera.cameraUsedByOtherAppTitle
                case .videoDeviceNotAvailableDueToSystemPressure:
                    return T.Camera.cameraUnavailableTitle
                case .videoDeviceNotAvailableWithMultipleForegroundApps:
                    return T.Camera.cantInitializeCameraSplitView
                default: return T.Camera.cantInitializeCameraGeneral
                }
            }()
            presenter.handleCameraError(str)
        } else {
            presenter.handleCancel()
        }
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}

extension CameraScannerViewController: CameraScannerViewControlling {
    func freezeCamera() {
        cameraViewModel.freeze()
    }
    
    func feedback() {
        feedbackGenerator.notificationOccurred(.warning)
    }
    
    func enableOverlay() {
        camera.overlayOnTop()
    }
    
    func disableOverlay() {
        camera.overlayHidden()
    }
}

private final class CameraViewModel {
    weak var delegate: CameraViewModelDelegate?
    
    var cameraDidStartedScanning: Callback?
    
    private var camera: Camera?
    
    private let presenter: CameraScannerPresenter?
    
    init(presenter: CameraScannerPresenter) {
        self.presenter = presenter
    }
    
    func freeze() {
        camera?.freeze()
    }
}

extension CameraViewModel: CameraViewModelType {
    func initialize() {
        guard
            let previewView = delegate?.viewForCamera(),
            let scanningRegion = delegate?.scanningRegion()
        else { return }
        camera = Camera(previewView: previewView, scanningRegion: scanningRegion)
        camera?.delegate = self
    }
    
    func startIfPossible() {
        camera?.startScanning()
    }
    
    func stopIfNeeded() {
        Log("Camera - stopping")
        camera?.stopScanning()
        camera?.delegate = nil
        camera?.clear()
        camera = nil
    }
    
    func cancel() {
        stopIfNeeded()
        presenter?.handleCancel()
    }
    
    func openGallery() {
        presenter?.handleOpenGallery()
    }
    
    func viewWillDisappear() {
        stopIfNeeded()
    }
    
    func updateOrientation() {
        camera?.updateOrientation()
    }
}

extension CameraViewModel: CameraDelegate {
    func didStartScanning() {
        cameraDidStartedScanning?()
    }
    
    func didFoundCode(_ code: CodeType) {
        presenter?.handleDidFound(code)
    }
}
