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
import Data
import Common
import CryptoKit

protocol ExportTokensModuleInteracting: AnyObject {
    var hasServices: Bool { get }
    var hasPIN: Bool { get }
    func generateOTPAuthCodes() -> String
    func copyToClipBoardGenertedCodes()
    func generateQRCodeFiles() async -> [URL]
    func cleanupTemporaryFiles(urls: [URL])
}

final class ExportTokensModuleInteractor {
    private let serviceListingInteractor: ServiceListingInteracting
    private let notificationsInteractor: NotificationInteracting
    private let qrCodeGeneratorInteractor: QRCodeGeneratorInteracting
    private let serviceDefinitionInteractor: ServiceDefinitionInteracting
    private let protectionInteractor: ProtectionInteracting
    
    private let fileManager = FileManager.default
    
    var hasServices: Bool {
        serviceListingInteractor.hasServices
    }
    
    var hasPIN: Bool {
        protectionInteractor.isPINSet
    }
    
    init(
        serviceListingInteractor: ServiceListingInteracting,
        notificationsInteractor: NotificationInteracting,
        qrCodeGeneratorInteractor: QRCodeGeneratorInteracting,
        serviceDefinitionInteractor: ServiceDefinitionInteracting,
        protectionInteractor: ProtectionInteracting
    ) {
        self.serviceListingInteractor = serviceListingInteractor
        self.notificationsInteractor = notificationsInteractor
        self.qrCodeGeneratorInteractor = qrCodeGeneratorInteractor
        self.serviceDefinitionInteractor = serviceDefinitionInteractor
        self.protectionInteractor = protectionInteractor
    }
}

extension ExportTokensModuleInteractor: ExportTokensModuleInteracting {
    func generateOTPAuthCodes() -> String {
        serviceListingInteractor.listAll()
            .map { serviceDefinitionInteractor.otpAuth(from: $0) }
            .joined(separator: "\n")
    }
    
    func copyToClipBoardGenertedCodes() {
        notificationsInteractor.copyWithSuccessNoModification(value: generateOTPAuthCodes())
    }
    
    func generateQRCodeFiles() async -> [URL] {
        let codes = await generateQRCodes()
        let urls = createTemporaryFiles(from: codes)
        return urls
    }
    
    func cleanupTemporaryFiles(urls: [URL]) {
        for url in urls {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                Log("ExportTokensModuleInteractor: Failed to remove temporary file \(url.lastPathComponent): \(error)")
            }
        }
    }
}

private extension ExportTokensModuleInteractor {
    func createTemporaryFiles(from imageFilePairs: [String: Data]) -> [URL] {
        let tempDirectory = fileManager.temporaryDirectory
        
        var createdURLs: [URL] = []
        
        Log("ExportTokensModuleInteractor: Creating \(imageFilePairs.count) temporary files in \(tempDirectory.path)")
        
        for (filename, imageData) in imageFilePairs {
            let fileURL = tempDirectory.appendingPathComponent(filename)
            
            Log("ExportTokensModuleInteractor: Creating file: \(filename) at \(fileURL.path)")
            
            do {
                try imageData.write(to: fileURL)
                createdURLs.append(fileURL)
            } catch {
                Log("ExportTokensModuleInteractor: Failed to create temporary file \(filename): \(error)")
                Log("ExportTokensModuleInteractor: Error details - code: \((error as NSError).code), domain: \((error as NSError).domain)")
            }
        }
        
        Log("ExportTokensModuleInteractor: Created \(createdURLs.count) out of \(imageFilePairs.count) files")
                
        return createdURLs
    }
    
    func generateQRCodes() async -> [String: Data] {
        let list = serviceListingInteractor.listAll()
            .map { serviceDefinitionInteractor.otpAuth(from: $0) }
        var result: [String: Data] = [:]
        
        Log("ExportTokensModuleInteractor: Generating QR codes for \(list.count) services")
        
        await withTaskGroup(of: (String, Data?).self) { group in
            for (index, secret) in list.enumerated() {
                group.addTask {
                    Log("ExportTokensModuleInteractor: Generating QR code \(index + 1)/\(list.count)")
                    let qrCode = await self.createQRCode(link: secret)
                    return (secret, qrCode)
                }
            }
            
            for await (secret, qrCode) in group {
                if let qrCode {
                    let filename = createName(for: secret)
                    result[filename] = qrCode
                    Log("ExportTokensModuleInteractor: Generated QR code: \(filename)")
                } else {
                    Log("ExportTokensModuleInteractor: Failed to generate QR code for secret")
                }
            }
        }
        
        Log("ExportTokensModuleInteractor: Generated \(result.count) QR codes")
        return result
    }
    
    func createName(for secret: String) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let data = Data("\(secret)\(timestamp)".utf8)
        let hash = SHA256.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        return "QR_\(hash.prefix(16)).png"
    }
    
    func createQRCode(link: String) async -> Data? {
        do {
            let qrCode = await qrCodeGeneratorInteractor.qrCode(
                of: Config.minQRCodeSize,
                margin: round(Config.minQRCodeSize / 12.0),
                for: link
            )
            
            guard let qrCode = qrCode else {
                Log("ExportTokensModuleInteractor: Failed to generate QR code image")
                return nil
            }
            
            guard let pngData = qrCode.pngData() else {
                Log("ExportTokensModuleInteractor: Failed to convert QR code to PNG data")
                return nil
            }
            
            Log("ExportTokensModuleInteractor: Successfully created QR code PNG data: \(pngData.count) bytes")
            return pngData
        } catch {
            Log("ExportTokensModuleInteractor: Error creating QR code: \(error)")
            return nil
        }
    }
}
