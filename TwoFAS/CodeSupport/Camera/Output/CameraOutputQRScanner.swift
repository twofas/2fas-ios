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
import Data

final class CameraOutputQRScanner: NSObject {
    private var metadataOutput: AVCaptureMetadataOutput?
    private weak var layer: AVCaptureVideoPreviewLayer?
    
    var didFoundCode: ((CodeType) -> Void)?
    
    override init() {}
    
    func setScanningRect(_ scanningRectangle: CGRect? = nil) {
        guard let layer = self.layer else { fatalError("To set scanning rectangle set view first") }
        guard let metadataOutput else { fatalError("To set scanning rectangle configure scanner first") }
        Log("CameraOutputQRScanner - setScanningRect \(String(describing: scanningRectangle))", module: .camera)
        if let rect = scanningRectangle, !rect.isEmpty {
            metadataOutput.rectOfInterest = layer.metadataOutputRectConverted(fromLayerRect: rect)
        }
    }
}

extension CameraOutputQRScanner: CameraOutputModule {
    var output: AVCaptureOutput? { metadataOutput }

    func initialize(with preview: UIView) {
        guard let layer = preview.layer as? AVCaptureVideoPreviewLayer else {
            fatalError("CameraOutputQRScanner: Passed view doesn't have a AVCaptureVideoPreviewLayer backing layer")
        }
        Log("CameraOutputQRScanner - initialize with \(preview)", module: .camera)
        self.layer = layer
        metadataOutput = AVCaptureMetadataOutput()
    }
    
    func registered() {
        Log("CameraOutputQRScanner - registered", module: .camera)
        metadataOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput?.metadataObjectTypes = [.qr]
    }
    
    func clear() {
        metadataOutput = nil
        layer = nil
    }
}

extension CameraOutputQRScanner: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard
            let metadata = metadataObjects.first,
            let readable = metadata as? AVMetadataMachineReadableCodeObject,
            let stringValue = readable.stringValue else { return }
        Log("CameraOutputQRScanner - metadataOutput (found code!) \(stringValue)", module: .camera, save: false)
        let codeType = Code.parse(with: stringValue)
        didFoundCode?(codeType)
    }
}
