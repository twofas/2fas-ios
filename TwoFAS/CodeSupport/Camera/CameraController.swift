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
    private var outputs: [CameraOutputModule] = []
    private weak var layer: AVCaptureVideoPreviewLayer?
    
    weak var delegate: CameraControllerDelegate?
    
    var isRunning: Bool { captureSession?.isRunning ?? false }
    private var isClearing = false
    
    private func initializationFailed(_ error: CameraError) {
        Log("CameraController - initializationFailed \(error)", module: .camera)
        delegate?.cameraFailedToInitilize(with: error)
        clear()
    }
    
    init() {}
    
    /// Use outputs for e.g. Photo or QR Code scanning
    func initialize(with outputs: [CameraOutputModule]) {
        Log("CameraController - initialize", module: .camera)
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        self.outputs = outputs
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        do {
            try device.lockForConfiguration()
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            device.unlockForConfiguration()
        } catch {
            initializationFailed(.deviceInitialization(error: error))
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: device)
        } catch {
            initializationFailed(.inputDeviceInitialization(error: error))
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            initializationFailed(.inputDeviceRegistration)
            return
        }
        
        for outputModule in outputs {
            guard let output = outputModule.output, captureSession.canAddOutput(output) else {
                initializationFailed(.outputModuleRegistration(module: outputModule))
                return
            }
            captureSession.addOutput(output)
            outputModule.registered()
        }
        
        self.captureSession = captureSession
        delegate?.cameraDidInitialize()
        Log("CameraController - initialize successful", module: .camera)
    }
    
    /// Set the view backed by AVCaptureViewPreviewLayer
    func setPreview(_ view: UIView) {
        guard let layer = view.layer as? AVCaptureVideoPreviewLayer
        else { fatalError("CameraController: Passed view doesn't have a AVCaptureVideoPreviewLayer backing layer") }
        layer.session = captureSession
        layer.videoGravity = .resizeAspectFill
        
        self.layer = layer
        Log("CameraController - setPreview with view: \(view)", module: .camera)
    }
    
    func startPreview() {
        guard !isRunning else { return }
        Log("CameraController - startPreview. Starting!", module: .camera)
        updateOrientation()
        DispatchQueue.main.async {
            self.captureSession?.startRunning()
            self.delegate?.cameraStartedPreview()
        }
    }
    
    func stopPreview() {
        guard isRunning else { return }
        Log("CameraController - stopPreview. Stopping!", module: .camera)
        DispatchQueue.main.async {
            self.captureSession?.stopRunning()
            self.delegate?.cameraStoppedPreview()
        }
    }
    
    /// Useful for freezing the screen for a while e.g. when simulating taking the photo
    func freezePreview() {
        Log("CameraController - freezePreview", module: .camera)
        let connection = layer?.connection
        DispatchQueue.main.async {
            connection?.isEnabled = false
            self.delegate?.cameraFreezedPreview()
        }
    }
    
    func unfreezePreview() {
        Log("CameraController - unfreezePreview", module: .camera)
        let connection = layer?.connection
        DispatchQueue.main.async {
            connection?.isEnabled = true
            self.delegate?.cameraUnfreezedPreview()
        }
    }
    
    /// Call when camera is no longer needed
    func clear() {
        Log("CameraController - clear!!!", module: .camera)
        clearSession(useAsync: true)
    }
    
    func updateOrientation() {
        guard
            let connection = self.layer?.connection,
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            connection.isVideoOrientationSupported
        else { return }
        Log("CameraController - updateOrientation", module: .camera)
        let avOrientation: AVCaptureVideoOrientation = {
            switch scene.interfaceOrientation {
            case .landscapeLeft: return .landscapeLeft
            case .landscapeRight: return .landscapeRight
            case .portrait: return .portrait
            case .portraitUpsideDown: return .portraitUpsideDown
            case .unknown: return .portrait
            @unknown default:
                return .portrait
            }
        }()
        connection.videoOrientation = avOrientation
    }
    
    // MARK: - Private
    
    private func clearSession(useAsync: Bool) {
        guard !isClearing else { return }
        isClearing = true
        Log("CameraController - clearSession. Use async: \(useAsync)", module: .camera)
        func removeDependencies(captureSession: AVCaptureSession, callDelegate: Bool) {
            captureSession.inputs.forEach(captureSession.removeInput)
            captureSession.outputs.forEach(captureSession.removeOutput)
            outputs.forEach { $0.clear() }
            outputs = []
            captureSession.stopRunning()
            self.captureSession = nil
            if callDelegate {
                Log("CameraController - did clear!", module: .camera)
                delegate?.cameraDidClear()
            }
        }
        
        layer?.session = nil
        layer = nil
        
        guard let captureSession else {
            Log("CameraController - did clear!", module: .camera)
            outputs = []
            delegate?.cameraDidClear()
            return
        }
        
        if useAsync {
            DispatchQueue.main.async {
                removeDependencies(captureSession: captureSession, callDelegate: true)
            }
        } else {
            removeDependencies(captureSession: captureSession, callDelegate: false)
        }
        Log("CameraController - did clear!", module: .camera)
    }
    
    deinit {
        Log("CameraController - deinit!", module: .camera)
        clearSession(useAsync: false)
    }
}
