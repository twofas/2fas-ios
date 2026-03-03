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

import SwiftUI
import EFQRCode
import CommonWatch

struct PairQRCodeView: View {
    private let dimension = 120
    private let padding: CGFloat = 24
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text(verbatim: T.Backup.watchPairTitle)
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                Spacer()
                HStack {
                    Text(verbatim: T.Backup.watchPairDescription)
                        .font(.body)
                    Spacer()
                }
                Spacer(minLength: padding)
                if let image = generateQRCode() {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .renderingMode(.original)
                } else {
                    Text(verbatim: T.Backup.watchPairQrError)
                }
                Spacer(minLength: padding)
            }
        }
    }
    
    private func generateQRCode() -> UIImage? {
        let deviceCode = MainRepositoryImpl.shared.deviceCode.code
        let devicePath = DeviceCodePath(code: deviceCode)
        let generator = EFQRCodeGenerator(
            content: devicePath.codePath,
            encoding: .ascii,
            size: EFIntSize(width: dimension, height: dimension)
        )
        generator.withMode(EFQRCodeMode.grayscale)
        generator.withInputCorrectionLevel(EFInputCorrectionLevel.l)
        
        guard let cgImage = generator.generate() else {
            return nil
        }
        
        let image = UIImage(cgImage: cgImage)
            .withRenderingMode(.alwaysOriginal)
        
        return image
    }
}
