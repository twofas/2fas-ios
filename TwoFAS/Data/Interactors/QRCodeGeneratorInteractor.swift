//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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

public protocol QRCodeGeneratorInteracting: AnyObject {
    func qrCode(of size: CGFloat, margin: CGFloat, for link: String) async -> UIImage?
}

final class QRCodeGeneratorInteractor: QRCodeGeneratorInteracting {
    func qrCode(of size: CGFloat, margin: CGFloat, for link: String) async -> UIImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let data = link.data(using: .ascii) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
                    continuation.resume(returning: nil)
                    return
                }
                
                filter.setValue(data, forKey: "inputMessage")
                filter.setValue("L", forKey: "inputCorrectionLevel")
                
                guard let qrCode = filter.outputImage else {
                    continuation.resume(returning: nil)
                    return
                }
                let finalSize = size - 2 * margin
                let scale = UIScreen.main.scale
                let scaledSize = CGSize(width: finalSize * scale, height: finalSize * scale)
                let context = CIContext(options: [
                    .useSoftwareRenderer: false,
                    .highQualityDownsample: true
                ])
                let transform = CGAffineTransform(
                    scaleX: scaledSize.width / qrCode.extent.width,
                    y: scaledSize.height / qrCode.extent.height
                )
                let scaledQRCode = qrCode.transformed(by: transform)
                guard let cgImage = context.createCGImage(scaledQRCode, from: scaledQRCode.extent) else {
                    continuation.resume(returning: nil)
                    return
                }
                // UIKit drawing must be on main thread
                DispatchQueue.main.async {
                    let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
                    let image = renderer.image { context in
                        UIColor.white.setFill()
                        context.fill(CGRect(x: 0, y: 0, width: size, height: size))
                        let qrCodeImage = UIImage(cgImage: cgImage)
                        qrCodeImage.draw(in: CGRect(x: margin, y: margin, width: finalSize, height: finalSize))
                    }
                    continuation.resume(returning: image)
                }
            }
        }
    }
}
