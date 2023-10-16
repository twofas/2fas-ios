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
import Vision
import Common

public enum ScanImageError: Error {
    case noCodesFound
    case scanError
}

public typealias VisionScanCompletion = (Result<[String], ScanImageError>) -> Void

extension MainRepositoryImpl {
    func scan(image: UIImage, completion: @escaping VisionScanCompletion) {
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let cgImage = image.cgImage else {
            Log("Can't get cgImage", module: .camera)
            completion(.failure(.scanError))
            return
        }
        performVisionRequest(image: cgImage, orientation: cgOrientation, completion: completion)
    }
    
    private func performVisionRequest(
        image: CGImage,
        orientation: CGImagePropertyOrientation,
        completion: @escaping VisionScanCompletion
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let requests = self.createVisionRequests(completion: completion)
            let imageRequestHandler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])

            do {
                try imageRequestHandler.perform(requests)
            } catch let error as NSError {
                Log("Failed to perform Vision request \(error)", module: .camera)
                DispatchQueue.main.async {
                    completion(.failure(.scanError))
                }
                return
            }
        }
    }
    
    private func createVisionRequests(completion: @escaping VisionScanCompletion) -> [VNRequest] {
        func errorWhileScanning() {
            DispatchQueue.main.async {
                completion(.failure(.scanError))
            }
        }
        func handleDetectedBarcodes(request: VNRequest?, error: Error?) {
            if let error = error as NSError? {
                Log("Error while handling vision request \(error)", module: .camera)
                errorWhileScanning()
                return
            }
            
            guard let results = request?.results as? [VNBarcodeObservation] else {
                Log("Returned type is not a barcode", module: .camera)
                errorWhileScanning()
                return
            }
            
            let codes = results.compactMap({ $0.payloadStringValue })
            
            DispatchQueue.main.async {
                guard !codes.isEmpty else {
                    completion(.failure(.noCodesFound))
                    return
                }
                
                completion(.success(codes))
            }
        }
        
        let barcodeDetectRequest = VNDetectBarcodesRequest(completionHandler: handleDetectedBarcodes)
        barcodeDetectRequest.symbologies = [.qr]

        return [barcodeDetectRequest]
    }
}

private extension CGImagePropertyOrientation {
    init(_ uiImageOrientation: UIImage.Orientation) {
        switch uiImageOrientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        default: self = .up
        }
    }
}
