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

import Foundation
import AVFoundation
import UIKit.UIView
import Common

/**
 Initialize with outputs, set preview view, start preview. Then stop preview, clear. Uses back camera only with autofocus
 Additional actions are provided by Output Modules
 */
final class CameraController {
    enum CameraError: Error {
        case deviceInitialization(error: Error)
        case inputDeviceInitialization(error: Error)
        case inputDeviceRegistration
        case outputModuleRegistration(module: CameraOutputModule)
    }
    
    private var captureSession: AVCaptureSession?
    private var captureDevice: AVCaptureDevice?
    private var outputs: [CameraOutputModule] = []
    private weak var layer: AVCaptureVideoPreviewLayer?
    
    private let notificationCenter = NotificationCenter.default

    private let sessionQueue = DispatchQueue(label: "com.twofas.camera.session", qos: .userInitiated)

    weak var delegate: CameraControllerDelegate?

    /// Main-thread mirror of the requested preview state. `AVCaptureSession.isRunning`
    /// can block while `startRunning`/`stopRunning` hold the session on `sessionQueue`,
    /// so it must never be read from the main thread.
    private(set) var isRunning = false
    private var isClearing = false
    /// A start requested before the (now asynchronous) session configuration
    /// finished; honored once `initialize` completes.
    private var pendingStart = false

    /// On iPhone we lock the preview to portrait; on iPad we keep the dynamic
    /// orientation tracking based on device rotation notifications.
    private var tracksDeviceOrientation: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    /// Fixed angle for back camera when the preview is locked to portrait.
    /// (Back camera sensor is mounted landscape, so 90° rotates it upright.)
    private let portraitVideoRotationAngle: CGFloat = 90
    
    private func initializationFailed(_ error: CameraError) {
        Log("CameraController - initializationFailed \(error)", module: .camera)
        delegate?.cameraFailedToInitilize(with: error)
        clear()
    }
    
    init() {}
    
    /// Use outputs for e.g. Photo or QR Code scanning
    func initialize(with outputs: [CameraOutputModule]) {
        Log("CameraController - initialize", module: .camera)

        if tracksDeviceOrientation {
            notificationCenter.addObserver(
                self,
                selector: #selector(updateOrientation),
                name: UIDevice.orientationDidChangeNotification,
                object: nil
            )
        }

        sessionQueue.async { [weak self] in
            guard let self else { return }

            let captureSession = AVCaptureSession()
            captureSession.sessionPreset = .high

            guard let device = AVCaptureDevice.default(for: .video) else { return }
            do {
                try device.lockForConfiguration()
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                }
                device.unlockForConfiguration()
            } catch {
                DispatchQueue.main.async { self.initializationFailed(.deviceInitialization(error: error)) }
                return
            }

            let videoInput: AVCaptureDeviceInput
            do {
                videoInput = try AVCaptureDeviceInput(device: device)
            } catch {
                DispatchQueue.main.async { self.initializationFailed(.inputDeviceInitialization(error: error)) }
                return
            }

            captureSession.beginConfiguration()

            guard captureSession.canAddInput(videoInput) else {
                captureSession.commitConfiguration()
                DispatchQueue.main.async { self.initializationFailed(.inputDeviceRegistration) }
                return
            }
            captureSession.addInput(videoInput)

            for outputModule in outputs {
                guard let output = outputModule.output, captureSession.canAddOutput(output) else {
                    captureSession.commitConfiguration()
                    DispatchQueue.main.async {
                        self.initializationFailed(.outputModuleRegistration(module: outputModule))
                    }
                    return
                }
                captureSession.addOutput(output)
                outputModule.registered()
            }

            captureSession.commitConfiguration()

            DispatchQueue.main.async {
                guard !self.isClearing else { return }
                self.captureDevice = device
                self.outputs = outputs
                self.captureSession = captureSession
                self.layer?.session = captureSession
                self.updateOrientation()
                self.delegate?.cameraDidInitialize()
                Log("CameraController - initialize successful", module: .camera)
                if self.pendingStart {
                    self.pendingStart = false
                    self.startPreview()
                }
            }
        }
    }
    
    /// Set the view backed by AVCaptureViewPreviewLayer
    func setPreview(_ view: UIView) {
        guard let layer = view.layer as? AVCaptureVideoPreviewLayer
        else { fatalError("CameraController: Passed view doesn't have a AVCaptureVideoPreviewLayer backing layer") }
        layer.session = captureSession
        layer.videoGravity = .resizeAspectFill

        self.layer = layer
        // Apply orientation immediately so the very first frames render correctly,
        // before startPreview() runs.
        updateOrientation()
        Log("CameraController - setPreview with view: \(view)", module: .camera)
    }
    
    func startPreview() {
        guard !isRunning else { return }
        guard let session = captureSession else {
            pendingStart = true
            return
        }
        isRunning = true
        Log("CameraController - startPreview. Starting!", module: .camera)
        updateOrientation()
        if tracksDeviceOrientation {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        sessionQueue.async { [weak self] in
            guard !session.isRunning else { return }
            session.startRunning()
            DispatchQueue.main.async {
                self?.delegate?.cameraStartedPreview()
            }
        }
    }

    func stopPreview() {
        guard isRunning, let session = captureSession else {
            return
        }
        isRunning = false
        Log("CameraController - stopPreview. Stopping!", module: .camera)
        if tracksDeviceOrientation {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        sessionQueue.async { [weak self] in
            guard session.isRunning else { return }
            session.stopRunning()
            DispatchQueue.main.async {
                self?.delegate?.cameraStoppedPreview()
            }
        }
    }
    
    /// Useful for freezing the screen for a while e.g. when simulating taking the photo
    func freezePreview() {
        Log("CameraController - freezePreview", module: .camera)
        let layer = layer
        sessionQueue.async { [weak self] in
            // Touching the connection can block while the session is starting/stopping.
            layer?.connection?.isEnabled = false
            DispatchQueue.main.async {
                self?.delegate?.cameraFreezedPreview()
            }
        }
    }
    
    func unfreezePreview() {
        Log("CameraController - unfreezePreview", module: .camera)
        let layer = layer
        sessionQueue.async { [weak self] in
            // Touching the connection can block while the session is starting/stopping.
            layer?.connection?.isEnabled = true
            DispatchQueue.main.async {
                self?.delegate?.cameraUnfreezedPreview()
            }
        }
    }
    
    /// Call when camera is no longer needed
    func clear() {
        Log("CameraController - clear!!!", module: .camera)
        clearSession(useAsync: true)
    }
    
    @objc
    func updateOrientation() {
        guard
            let layer,
            let connection = layer.connection,
            let device = self.captureDevice
        else { return }

        Log("CameraController - updateOrientation", module: .camera)

        let angle: CGFloat
        if tracksDeviceOrientation {
            // iPad: follow device rotation through RotationCoordinator.
            let rotationCoordinator = AVCaptureDevice.RotationCoordinator(
                device: device,
                previewLayer: layer
            )
            angle = rotationCoordinator.videoRotationAngleForHorizonLevelPreview
        } else {
            // iPhone: locked to portrait, ignore device orientation.
            angle = portraitVideoRotationAngle
        }

        guard connection.isVideoRotationAngleSupported(angle) else { return }

        connection.videoRotationAngle = angle
    }
    
    // MARK: - Private
    
    private func clearSession(useAsync: Bool) {
        guard !isClearing else {
            return
        }
        isClearing = true
        pendingStart = false
        isRunning = false
        Log("CameraController - clearSession. Use async: \(useAsync)", module: .camera)

        layer = nil
        let session = captureSession
        captureSession = nil
        let modulesToClear = outputs
        outputs = []

        func teardown() {
            guard let session else { return }
            session.inputs.forEach(session.removeInput)
            session.outputs.forEach(session.removeOutput)
            modulesToClear.forEach { $0.clear() }
            if session.isRunning {
                session.stopRunning()
            }
        }

        if useAsync {
            sessionQueue.async { [weak self] in
                teardown()
                DispatchQueue.main.async { [weak self] in
                    Log("CameraController - did clear!", module: .camera)
                    self?.delegate?.cameraDidClear()
                }
                Log("CameraController - did clear in async!", module: .camera)
            }
        } else {
            sessionQueue.async {
                teardown()
                Log("CameraController - did clear!", module: .camera)
            }
        }
    }

    deinit {
        Log("CameraController - deinit!", module: .camera)
        notificationCenter.removeObserver(self)
        clearSession(useAsync: false)
    }
}
