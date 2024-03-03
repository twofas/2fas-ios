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
import AVFoundation
import Common

public final class Camera {
    private let camera = CameraController()
    private let scanner = CameraOutputQRScanner()
    private var isScanning = false
    
    public weak var delegate: CameraDelegate?
    
    public init(previewView: UIView, scanningRegion: CGRect) {
        Log("Camera - init with previewView: \(previewView), scanningRegion: \(scanningRegion)", module: .camera)
        camera.delegate = self
        scanner.didFoundCode = { [weak self] in self?.delegate?.didFoundCode($0) }
        scanner.initialize(with: previewView)
        camera.initialize(with: [scanner])
        camera.setPreview(previewView)
        scanner.setScanningRect(scanningRegion)
    }
    
    public func updateScanningRegion(_ scanningRegion: CGRect) {
        Log("Camera - updateScanningRegion \(scanningRegion)", module: .camera)
        scanner.setScanningRect(scanningRegion)
    }
    
    public func startScanning() {
        Log("Camera - startScanning", module: .camera)
        camera.startPreview()
    }
    
    public func stopScanning() {
        Log("Camera - stopScanning", module: .camera)
        camera.stopPreview()
    }
    
    public func freeze() {
        Log("Camera - freeze", module: .camera)
        camera.freezePreview()
    }
    
    public func unfreeze() {
        Log("Camera - unfreeze", module: .camera)
        camera.unfreezePreview()
    }
    
    public func updateOrientation() {
        Log("Camera - updateOrientation", module: .camera)
        camera.updateOrientation()
    }
    
    public func clear() {
        Log("Camera - clear", module: .camera)
        camera.clear()
    }
    
    deinit {
        Log("Camera - deinit and clear!", module: .camera)
        camera.clear()
    }
}

extension Camera: CameraControllerDelegate {
    func cameraDidInitialize() {}
    func cameraFailedToInitilize(with error: CameraController.CameraError) {
        Log("Camera - can't start: \(error)", module: .camera)
    }
    func cameraStartedPreview() {
        delegate?.didStartScanning()
    }
    func cameraStoppedPreview() {}
    func cameraFreezedPreview() {}
    func cameraUnfreezedPreview() {}
    func cameraDidClear() {}
}
