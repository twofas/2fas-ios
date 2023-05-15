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

// swiftlint:disable all
enum ExportPublicKey {
    private static let kCryptoExportImportManagerASNHeaderLengthForRSA = 15
    private static let kCryptoExportImportManagerASNHeaderSequenceMark: UInt8 = 48 // 0x30
    
    private static let kCryptoExportImportManagerRSAOIDHeader: [UInt8] = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]
    private static let kCryptoExportImportManagerRSAOIDHeaderLength = 15
    
    private static let kCryptoExportImportManagerASNHeaderBitstringMark: UInt8 = 03 //0x03
    private static let kCryptoExportImportManagerExtendedLengthMark: UInt8 = 128  // 0x80

    static func exportRSAPublicKeyToDER(_ rawPublicKeyBytes: Data) -> Data {
        // first we create the space for the ASN.1 header and decide about its length
        let bitstringEncodingLength = bytesNeededForRepresentingInteger(rawPublicKeyBytes.count)
        
        // start building the ASN.1 header
        var headerBuffer = [UInt8](repeating: 0, count: kCryptoExportImportManagerASNHeaderLengthForRSA);
        headerBuffer[0] = kCryptoExportImportManagerASNHeaderSequenceMark;
        
        // total size (OID + encoding + key size) + 2 (marks)
        let totalSize = kCryptoExportImportManagerRSAOIDHeaderLength + bitstringEncodingLength + rawPublicKeyBytes.count + 3
        let totalSizebitstringEncodingLength = encodeASN1LengthParameter(totalSize, buffer: &(headerBuffer[1]))
        
        // bitstring header
        var keyLengthBytesEncoded = 0
        var bitstringBuffer = [UInt8](repeating: 0, count: kCryptoExportImportManagerASNHeaderLengthForRSA)
        bitstringBuffer[0] = kCryptoExportImportManagerASNHeaderBitstringMark
        keyLengthBytesEncoded = encodeASN1LengthParameter(rawPublicKeyBytes.count + 1, buffer: &(bitstringBuffer[1]))
        bitstringBuffer[keyLengthBytesEncoded + 1] = 0x00
        
        // build DER key.
        var derKey = Data(capacity: totalSize + totalSizebitstringEncodingLength)
        derKey.append(headerBuffer, count: totalSizebitstringEncodingLength + 1)
        derKey.append(
            kCryptoExportImportManagerRSAOIDHeader,
            count: kCryptoExportImportManagerRSAOIDHeaderLength
        ) // Add OID header
        derKey.append(bitstringBuffer, count: keyLengthBytesEncoded + 2) // 0x03 + key bitstring length + 0x00
        derKey.append(rawPublicKeyBytes) // public key raw data.

        return derKey
    }

    static private func bytesNeededForRepresentingInteger(_ number: Int) -> Int {
        if number <= 0 { return 0 }
        var i = 1
        while i < 8 && number >= (1 << (i * 8)) {
            i += 1
        }
        return i
    }
    
    static private func encodeASN1LengthParameter(_ length: Int, buffer: UnsafeMutablePointer<UInt8>) -> Int {
        if length < Int(kCryptoExportImportManagerExtendedLengthMark) {
            buffer[0] = UInt8(length)
            return 1 // just one byte was used, no need for length starting mark (0x80).
        } else {
            let extraBytes = bytesNeededForRepresentingInteger(length)
            var currentLengthValue = length
            
            buffer[0] = kCryptoExportImportManagerExtendedLengthMark + UInt8(extraBytes)
            for i in 0 ..< extraBytes {
                buffer[extraBytes - i] = UInt8(currentLengthValue & 0xff)
                currentLengthValue = currentLengthValue >> 8
            }
            return extraBytes + 1 // 1 byte for the starting mark (0x80 + bytes used) + bytes used to encode length.
        }
    }
}
// swiftlint:enable all
