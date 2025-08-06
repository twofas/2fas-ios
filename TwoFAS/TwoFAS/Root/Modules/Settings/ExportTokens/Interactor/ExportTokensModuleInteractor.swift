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
    func copyToClipboardGeneratedCodes(message: String)
    func createOTPAuthCodesFile() -> URL?
    func createQRCodeFiles() async -> URL?
    func cleanupTemporaryFiles(urls: [URL])
}

final class ExportTokensModuleInteractor {
    private let serviceListingInteractor: ServiceListingInteracting
    private let notificationsInteractor: NotificationInteracting
    private let qrCodeGeneratorInteractor: QRCodeGeneratorInteracting
    private let serviceDefinitionInteractor: ServiceDefinitionInteracting
    private let protectionInteractor: ProtectionInteracting
    private let compressionInteractor: CompressionInteracting
    
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
        protectionInteractor: ProtectionInteracting,
        compressionInteractor: CompressionInteracting
    ) {
        self.serviceListingInteractor = serviceListingInteractor
        self.notificationsInteractor = notificationsInteractor
        self.qrCodeGeneratorInteractor = qrCodeGeneratorInteractor
        self.serviceDefinitionInteractor = serviceDefinitionInteractor
        self.protectionInteractor = protectionInteractor
        self.compressionInteractor = compressionInteractor
    }
}

extension ExportTokensModuleInteractor: ExportTokensModuleInteracting {
    func createOTPAuthCodesFile() -> URL? {
        let contents = generateOTPAuthCodes().utf8
        let data = Data(contents)
        let fileName = "otpauth_\(Date().fileDateAndTime()).txt"
        return createTemporaryFiles(from: [fileName: data]).first
    }
    
    func copyToClipboardGeneratedCodes(message: String) {
        notificationsInteractor.copyWithSuccess(value: generateOTPAuthCodes())
        HUDNotification.presentSuccess(title: message)
    }
    
    func createQRCodeFiles() async -> URL? {
        let codes = await generateQRCodes()
        let urls = createTemporaryFiles(from: codes)
        let zipURL = await compressionInteractor.zipFiles(urls, into: "QRCodes_\(Date().fileDateAndTime())")
        cleanupTemporaryFiles(urls: urls)
        return zipURL
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
    func generateOTPAuthCodes() -> String {
        serviceListingInteractor.listAll()
            .map { serviceDefinitionInteractor.otpAuth(from: $0) }
            .joined(separator: "\n")
    }
    
    func createTemporaryFiles(from filePairs: [String: Data]) -> [URL] {
        let tempDirectory = fileManager.temporaryDirectory
        
        var createdURLs: [URL] = []
        
        Log("ExportTokensModuleInteractor: Creating \(filePairs.count) temporary files in \(tempDirectory.path)")
        
        for (filename, data) in filePairs {
            let fileURL = URL(fileURLWithPath: tempDirectory.appendingPathComponent(filename).path())
            
            Log("ExportTokensModuleInteractor: Creating file: \(filename) at \(fileURL.path)")
            
            do {
                try data.write(to: fileURL, options: .atomic)
                createdURLs.append(fileURL)
            } catch {
                Log("ExportTokensModuleInteractor: Failed to create temporary file \(filename): \(error)")
                let errorCode = (error as NSError).code
                let domain = (error as NSError).domain
                Log("ExportTokensModuleInteractor: Error details - code: \(errorCode), domain: \(domain)")
            }
        }
        
        Log("ExportTokensModuleInteractor: Created \(createdURLs.count) out of \(filePairs.count) files")
        
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
                    let filename = createQRCodeImageName(from: secret)
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
    
    func createQRCodeImageName(from content: String) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let data = Data("\(content)\(timestamp)".utf8)
        let hash = SHA256.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        return "QR_\(hash.prefix(16)).png"
    }
    
    func createQRCode(link: String) async -> Data? {
        let qrCode = await qrCodeGeneratorInteractor.qrCode(
            of: Config.minQRCodeSize,
            margin: round(Config.minQRCodeSize / 12.0),
            for: link
        )
        
        guard let qrCode else {
            Log("ExportTokensModuleInteractor: Failed to generate QR code image")
            return nil
        }
        
        guard let pngData = qrCode.pngData() else {
            Log("ExportTokensModuleInteractor: Failed to convert QR code to PNG data")
            return nil
        }
        
        Log("ExportTokensModuleInteractor: Successfully created QR code PNG data: \(pngData.count) bytes")
        return pngData
    }
}
