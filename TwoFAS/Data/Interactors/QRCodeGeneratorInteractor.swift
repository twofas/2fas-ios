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
    func qrCode(of size: CGFloat, margin: CGFloat, for link: String) -> UIImage?
}

final class QRCodeGeneratorInteractor {
    private let correctionLevel = "L"
}

extension QRCodeGeneratorInteractor: QRCodeGeneratorInteracting {
    func qrCode(of size: CGFloat, margin: CGFloat, for link: String) -> UIImage? {
        guard let qrCode = generateQRCode(from: link) else {
            return nil
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
            return nil
        }
        

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let image = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: size, height: size))
            
            let qrCodeImage = UIImage(cgImage: cgImage)
            qrCodeImage.draw(in: CGRect(x: margin, y: margin, width: finalSize, height: finalSize))
        }
        
        return image
    }
}

private extension QRCodeGeneratorInteractor {
    func generateQRCode(from text: String) -> CIImage? {
        guard let data = text.data(using: .ascii) else {
            return nil
        }
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(correctionLevel, forKey: "inputCorrectionLevel")
        
        return filter.outputImage
    }
}
