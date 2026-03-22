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

struct PairIconBadge: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .renderingMode(.template)
            .font(.system(size: 24))
            .foregroundStyle(Color.accent)
            .frame(width: 42, height: 42)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
            )
    }
}

struct PairQRCodeView: View {
    private let dimension = 120

    @State private var currentPage = 0
    private let totalPages = 6

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                instructionPage(
                    icon: "applewatch.and.arrow.forward",
                    text: T.Watch.introStep1
                )
                .tag(0)

                instructionPage(
                    icon: "gearshape",
                    text: T.Watch.introStep2
                )
                .tag(1)

                instructionPage(
                    icon: "icloud",
                    text: T.Watch.introStep3
                )
                .tag(2)

                instructionPage(
                    icon: "applewatch",
                    text: T.Watch.introStep4
                )
                .tag(3)

                instructionPage(
                    icon: "qrcode.viewfinder",
                    text: T.Watch.introStep5
                )
                .tag(4)

                qrCodePage()
                    .tag(5)
                
                instructionPage(
                    icon: "checkmark.circle.fill",
                    text: T.Watch.introStep6
                )
            }
            .tabViewStyle(.verticalPage)
        }
    }

    private func instructionPage(icon: String, text: String) -> some View {
        VStack(spacing: 12) {
            PairIconBadge(systemName: icon)
            Text(text)
                .font(.body)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.5)
                .allowsTightening(true)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func qrCodePage() -> some View {
        VStack {
            if let image = generateQRCode() {
                Image(uiImage: image)
                    .interpolation(.none)
                    .renderingMode(.original)
            } else {
                Text(verbatim: T.Backup.watchPairQrError)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
